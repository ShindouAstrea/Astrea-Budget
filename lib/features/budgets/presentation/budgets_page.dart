import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/month_selector.dart';
import '../../../core/widgets/state_views.dart';
import '../../households/presentation/household_controller.dart';
import '../../households/presentation/household_switcher.dart';
import 'budgets_controller.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(budgetStatusesProvider);
    final isOwner =
        ref.watch(isActiveHouseholdOwnerProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: const [HouseholdIndicator()],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: MonthSelector(),
          ),
          Expanded(
            child: statusesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(
                message: 'No pudimos cargar los presupuestos.',
                onRetry: () => ref.invalidate(budgetStatusesProvider),
              ),
              data: (statuses) {
                if (statuses.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.donut_small_outlined,
                    title: 'Sin categorías de gasto',
                    message: 'Crea categorías de gasto para asignarles un tope.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    if (!isOwner)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sólo el propietario del presupuesto puede definir topes.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ),
                    for (final s in statuses)
                      _BudgetTile(
                        status: s,
                        onTap: isOwner
                            ? () => _editBudget(context, ref, s)
                            : null,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetStatus status,
  ) async {
    final controller = TextEditingController(
      text: status.hasBudget ? status.limit.toInt().toString() : '',
    );
    final result = await showDialog<_BudgetEditResult>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tope de ${status.category.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Tope mensual',
            prefixText: r'$ ',
          ),
        ),
        actions: [
          if (status.hasBudget)
            TextButton(
              onPressed: () => Navigator.pop(ctx, const _BudgetEditResult.remove()),
              child: Text(
                'Quitar',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              Navigator.pop(ctx, _BudgetEditResult.save(amount));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final actions = ref.read(budgetActionsProvider);
    try {
      if (result.remove || result.amount <= 0) {
        await actions.remove(status.category.id);
      } else {
        await actions.set(status.category.id, result.amount);
      }
      if (context.mounted) context.showSuccess('Presupuesto actualizado');
    } catch (_) {
      if (context.mounted) context.showError('No se pudo guardar el tope');
    }
  }
}

class _BudgetEditResult {
  const _BudgetEditResult.save(this.amount) : remove = false;
  const _BudgetEditResult.remove()
      : amount = 0,
        remove = true;
  final int amount;
  final bool remove;
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.status, this.onTap});

  final BudgetStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = status.category;
    final color = status.over
        ? scheme.error
        : status.warning
            ? Colors.orange.shade700
            : scheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: cat.colorValue.withValues(alpha: 0.15),
                    child: Icon(cat.iconData, size: 18, color: cat.colorValue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (status.hasBudget)
                    Text(
                      '${Formatters.currency(status.spent)} / '
                      '${Formatters.currency(status.limit)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  else
                    Text(
                      onTap != null ? 'Definir tope' : 'Sin tope',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                          ),
                    ),
                ],
              ),
              if (status.hasBudget) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: status.fraction.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status.over
                      ? 'Te pasaste por ${Formatters.currency(-status.remaining)}'
                      : 'Quedan ${Formatters.currency(status.remaining)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: status.over ? scheme.error : scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
