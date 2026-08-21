import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/service_payment.dart';
import 'services_controller.dart';

/// Hoja para ajustar el monto de UN período de un servicio fijo: la suscripción
/// subió, la boleta de luz llegó más alta, etc. Sólo cambia ese pago; el monto
/// estimado del servicio (y por lo tanto los meses siguientes) queda igual.
class PaymentAmountSheet extends ConsumerStatefulWidget {
  const PaymentAmountSheet({
    super.key,
    required this.payment,
    required this.serviceName,
  });

  final ServicePayment payment;
  final String serviceName;

  /// Abre la hoja centralizando el estilo (drag handle + teclado).
  static Future<void> show(
    BuildContext context, {
    required ServicePayment payment,
    required String serviceName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PaymentAmountSheet(
        payment: payment,
        serviceName: serviceName,
      ),
    );
  }

  @override
  ConsumerState<PaymentAmountSheet> createState() => _PaymentAmountSheetState();
}

class _PaymentAmountSheetState extends ConsumerState<PaymentAmountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  bool _saving = false;

  ServicePayment get _payment => widget.payment;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: _payment.amount.round().toString());
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool alsoPay}) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Formatters.parseAmount(_amount.text)!;
    setState(() => _saving = true);
    try {
      final actions = ref.read(paymentActionsProvider);
      if (alsoPay) {
        await actions.markAsPaid(_payment, amount: amount);
      } else {
        await actions.updateAmount(_payment, amount);
      }
      if (!mounted) return;
      context.showSuccess(alsoPay ? 'Pago registrado' : 'Monto actualizado');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) context.showError('No se pudo actualizar el monto');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = !_payment.isPaid;
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
            Text('Ajustar monto', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.serviceName} · vence el '
              '${Formatters.dayMonthYear(_payment.dueDate)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto de este período',
                prefixText: r'$ ',
                prefixIcon: Icon(Icons.payments_outlined),
                helperText: 'Sólo cambia este mes; el monto estimado del '
                    'servicio no se modifica.',
                helperMaxLines: 3,
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),
            if (_saving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              FilledButton(
                onPressed: () => _submit(alsoPay: false),
                child: const Text('Guardar monto'),
              ),
              if (pending) ...[
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _submit(alsoPay: true),
                  child: const Text('Guardar y marcar pagado'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
