import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
// AppColors provee la extensión context.finance (income/expense).
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../categories/presentation/categories_controller.dart';
import '../domain/transaction.dart';
import 'transactions_controller.dart';

/// Formulario de creación/edición de transacción. Si [existing] no es null,
/// edita; si es null, crea.
class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key, this.existing});

  final TransactionModel? existing;

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late TransactionType _type;
  late DateTime _date;
  String? _categoryId;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.expense;
    _date = e?.date ?? DateTime.now();
    _categoryId = e?.categoryId;
    _amount = TextEditingController(
      text: e != null ? e.amount.toInt().toString() : '',
    );
    _description = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Formatters.parseAmount(_amount.text)!;
    setState(() => _saving = true);
    final actions = ref.read(transactionActionsProvider);
    try {
      if (_isEditing) {
        await actions.update(
          id: widget.existing!.id,
          type: _type,
          amount: amount,
          date: _date,
          description: _description.text.trim(),
          categoryId: _categoryId,
        );
      } else {
        await actions.create(
          type: _type,
          amount: amount,
          date: _date,
          description: _description.text.trim(),
          categoryId: _categoryId,
        );
      }
      if (mounted) {
        context.showSuccess(_isEditing ? 'Transacción actualizada' : 'Transacción creada');
        context.pop();
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar la transacción');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('Esta acción no se puede deshacer.'),
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
    await ref.read(transactionActionsProvider).delete(widget.existing!.id);
    if (mounted) {
      context.showSuccess('Transacción eliminada');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(_type));
    final finance = context.finance;

    // Si la categoría seleccionada ya no pertenece al tipo, la limpiamos.
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar transacción' : 'Nueva transacción'),
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
            // Selector de tipo
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: const Text('Gasto'),
                  icon: Icon(Icons.north_east, color: finance.expense),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: const Text('Ingreso'),
                  icon: Icon(Icons.south_west, color: finance.income),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.headlineSmall,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
              ),
              validator: Validators.amount,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(c.iconData, size: 18, color: c.colorValue),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
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
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha'),
              subtitle: Text(Formatters.dayMonthYear(_date)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
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
                  : Text(_isEditing ? 'Guardar cambios' : 'Crear transacción'),
            ),
          ],
        ),
      ),
    );
  }
}