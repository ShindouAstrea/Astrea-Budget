import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../categories/domain/category.dart' show kCategoryIcons;
import '../../households/presentation/household_controller.dart';
import '../../households/presentation/household_switcher.dart';
import '../../onboarding/presentation/feature_tour.dart';
import '../../onboarding/presentation/feature_tours.dart';
import '../domain/savings_goal.dart';
import 'savings_controller.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de ahorro'),
        actions: const [
          FeatureTourButton(tour: savingsTour),
          HouseholdIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-savings',
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar las metas.',
          onRetry: () => ref.invalidate(savingsGoalsProvider),
        ),
        data: (goals) {
          if (goals.isEmpty) {
            return const EmptyStateView(
              icon: Icons.savings_outlined,
              title: 'Sin metas de ahorro',
              message: 'Crea una meta (ej. Vacaciones) y sigue tu progreso.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final g in goals)
                _GoalCard(
                  goal: g,
                  onTap: () => _openForm(context, goal: g),
                  onContribute: () => _contribute(context, ref, g),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {SavingsGoal? goal}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _GoalForm(goal: goal),
    );
  }

  Future<void> _contribute(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Aportar a ${goal.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Monto', prefixText: r'$ '),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text) ?? 0;
              if (v > 0) Navigator.pop(ctx, -v); // retirar
            },
            child: const Text('Retirar'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text) ?? 0;
              if (v > 0) Navigator.pop(ctx, v); // aportar
            },
            child: const Text('Aportar'),
          ),
        ],
      ),
    );
    if (result == null || result == 0) return;
    try {
      await ref.read(savingsActionsProvider).contribute(goal.id, result);
      if (context.mounted) {
        context.showSuccess(result > 0 ? 'Aporte registrado' : 'Retiro registrado');
      }
    } catch (_) {
      if (context.mounted) context.showError('No se pudo registrar');
    }
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onContribute,
  });

  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback onContribute;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final suggested = goal.suggestedMonthly;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: goal.colorValue.withValues(alpha: 0.16),
                    child: Icon(goal.iconData, color: goal.colorValue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name,
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          '${Formatters.currency(goal.currentAmount)} de '
                          '${Formatters.currency(goal.targetAmount)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(goal.progress * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: goal.isComplete ? scheme.primary : null,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(goal.colorValue),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.isComplete
                        ? '¡Meta cumplida! 🎉'
                        : 'Faltan ${Formatters.currency(goal.remaining)}'
                            '${suggested != null ? ' · ${Formatters.currency(suggested)}/mes' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                if (!goal.isComplete)
                  FilledButton.tonal(
                    onPressed: onContribute,
                    child: const Text('Aportar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({this.goal});
  final SavingsGoal? goal;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _current;
  DateTime? _targetDate;
  String? _accountId;
  late String _icon;
  late String _color;
  bool _saving = false;

  bool get _isEditing => widget.goal != null;

  static const _palette = [
    '#16A34A', '#2563EB', '#F97316', '#8B5CF6',
    '#EC4899', '#14B8A6', '#EAB308', '#0EA5E9',
  ];
  static const _icons = [
    'savings', 'flight', 'home', 'school',
    'card_giftcard', 'directions_bus', 'favorite', 'phone_android',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(
      text: g != null ? g.targetAmount.toInt().toString() : '',
    );
    _current = TextEditingController(
      text: g != null ? g.currentAmount.toInt().toString() : '',
    );
    _targetDate = g?.targetDate;
    _accountId = g?.accountId;
    _icon = g?.icon ?? 'savings';
    _color = g?.color ?? _palette.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final actions = ref.read(savingsActionsProvider);
    final target = Formatters.parseAmount(_target.text)!;
    try {
      if (_isEditing) {
        await actions.update(widget.goal!.copyWith(
          name: _name.text.trim(),
          targetAmount: target.toDouble(),
          targetDate: _targetDate,
          accountId: _accountId,
          icon: _icon,
          color: _color,
        ));
      } else {
        await actions.create(
          name: _name.text.trim(),
          targetAmount: target,
          currentAmount: int.tryParse(_current.text) ?? 0,
          targetDate: _targetDate,
          accountId: _accountId,
          icon: _icon,
          color: _color,
        );
      }
      if (mounted) {
        context.showSuccess('Meta guardada');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    try {
      await ref.read(savingsActionsProvider).remove(widget.goal!.id);
      if (mounted) {
        context.showSuccess('Meta eliminada');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('Sólo quien la creó (o el dueño) puede borrarla');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final myId = ref.watch(currentUserProvider)?.id;
    final isOwner = ref.watch(isActiveHouseholdOwnerProvider).valueOrNull ?? false;
    final canDelete =
        _isEditing && (widget.goal!.userId == myId || isOwner);

    if (_accountId != null && !accounts.any((a) => a.id == _accountId)) {
      _accountId = null;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              _isEditing ? 'Editar meta' : 'Nueva meta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre (ej. Vacaciones)'),
              validator: (v) => Validators.required(v, field: 'El nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _target,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Meta a juntar',
                prefixText: r'$ ',
              ),
              validator: Validators.amount,
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _current,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Ya ahorrado (opcional)',
                  prefixText: r'$ ',
                ),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4),
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.event_outlined),
              ),
              title: const Text('Fecha objetivo (opcional)'),
              subtitle: Text(_targetDate == null
                  ? 'Sin fecha'
                  : Formatters.dayMonthYear(_targetDate!)),
              trailing: _targetDate == null
                  ? const Icon(Icons.chevron_right)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _targetDate = null),
                    ),
              onTap: _pickDate,
            ),
            if (accounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _accountId,
                decoration: const InputDecoration(
                  labelText: 'Cuenta asociada (opcional)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Ninguna')),
                  for (final a in accounts)
                    DropdownMenuItem(
                      value: a.id,
                      child: Row(
                        children: [
                          Icon(a.iconData, size: 18, color: a.colorValue),
                          const SizedBox(width: 8),
                          Text(a.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _accountId = v),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.fromHex(hex),
                        shape: BoxShape.circle,
                        border: _color == hex
                            ? Border.all(
                                width: 3,
                                color: Theme.of(context).colorScheme.onSurface)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ícono', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in _icons)
                  GestureDetector(
                    onTap: () => setState(() => _icon = key),
                    child: CircleAvatar(
                      backgroundColor: _icon == key
                          ? AppColors.fromHex(_color)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        kCategoryIcons[key] ?? Icons.savings,
                        color: _icon == key
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Guardar' : 'Crear'),
            ),
            if (canDelete)
              TextButton(
                onPressed: _saving ? null : _delete,
                child: Text(
                  'Eliminar meta',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
