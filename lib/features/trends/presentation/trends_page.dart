import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../households/presentation/household_switcher.dart';
import 'trends_bar_chart.dart';
import 'trends_controller.dart';

class TrendsPage extends ConsumerWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(monthlyTrendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendencias'),
        actions: const [HouseholdIndicator()],
      ),
      body: trendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar las tendencias.',
          onRetry: () => ref.invalidate(monthlyTrendsProvider),
        ),
        data: (trends) {
          final hasData = trends.any((t) => t.income > 0 || t.expense > 0);
          if (!hasData) {
            return const EmptyStateView(
              icon: Icons.bar_chart_outlined,
              title: 'Sin datos suficientes',
              message: 'Registra movimientos para ver tu evolución mensual.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    children: [
                      TrendsBarChart(trends: trends, height: 240),
                      const SizedBox(height: 12),
                      const TrendsLegend(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Detalle por mes',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final t in trends.reversed) _MonthRow(trend: t),
            ],
          );
        },
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.trend});
  final MonthTrend trend;

  @override
  Widget build(BuildContext context) {
    final finance = context.finance;
    final positive = trend.balance >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.monthYear(trend.month),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  Formatters.currency(trend.balance),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: positive ? finance.income : finance.expense,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _Chip(
                  label: 'Ingresos',
                  value: trend.income,
                  color: finance.income,
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: 'Gastos',
                  value: trend.expense,
                  color: finance.expense,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              Formatters.currency(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
