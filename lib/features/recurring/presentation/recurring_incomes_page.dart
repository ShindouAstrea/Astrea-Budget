import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../households/presentation/household_switcher.dart';
import '../domain/recurring_income.dart';
import '../domain/recurring_schedule.dart';
import 'recurring_income_controller.dart';

class RecurringIncomesPage extends ConsumerWidget {
  const RecurringIncomesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(recurringIncomesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos recurrentes'),
        actions: const [HouseholdIndicator()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-recurring',
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: incomesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar los ingresos recurrentes.',
          onRetry: () => ref.invalidate(recurringIncomesProvider),
        ),
        data: (incomes) {
          if (incomes.isEmpty) {
            return const EmptyStateView(
              icon: Icons.event_repeat_outlined,
              title: 'Sin ingresos recurrentes',
              message: 'Crea uno (ej. tu sueldo) para que se registre solo '
                  'cada mes.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final i in incomes)
                _IncomeCard(income: i, onTap: () => _openForm(context, income: i)),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {RecurringIncome? income}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RecurringIncomeForm(income: income),
    );
  }
}

/// Tarjeta de una plantilla. Muestra en qué va la generación automática —
/// último registro y próxima fecha— y deja registrar a mano lo atrasado, para
/// que "no se registró solo" deje de ser un misterio.
class _IncomeCard extends ConsumerStatefulWidget {
  const _IncomeCard({required this.income, required this.onTap});
  final RecurringIncome income;
  final VoidCallback onTap;

  @override
  ConsumerState<_IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends ConsumerState<_IncomeCard> {
  bool _running = false;

  RecurringIncome get _income => widget.income;

  Future<void> _generateNow() async {
    setState(() => _running = true);
    try {
      final created =
          await ref.read(recurringIncomeActionsProvider).generateNow(_income);
      if (!mounted) return;
      context.showSuccess(
        created == 0
            ? 'No había nada pendiente'
            : 'Se registró el ingreso ($created ${created == 1 ? 'mes' : 'meses'})',
      );
    } catch (_) {
      if (mounted) context.showError('No se pudo registrar el ingreso');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pending = _income.active
        ? pendingOccurrences(
            dayOfMonth: _income.dayOfMonth,
            lastGenerated: _income.lastGenerated,
            today: today,
          )
        : const <DateTime>[];
    final next = nextOccurrence(
      dayOfMonth: _income.dayOfMonth,
      lastGenerated: _income.lastGenerated,
      today: today,
    );

    final String estado;
    if (!_income.active) {
      estado = 'Pausado: no se registra solo';
    } else if (pending.isNotEmpty) {
      estado = 'Pendiente desde el ${Formatters.dayMonthYear(pending.first)}';
    } else if (_income.lastGenerated != null) {
      estado = 'Último: ${Formatters.dayMonthYear(_income.lastGenerated!)} · '
          'próximo: ${Formatters.dayMonthYear(next)}';
    } else {
      estado = 'Próximo: ${Formatters.dayMonthYear(next)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ListTile(
            onTap: widget.onTap,
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                _income.active
                    ? Icons.event_repeat
                    : Icons.pause_circle_outline,
                color: scheme.onPrimaryContainer,
              ),
            ),
            title: Text(_income.description),
            isThreeLine: true,
            subtitle: Text(
              'Día ${_income.dayOfMonth} · '
              '${Formatters.currency(_income.amount)}\n$estado',
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          if (pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_running)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: _generateNow,
                      icon: const Icon(Icons.playlist_add_check),
                      label: Text(
                        pending.length == 1
                            ? 'Registrar ahora'
                            : 'Registrar ${pending.length} meses',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecurringIncomeForm extends ConsumerStatefulWidget {
  const _RecurringIncomeForm({this.income});
  final RecurringIncome? income;

  @override
  ConsumerState<_RecurringIncomeForm> createState() =>
      _RecurringIncomeFormState();
}

class _RecurringIncomeFormState extends ConsumerState<_RecurringIncomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _amount;
  String? _categoryId;
  String? _accountId;
  late int _dayOfMonth;
  late bool _active;
  bool _saving = false;

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    final i = widget.income;
    _description = TextEditingController(text: i?.description ?? '');
    _amount = TextEditingController(
      text: i != null ? i.amount.toInt().toString() : '',
    );
    _categoryId = i?.categoryId;
    _accountId = i?.accountId;
    _dayOfMonth = i?.dayOfMonth ?? 1;
    _active = i?.active ?? true;
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final actions = ref.read(recurringIncomeActionsProvider);
    final amount = Formatters.parseAmount(_amount.text)!;
    try {
      if (_isEditing) {
        await actions.update(widget.income!.copyWith(
          description: _description.text.trim(),
          amount: amount.toDouble(),
          categoryId: _categoryId,
          accountId: _accountId,
          dayOfMonth: _dayOfMonth,
          active: _active,
        ));
      } else {
        await actions.create(
          description: _description.text.trim(),
          amount: amount,
          categoryId: _categoryId,
          accountId: _accountId,
          dayOfMonth: _dayOfMonth,
        );
      }
      if (mounted) {
        context.showSuccess('Ingreso recurrente guardado');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    await ref.read(recurringIncomeActionsProvider).remove(widget.income!.id);
    if (mounted) {
      context.showSuccess('Ingreso recurrente eliminado');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(TransactionType.income));
    final accounts = ref.watch(accountsProvider).value ?? const [];

    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
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
              _isEditing ? 'Editar ingreso recurrente' : 'Nuevo ingreso recurrente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (ej. Sueldo)',
              ),
              validator: (v) => Validators.required(v, field: 'La descripción'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _dayOfMonth,
              decoration: const InputDecoration(
                labelText: 'Día del mes',
                prefixIcon: Icon(Icons.event_outlined),
              ),
              items: [
                for (var d = 1; d <= 28; d++)
                  DropdownMenuItem(value: d, child: Text('Día $d')),
              ],
              onChanged: (v) => setState(() => _dayOfMonth = v ?? _dayOfMonth),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(c.iconData, size: 18, color: c.colorValue),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            if (accounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _accountId,
                decoration: const InputDecoration(
                  labelText: 'Cuenta',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin cuenta')),
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
            if (_isEditing) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo'),
                subtitle: const Text('Si lo pausas, deja de registrarse.'),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Guardar' : 'Crear'),
            ),
            if (_isEditing)
              TextButton(
                onPressed: _saving ? null : _delete,
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
