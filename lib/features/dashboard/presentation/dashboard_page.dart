import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/month_selector.dart';
import '../../../core/widgets/state_views.dart';
import '../../services/domain/service_payment.dart';
import '../../services/presentation/services_controller.dart';
import '../../transactions/presentation/transactions_controller.dart';
import 'dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Astrea Budget'),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(AppRoute.settings.name),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthSummaryProvider);
          ref.invalidate(monthlyPaymentsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            const MonthSelector(),
            const SizedBox(height: 8),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorStateView(
                message: 'No pudimos cargar el resumen del mes.',
                onRetry: () => ref.invalidate(monthlyTransactionsProvider),
              ),
              data: (summary) => _SummarySection(summary: summary),
            ),
            const SizedBox(height: 24),
            const _UpcomingPaymentsSection(),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final finance = context.finance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Balance destacado
        _BalanceCard(balance: summary.balance),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TotalCard(
                label: 'Ingresos',
                amount: summary.income,
                color: finance.income,
                icon: Icons.south_west,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TotalCard(
                label: 'Gastos',
                amount: summary.expense,
                color: finance.expense,
                icon: Icons.north_east,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Gasto por categoría',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _CategoryChart(spending: summary.byCategory),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final positive = balance >= 0;
    return Card(
      color: scheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance del mes',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.currency(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  positive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  positive ? 'Vas en positivo' : 'Gastaste más de lo que ingresó',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              Formatters.currency(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.spending});
  final List<CategorySpending> spending;

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Text('Aún no hay gastos este mes'),
          ),
        ),
      );
    }

    final total = spending.fold<double>(0, (s, e) => s + e.amount);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  sections: [
                    for (var i = 0; i < spending.length; i++)
                      PieChartSectionData(
                        value: spending[i].amount,
                        color: spending[i].category?.colorValue ??
                            AppColors.chartPalette[i % AppColors.chartPalette.length],
                        radius: 22,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < spending.length && i < 5; i++)
                    _LegendRow(
                      color: spending[i].category?.colorValue ??
                          AppColors.chartPalette[i % AppColors.chartPalette.length],
                      label: spending[i].label,
                      percent: total == 0 ? 0 : spending[i].amount / total,
                      amount: spending[i].amount,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.percent,
    required this.amount,
  });

  final Color color;
  final String label;
  final double percent;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '${(percent * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Sección "Próximos pagos": servicios pendientes del mes.
class _UpcomingPaymentsSection extends ConsumerWidget {
  const _UpcomingPaymentsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(monthlyPaymentsProvider);
    final servicesById = {
      for (final s in ref.watch(servicesProvider).valueOrNull ?? []) s.id: s,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos pagos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () => context.goNamed(AppRoute.services.name),
              child: const Text('Ver servicios'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        paymentsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ErrorStateView(
            message: 'No pudimos cargar los pagos.',
            onRetry: () => ref.invalidate(monthlyPaymentsProvider),
          ),
          data: (payments) {
            final pending =
                payments.where((p) => !p.isPaid).toList();
            if (pending.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('¡No tienes pagos pendientes este mes!'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final p in pending)
                  _PaymentTile(
                    payment: p,
                    serviceName:
                        servicesById[p.serviceId]?.name ?? 'Servicio',
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment, required this.serviceName});

  final ServicePayment payment;
  final String serviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: payment.isOverdue
              ? scheme.errorContainer
              : scheme.primaryContainer,
          child: Icon(
            payment.isOverdue ? Icons.warning_amber : Icons.event_outlined,
            color: payment.isOverdue ? scheme.error : scheme.primary,
          ),
        ),
        title: Text(serviceName),
        subtitle: Text(
          '${Formatters.dayMonthYear(payment.dueDate)} · '
          '${Formatters.currency(payment.amount)}',
        ),
        trailing: FilledButton.tonal(
          onPressed: () async {
            await ref
                .read(paymentActionsProvider)
                .markAsPaid(payment);
            if (context.mounted) context.showSuccess('Pago registrado');
          },
          child: const Text('Pagar'),
        ),
      ),
    );
  }
}
