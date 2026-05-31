import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/service.dart';
import '../domain/service_payment.dart';
import 'services_controller.dart';

class ServiceDetailPage extends ConsumerWidget {
  const ServiceDetailPage({super.key, required this.service});

  final Service service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(servicePaymentsProvider(service.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(
              AppRoute.serviceForm.name,
              extra: service,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _InfoCard(service: service),
          const SizedBox(height: 24),
          Text(
            'Historial de pagos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ErrorStateView(
              message: 'No pudimos cargar el historial.',
              onRetry: () =>
                  ref.invalidate(servicePaymentsProvider(service.id)),
            ),
            data: (payments) {
              if (payments.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.history,
                  title: 'Sin pagos registrados',
                  message: 'Los pagos del mes aparecerán aquí.',
                );
              }
              return Column(
                children: [
                  for (final p in payments) _PaymentRow(payment: p),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(context, 'Tipo', service.type.label),
            _row(context, 'Categoría', service.category.label),
            _row(context, 'Monto estimado',
                Formatters.currency(service.estimatedAmount)),
            if (service.isFixed && service.billingDay != null)
              _row(context, 'Día de cobro', 'Día ${service.billingDay}'),
            _row(context, 'Frecuencia', service.frequency.label),
            _row(context, 'Estado', service.active ? 'Activo' : 'Inactivo'),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.payment});
  final ServicePayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final paid = payment.isPaid;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              paid ? Colors.green.withValues(alpha: 0.15) : scheme.errorContainer,
          child: Icon(
            paid ? Icons.check : Icons.schedule,
            color: paid ? Colors.green.shade700 : scheme.error,
          ),
        ),
        title: Text(Formatters.currency(payment.amount)),
        subtitle: Text(
          paid && payment.paidDate != null
              ? 'Pagado el ${Formatters.dayMonthYear(payment.paidDate!)}'
              : 'Vence el ${Formatters.dayMonthYear(payment.dueDate)}',
        ),
        trailing: paid
            ? TextButton(
                onPressed: () =>
                    ref.read(paymentActionsProvider).markAsPending(payment),
                child: const Text('Revertir'),
              )
            : FilledButton.tonal(
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
