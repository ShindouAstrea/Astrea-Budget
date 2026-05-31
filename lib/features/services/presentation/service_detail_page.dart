import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/brand_illustration.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-service-payment',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _RegisterPaymentSheet(service: service),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Registrar pago'),
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
                  illustration: BrandEmptyArt(EmptyArt.history),
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

/// Hoja inferior para registrar un pago/vencimiento de un servicio. Útil sobre
/// todo para servicios esporádicos (los fijos generan su pago automáticamente).
class _RegisterPaymentSheet extends ConsumerStatefulWidget {
  const _RegisterPaymentSheet({required this.service});
  final Service service;

  @override
  ConsumerState<_RegisterPaymentSheet> createState() =>
      _RegisterPaymentSheetState();
}

class _RegisterPaymentSheetState extends ConsumerState<_RegisterPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late DateTime _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.service.estimatedAmount.toInt().toString(),
    );
    _dueDate = DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(paymentActionsProvider).createPayment(
            serviceId: widget.service.id,
            dueDate: _dueDate,
            amount: Formatters.parseAmount(_amount.text)!,
          );
      if (mounted) {
        context.showSuccess('Vencimiento registrado');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo registrar el pago');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Registrar pago',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4),
              leading: const Icon(Icons.event_outlined),
              title: const Text('Fecha de vencimiento'),
              subtitle: Text(Formatters.dayMonthYear(_dueDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
