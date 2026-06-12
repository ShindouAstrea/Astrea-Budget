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
import '../../accounts/presentation/accounts_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../budgets/presentation/budgets_controller.dart';
import '../../categories/presentation/categories_controller.dart';
import '../domain/installments.dart';
import '../domain/transaction.dart';
import 'transactions_controller.dart';

/// Qué eliminar cuando la transacción pertenece a una compra en cuotas.
enum _DeleteChoice { single, group }

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
  String? _accountId;
  bool _saving = false;

  /// Nº de cuotas (1 = sin cuotas). Sólo para gastos nuevos en cuenta de crédito.
  int _installments = 1;
  static const _installmentOptions = [1, 2, 3, 6, 12, 18, 24, 36];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.expense;
    _date = e?.date ?? DateTime.now();
    _categoryId = e?.categoryId;
    _accountId = e?.accountId;
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

  /// Cuenta efectiva para el movimiento (la elegida, si no la activa, si no la
  /// primera). Refleja la misma resolución que muestra el dropdown.
  String? get _selectedAccountId {
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    return _accountId ??
        ref.read(activeAccountProvider).valueOrNull?.id ??
        (accounts.isNotEmpty ? accounts.first.id : null);
  }

  /// Las cuotas aplican sólo al crear un gasto pagado con tarjeta de crédito.
  bool get _installmentsApply {
    if (_isEditing || _type != TransactionType.expense) return false;
    final accounts = ref.read(accountsProvider).valueOrNull ?? const [];
    final selectedId = _selectedAccountId;
    for (final a in accounts) {
      if (a.id == selectedId) return a.type.isCredit;
    }
    return false;
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

  /// Si este gasto supera el tope de su categoría, devuelve cuánto se pasa y el
  /// nombre de la categoría; si no hay tope o no se pasa, `null`.
  ({double over, String name})? _budgetOverInfo(int amount) {
    if (_type != TransactionType.expense || _categoryId == null) return null;
    final statuses = ref.read(budgetStatusesProvider).valueOrNull ?? const [];
    BudgetStatus? status;
    for (final s in statuses) {
      if (s.category.id == _categoryId) {
        status = s;
        break;
      }
    }
    if (status == null || !status.hasBudget) return null;
    // Al editar un gasto ya contado en el mes, descontamos su aporte previo.
    final prior = (_isEditing &&
            widget.existing!.categoryId == _categoryId &&
            !widget.existing!.isIncome)
        ? widget.existing!.amount
        : 0.0;
    final projected = (status.spent - prior) + amount;
    if (projected <= status.limit) return null;
    return (over: projected - status.limit, name: status.category.name);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Formatters.parseAmount(_amount.text)!;

    // Aviso si el gasto supera el tope de su categoría. En cuotas, lo que
    // impacta este mes es la primera cuota, no el total.
    final monthlyImpact = _installmentsApply && _installments > 1
        ? splitInstallments(amount, _installments).first
        : amount;
    final overInfo = _budgetOverInfo(monthlyImpact);
    if (overInfo != null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.warning_amber_rounded,
              color: Theme.of(ctx).colorScheme.error),
          title: const Text('Te pasas del tope'),
          content: Text(
            'Con esta transacción superas el tope de ${overInfo.name} por '
            '${Formatters.currency(overInfo.over)}. ¿Registrarla igual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Registrar igual'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

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
          accountId: _accountId,
        );
      } else if (_installmentsApply && _installments > 1) {
        await actions.createInstallments(
          totalAmount: amount,
          count: _installments,
          firstDate: _date,
          description: _description.text.trim(),
          categoryId: _categoryId,
          accountId: _accountId,
        );
      } else {
        await actions.create(
          type: _type,
          amount: amount,
          date: _date,
          description: _description.text.trim(),
          categoryId: _categoryId,
          accountId: _accountId,
        );
      }
      if (mounted) {
        context.showSuccess(
          _isEditing
              ? 'Transacción actualizada'
              : (_installmentsApply && _installments > 1
                  ? 'Compra en $_installments cuotas creada'
                  : 'Transacción creada'),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar la transacción');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing!;

    // En una compra en cuotas se puede borrar sólo esta cuota o el grupo.
    if (existing.isInstallment) {
      final choice = await showDialog<_DeleteChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar compra en cuotas'),
          content: Text(
            'Esta es la ${existing.installmentLabel} de una compra en '
            '${existing.installmentsTotal} cuotas. ¿Qué quieres eliminar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _DeleteChoice.single),
              child: const Text('Sólo esta cuota'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _DeleteChoice.group),
              child: const Text('Todas las cuotas'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      final actions = ref.read(transactionActionsProvider);
      if (choice == _DeleteChoice.group) {
        await actions.deleteInstallmentGroup(existing.installmentGroupId!);
      } else {
        await actions.delete(existing.id);
      }
      if (mounted) {
        context.showSuccess(
          choice == _DeleteChoice.group
              ? 'Compra en cuotas eliminada'
              : 'Cuota eliminada',
        );
        context.pop();
      }
      return;
    }

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
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final activeAccountId = ref.watch(activeAccountProvider).valueOrNull?.id;
    final finance = context.finance;

    // Si la categoría seleccionada ya no pertenece al tipo, la limpiamos.
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    // Cuenta efectiva mostrada: la elegida, si no la activa, si no la primera.
    final selectedAccountId = _accountId ??
        activeAccountId ??
        (accounts.isNotEmpty ? accounts.first.id : null);

    // Sólo el autor puede eliminar (RLS Nivel A). Refuerzo defensivo: el listado
    // ya impide abrir el form de un movimiento ajeno.
    final myId = ref.watch(currentUserProvider)?.id;
    final isMine = !_isEditing || widget.existing!.userId == myId;

    // Aviso en vivo si el gasto actual supera el tope de su categoría.
    ref.watch(budgetStatusesProvider); // se redibuja cuando cargan los topes
    final parsedAmount = Formatters.parseAmount(_amount.text) ?? 0;
    // Con cuotas, lo que impacta el mes es la primera cuota, no el total.
    final monthlyImpact = _installmentsApply && _installments > 1
        ? splitInstallments(parsedAmount, _installments).first
        : parsedAmount;
    final overInfo = monthlyImpact > 0 ? _budgetOverInfo(monthlyImpact) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar transacción' : 'Nueva transacción'),
        actions: [
          if (_isEditing && isMine)
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
              // Recalcula el aviso de tope en vivo mientras se escribe.
              onChanged: (_) => setState(() {}),
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
            if (accounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Cuenta',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  for (final a in accounts)
                    DropdownMenuItem(
                      value: a.id,
                      child: Row(
                        children: [
                          Icon(a.iconData, size: 18, color: a.colorValue),
                          const SizedBox(width: 8),
                          Text(a.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _accountId = v),
              ),
            ],
            if (_installmentsApply) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _installments,
                decoration: const InputDecoration(
                  labelText: 'Cuotas',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                items: [
                  for (final n in _installmentOptions)
                    DropdownMenuItem(
                      value: n,
                      child: Text(n == 1 ? 'Sin cuotas' : '$n cuotas'),
                    ),
                ],
                onChanged: (v) => setState(() => _installments = v ?? 1),
              ),
              if (_installments > 1 && parsedAmount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$_installments cuotas mensuales de '
                  '${Formatters.currency(splitInstallments(parsedAmount, _installments).first)} '
                  'desde ${Formatters.dayMonthYear(_date)}.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
            if (widget.existing?.isInstallment == true) ...[
              const SizedBox(height: 16),
              Text(
                'Esta transacción es la ${widget.existing!.installmentLabel} '
                'de una compra en cuotas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (overInfo != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Te pasas del tope de ${overInfo.name} por '
                        '${Formatters.currency(overInfo.over)}.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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