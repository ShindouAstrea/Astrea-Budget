import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../domain/service.dart';
import 'services_controller.dart';

/// Formulario de creación/edición de servicio.
class ServiceFormPage extends ConsumerStatefulWidget {
  const ServiceFormPage({super.key, this.existing});
  final Service? existing;

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _billingDay;
  late ServiceType _type;
  late ServiceCategory _category;
  late ServiceFrequency _frequency;
  late bool _active;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _amount = TextEditingController(
      text: s != null ? s.estimatedAmount.toInt().toString() : '',
    );
    _billingDay = TextEditingController(text: s?.billingDay?.toString() ?? '');
    _type = s?.type ?? ServiceType.fijo;
    _category = s?.category ?? ServiceCategory.esencial;
    _frequency = s?.frequency ?? ServiceFrequency.mensual;
    _active = s?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _billingDay.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Validators.amount(_amount.text) == null
        ? int.parse(_amount.text)
        : 0;
    final billingDay =
        _type == ServiceType.fijo && _billingDay.text.trim().isNotEmpty
            ? int.tryParse(_billingDay.text.trim())
            : null;

    setState(() => _saving = true);
    final notifier = ref.read(servicesProvider.notifier);
    try {
      if (_isEditing) {
        await notifier.edit(
          widget.existing!.id,
          name: _name.text.trim(),
          type: _type,
          category: _category,
          estimatedAmount: amount,
          billingDay: billingDay,
          frequency: _frequency,
          active: _active,
        );
      } else {
        await notifier.add(
          name: _name.text.trim(),
          type: _type,
          category: _category,
          estimatedAmount: amount,
          billingDay: billingDay,
          frequency: _frequency,
        );
      }
      // Refresca los pagos del mes (pueden generarse nuevos).
      ref.invalidate(monthlyPaymentsProvider);
      if (mounted) {
        context.showSuccess('Servicio guardado');
        context.pop();
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar el servicio');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: const Text(
          'Se eliminarán también sus pagos asociados. Esta acción no se puede '
          'deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(servicesProvider.notifier).remove(widget.existing!.id);
    ref.invalidate(monthlyPaymentsProvider);
    if (mounted) {
      context.showSuccess('Servicio eliminado');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFixed = _type == ServiceType.fijo;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar servicio' : 'Nuevo servicio'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del servicio',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => Validators.required(v, field: 'El nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto estimado',
                prefixText: r'$ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),
            Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ServiceType>(
              segments: const [
                ButtonSegment(value: ServiceType.fijo, label: Text('Fijo')),
                ButtonSegment(
                    value: ServiceType.esporadico, label: Text('Esporádico')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            Text('Categoría', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ServiceCategory>(
              segments: const [
                ButtonSegment(
                    value: ServiceCategory.esencial, label: Text('Esencial')),
                ButtonSegment(
                    value: ServiceCategory.suscripcion,
                    label: Text('Suscripción')),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
            const SizedBox(height: 16),
            // Para servicios fijos: día de cobro + frecuencia.
            if (isFixed) ...[
              TextFormField(
                controller: _billingDay,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Día de cobro (1–31)',
                  helperText:
                      'Se generará automáticamente el pago de cada mes.',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                validator: Validators.billingDay,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: [
                  for (final f in ServiceFrequency.values)
                    DropdownMenuItem(value: f, child: Text(f.label)),
                ],
                onChanged: (v) =>
                    setState(() => _frequency = v ?? ServiceFrequency.mensual),
              ),
              const SizedBox(height: 16),
            ],
            if (_isEditing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Servicio activo'),
                subtitle: const Text(
                  'Los servicios inactivos no generan pagos.',
                ),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(_isEditing ? 'Guardar cambios' : 'Crear servicio'),
            ),
          ],
        ),
      ),
    );
  }
}
