import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../data/service_repository.dart';
import '../domain/service.dart';
import '../domain/service_payment.dart';
import 'services_controller.dart';

/// Hoja del pago de UN período de un servicio.
///
/// Permite dos cosas que antes no se podían:
/// - **ajustar el monto de ese mes** (la suscripción subió, la boleta llegó más
///   alta) sin tocar el monto estimado del servicio ni los meses siguientes;
/// - **elegir la fecha del pago**, para que el gasto quede en el mes que
///   corresponde y no siempre en el día de hoy.
class PaymentAmountSheet extends ConsumerStatefulWidget {
  const PaymentAmountSheet({
    super.key,
    required this.payment,
    required this.serviceName,
    this.service,
  });

  final ServicePayment payment;
  final String serviceName;

  /// Servicio del pago, si la lista ya está cargada: permite ofrecer subir el
  /// monto estimado cuando el cobro cambió de forma permanente.
  final Service? service;

  /// Abre la hoja centralizando el estilo (drag handle + teclado).
  static Future<void> show(
    BuildContext context, {
    required ServicePayment payment,
    required String serviceName,
    Service? service,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PaymentAmountSheet(
        payment: payment,
        serviceName: serviceName,
        service: service,
      ),
    );
  }

  @override
  ConsumerState<PaymentAmountSheet> createState() => _PaymentAmountSheetState();
}

class _PaymentAmountSheetState extends ConsumerState<PaymentAmountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late DateTime _paidDate;
  bool _saving = false;
  /// ¿Además de este mes, dejar el monto nuevo como estimado del servicio?
  bool _updateEstimate = false;

  ServicePayment get _payment => widget.payment;
  bool get _pending => !_payment.isPaid;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: _payment.amount.round().toString());
    // El bloque de "subió de precio" aparece/desaparece según lo que se teclee.
    _amount.addListener(() => setState(() {}));
    _paidDate = _defaultPaidDate();
  }

  /// Hoy, salvo que el pago sea de otro mes: ahí se propone su vencimiento, que
  /// es lo que casi siempre se quiere al ponerse al día con un mes pasado.
  DateTime _defaultPaidDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = _payment.dueDate;
    final sameMonth = due.year == today.year && due.month == today.month;
    return sameMonth ? today : due;
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
      helpText: 'Fecha del pago',
    );
    if (picked != null) setState(() => _paidDate = picked);
  }

  Future<void> _submit({required bool alsoPay}) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Formatters.parseAmount(_amount.text)!;
    setState(() => _saving = true);
    try {
      final actions = ref.read(paymentActionsProvider);
      if (alsoPay) {
        await actions.markAsPaid(_payment, amount: amount, paidDate: _paidDate);
      } else {
        await actions.updateAmount(_payment, amount);
      }
      final service = widget.service;
      if (_updateEstimate && service != null) {
        await ref
            .read(servicesProvider.notifier)
            .updateEstimatedAmount(service.id, amount);
      }
      if (!mounted) return;
      context.showSuccess(alsoPay ? 'Pago registrado' : 'Monto actualizado');
      Navigator.pop(context);
    } on ServiceRepositoryException catch (e) {
      if (mounted) context.showError(e.message);
    } catch (_) {
      if (mounted) context.showError('No se pudo actualizar el monto');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              _pending ? 'Registrar pago' : 'Ajustar monto',
              style: theme.textTheme.titleLarge,
            ),
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
            _EstimateUpdate(
              service: widget.service,
              typed: Formatters.parseAmount(_amount.text),
              value: _updateEstimate,
              onChanged: (v) => setState(() => _updateEstimate = v),
            ),
            if (_pending) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Fecha del pago'),
                subtitle: Text(Formatters.dayMonthYear(_paidDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              Text(
                'El gasto se registra con esta fecha, así queda en el mes que '
                'corresponde.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            if (_saving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_pending) ...[
              FilledButton(
                onPressed: () => _submit(alsoPay: true),
                child: const Text('Marcar pagado'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _submit(alsoPay: false),
                child: const Text('Sólo guardar el monto'),
              ),
            ] else
              FilledButton(
                onPressed: () => _submit(alsoPay: false),
                child: const Text('Guardar monto'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Aviso de "subió de precio": aparece cuando el monto tecleado no coincide con
/// el estimado del servicio y ofrece dejarlo como nuevo estimado, que es el
/// paso que si no hay que hacer a mano entrando a editar el servicio.
class _EstimateUpdate extends StatelessWidget {
  const _EstimateUpdate({
    required this.service,
    required this.typed,
    required this.value,
    required this.onChanged,
  });

  final Service? service;
  final int? typed;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = service;
    if (s == null || typed == null) return const SizedBox.shrink();
    final estimated = s.estimatedAmount.round();
    if (typed == estimated) return const SizedBox.shrink();

    final subio = typed! > estimated;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          subio ? 'El servicio subió de precio' : 'El servicio bajó de precio',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Dejar ${Formatters.currency(typed!)} como monto estimado '
          '(hoy es ${Formatters.currency(estimated)}). Se aplica también a los '
          'meses ya generados que sigan pendientes.',
        ),
      ),
    );
  }
}
