import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import 'budgets_controller.dart';

/// Sección "Presupuestos" del dashboard: progreso del mes para las categorías
/// con tope definido. Si no hay ninguno, invita a crear el primero.
class DashboardBudgetsSection extends ConsumerWidget {
  const DashboardBudgetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(budgetStatusesProvider).valueOrNull ?? const [];
    final budgeted = statuses.where((s) => s.hasBudget).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Presupuestos',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.pushNamed(AppRoute.budgets.name),
              child: Text(budgeted.isEmpty ? 'Definir' : 'Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (budgeted.isEmpty)
          Card(
            child: InkWell(
              onTap: () => context.pushNamed(AppRoute.budgets.name),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.donut_small_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Define topes por categoría para controlar tus gastos.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                children: [
                  for (final s in budgeted) _BudgetRow(status: s),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.status});
  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = status.category;
    final color = status.over
        ? scheme.error
        : status.warning
            ? Colors.orange.shade700
            : scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cat.iconData, size: 16, color: cat.colorValue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${Formatters.currency(status.spent)} / '
                '${Formatters.currency(status.limit)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: status.over ? scheme.error : null,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: status.fraction.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
