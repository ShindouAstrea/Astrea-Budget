import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import 'trends_bar_chart.dart';
import 'trends_controller.dart';

/// Sección "Tendencias" del dashboard: barras de los últimos meses + la
/// comparación de gasto contra el mes anterior. Toca para ver el detalle.
class DashboardTrendsSection extends ConsumerWidget {
  const DashboardTrendsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(monthlyTrendsProvider);
    final comparison = ref.watch(trendComparisonProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tendencias',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => context.pushNamed(AppRoute.trends.name),
              child: const Text('Ver más'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Card(
          child: InkWell(
            onTap: () => context.pushNamed(AppRoute.trends.name),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: trendsAsync.when(
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const SizedBox(
                  height: 80,
                  child: Center(child: Text('No se pudo cargar la tendencia.')),
                ),
                data: (trends) {
                  final hasData =
                      trends.any((t) => t.income > 0 || t.expense > 0);
                  if (!hasData) {
                    return const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text('Aún no hay datos para la tendencia.'),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      if (comparison != null)
                        _ComparisonLine(comparison: comparison),
                      const SizedBox(height: 8),
                      TrendsBarChart(trends: trends),
                      const SizedBox(height: 8),
                      const TrendsLegend(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonLine extends StatelessWidget {
  const _ComparisonLine({required this.comparison});
  final TrendComparison comparison;

  @override
  Widget build(BuildContext context) {
    final finance = context.finance;
    final pct = comparison.expenseChangePct;
    if (pct == null || pct.abs() < 0.5) {
      return Text(
        'Tu gasto se mantuvo respecto al mes pasado.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final more = pct > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          more ? Icons.trending_up : Icons.trending_down,
          size: 18,
          color: more ? finance.expense : finance.income,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Gastaste ${pct.abs().round()}% ${more ? 'más' : 'menos'} '
            'que el mes pasado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: more ? finance.expense : finance.income,
                ),
          ),
        ),
      ],
    );
  }
}
