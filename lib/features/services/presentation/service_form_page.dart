import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/month_selector.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_controller.dart';
import '../domain/service.dart';
import 'services_controller.dart';

/// Selector de la categoría de GASTO del servicio: la que llevará la
/// transacción al marcar el pago. Se alimenta de las categorías de gasto del
/// household; "Sin categoría" sigue siendo válido.
class _ExpenseCategoryField extends ConsumerWidget {
  const _ExpenseCategoryField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final expense = [for (final c in categories) if (!c.type.isIncome) c];
    // Si la categoría guardada ya no existe, el Dropdown fallaría: cae a null.
    final selected =
        expense.any((c) => c.id == value) ? value : null;

    return DropdownButtonFormField<String?>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Categoría de gasto',
        helperText: 'Con categoría, el pago cuenta en su presupuesto y en el '
            'gráfico del mes.',
        helperMaxLines: 3,
        prefixIcon: Icon(Icons.pie_chart_outline),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sin categoría')),
        for (final c in expense)
          DropdownMenuItem(
            value: c.id,
            child: Row(
              children: [
                Icon(c.iconData, size: 18, color: c.colorValue),
                const SizedBox(width: 8),
                Flexible(child: Text(c.name, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

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
  /// Mes del primer cobro: ancla del ciclo para frecuencias no mensuales.
  late DateTime _firstChargeMonth;
  /// Mes del último cobro (null = sin fecha de término).
  late DateTime? _lastChargeMonth;
  /// Categoría de gasto a la que se imputa el pago (null = sin categoría).
  late String? _expenseCategoryId;
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
    final now = DateTime.now();
    _firstChargeMonth = s?.firstChargeMonth ?? DateTime(now.year, now.month);
    _lastChargeMonth = s?.lastChargeMonth;
    _expenseCategoryId = s?.expenseCategoryId;
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
    final end = _lastChargeMonth;
    if (end != null && end.isBefore(_firstChargeMonth)) {
      context.showError('El último cobro no puede ser antes del primero');
      return;
    }
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
          firstChargeMonth: _firstChargeMonth,
          lastChargeMonth: _lastChargeMonth,
          expenseCategoryId: _expenseCategoryId,
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
          firstChargeMonth: _firstChargeMonth,
          lastChargeMonth: _lastChargeMonth,
          expenseCategoryId: _expenseCategoryId,
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

  /// Explica en palabras cuándo vuelve a cobrarse (ej. "cada 6 meses").
  String _cycleHint() {
    return switch (_frequency) {
      ServiceFrequency.mensual => 'todos los meses',
      ServiceFrequency.bimestral => 'cada 2 meses',
      ServiceFrequency.trimestral => 'cada 3 meses',
      ServiceFrequency.semestral => 'cada 6 meses',
      ServiceFrequency.anual => 'una vez al año',
      ServiceFrequency.unico => 'sólo esa vez',
    };
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
            // Categoría de gasto: sin ella, el pago no cuenta en el presupuesto
            // por categoría ni en el gráfico del dashboard.
            _ExpenseCategoryField(
              value: _expenseCategoryId,
              onChanged: (v) => setState(() => _expenseCategoryId = v),
            ),
            const SizedBox(height: 16),
            // Para servicios fijos: día de cobro + frecuencia.
            if (isFixed) ...[
              TextFormField(
                controller: _billingDay,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Día de cobro (1–31)',
                  helperText: _frequency.isMonthly
                      ? 'Se generará automáticamente el pago de cada mes.'
                      : 'Día del mes en que cae el cobro cuando toca.',
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.event_outlined),
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
              // Ancla del ciclo: sin ella no hay forma de saber en qué mes cae
              // el cobro de un servicio anual/semestral.
              if (_frequency.needsAnchor) ...[
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.today_outlined),
                  title: const Text('Mes del primer cobro'),
                  subtitle: Text(
                    '${Formatters.monthYear(_firstChargeMonth)} · '
                    '${_cycleHint()}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showMonthPicker(
                      context,
                      initial: _firstChargeMonth,
                    );
                    if (picked != null) {
                      setState(() => _firstChargeMonth = picked);
                    }
                  },
                ),
              ],
              // Suscripción cancelada que sigue corriendo: en vez de acordarse
              // de pausarla el mes exacto, el ciclo se apaga solo.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy_outlined),
                title: const Text('Último cobro (opcional)'),
                subtitle: Text(
                  _lastChargeMonth == null
                      ? 'Sin fecha de término: se cobra indefinidamente'
                      : 'Hasta ${Formatters.monthYear(_lastChargeMonth!)}',
                ),
                trailing: _lastChargeMonth == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Quitar término',
                        onPressed: () =>
                            setState(() => _lastChargeMonth = null),
                      ),
                onTap: () async {
                  final picked = await showMonthPicker(
                    context,
                    initial: _lastChargeMonth ?? _firstChargeMonth,
                  );
                  if (picked != null) {
                    setState(() => _lastChargeMonth = picked);
                  }
                },
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
