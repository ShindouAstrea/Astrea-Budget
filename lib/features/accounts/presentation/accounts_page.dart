import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../households/presentation/household_controller.dart';
import '../../onboarding/presentation/feature_tour.dart';
import '../../onboarding/presentation/feature_tours.dart';
import '../domain/account.dart';
import 'accounts_controller.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final balances = ref.watch(accountBalancesProvider).valueOrNull ?? const {};
    final isOwner = ref.watch(isActiveHouseholdOwnerProvider).valueOrNull ?? false;
    final accounts = accountsAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
        actions: [
          const FeatureTourButton(tour: accountsTour),
          if (accounts.length >= 2)
            IconButton(
              onPressed: () => _openTransfer(context, ref, accounts),
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Transferir',
            ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              heroTag: 'fab-accounts',
              onPressed: () => _openForm(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar las cuentas.',
          onRetry: () => ref.invalidate(accountsProvider),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Sin cuentas',
              message: 'Crea tu primera cuenta con el botón +.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final a in accounts)
                _AccountCard(
                  account: a,
                  balance: balances[a.id] ?? a.initialBalance,
                  onTap:
                      isOwner ? () => _openForm(context, ref, account: a) : null,
                ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, {Account? account}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AccountFormSheet(account: account),
    );
  }

  void _openTransfer(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TransferSheet(accounts: accounts),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.balance,
    this.onTap,
  });

  final Account account;
  final double balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final available =
        account.isCredit ? (account.creditLimit ?? 0) + balance : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: account.colorValue.withValues(alpha: 0.18),
          child: Icon(account.iconData, color: account.colorValue),
        ),
        title: Text(account.name),
        subtitle: Text(
          account.isCredit
              ? '${account.type.label} · Cupo disponible '
                  '${Formatters.currency(available!)}'
              : account.type.label,
        ),
        trailing: Text(
          Formatters.currency(balance),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: balance < 0 ? scheme.error : scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

/// Hoja inferior para crear/editar una cuenta.
class _AccountFormSheet extends ConsumerStatefulWidget {
  const _AccountFormSheet({this.account});
  final Account? account;

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _initialBalance;
  late final TextEditingController _creditLimit;
  late AccountType _type;
  late String _color;
  late String _icon;
  int? _statementDay;
  int? _paymentDueDay;
  bool _saving = false;

  bool get _isEditing => widget.account != null;
  bool get _isCredit => _type.isCredit;

  static const _palette = [
    '#2563EB', '#16A34A', '#DC2626', '#F97316',
    '#8B5CF6', '#14B8A6', '#EAB308', '#EC4899',
    '#0EA5E9', '#64748B',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _name = TextEditingController(text: a?.name ?? '');
    _initialBalance = TextEditingController(
      text: a != null ? a.initialBalance.toInt().toString() : '',
    );
    _creditLimit = TextEditingController(
      text: a?.creditLimit != null ? a!.creditLimit!.toInt().toString() : '',
    );
    _type = a?.type ?? AccountType.debito;
    _color = a?.color ?? _palette.first;
    _icon = a?.icon ?? 'account_balance_wallet';
    _statementDay = a?.statementDay;
    _paymentDueDay = a?.paymentDueDay;
  }

  @override
  void dispose() {
    _name.dispose();
    _initialBalance.dispose();
    _creditLimit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final actions = ref.read(accountActionsProvider);
    final initial = int.tryParse(_initialBalance.text) ?? 0;
    final limit = _isCredit ? int.tryParse(_creditLimit.text) : null;
    try {
      if (_isEditing) {
        await actions.update(widget.account!.copyWith(
          name: _name.text.trim(),
          type: _type,
          initialBalance: initial.toDouble(),
          creditLimit: limit?.toDouble(),
          statementDay: _isCredit ? _statementDay : null,
          paymentDueDay: _isCredit ? _paymentDueDay : null,
          color: _color,
          icon: _icon,
        ));
      } else {
        await actions.create(
          name: _name.text.trim(),
          type: _type,
          initialBalance: initial,
          creditLimit: limit,
          statementDay: _isCredit ? _statementDay : null,
          paymentDueDay: _isCredit ? _paymentDueDay : null,
          color: _color,
          icon: _icon,
        );
      }
      if (mounted) {
        context.showSuccess('Cuenta guardada');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo guardar la cuenta');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _archive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archivar cuenta'),
        content: const Text(
          'La cuenta dejará de aparecer, pero sus movimientos se conservan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(accountActionsProvider).archive(widget.account!.id);
    if (mounted) {
      context.showSuccess('Cuenta archivada');
      Navigator.pop(context);
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
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              _isEditing ? 'Editar cuenta' : 'Nueva cuenta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => Validators.required(v, field: 'El nombre'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              items: [
                for (final t in AccountType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialBalance,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: _isCredit ? 'Saldo inicial (deuda)' : 'Saldo inicial',
                prefixText: r'$ ',
                helperText: _isCredit
                    ? 'Si tienes deuda, ingrésala como negativa más adelante.'
                    : null,
              ),
            ),
            if (_isCredit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditLimit,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Cupo total',
                  prefixText: r'$ ',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
              ),
              const SizedBox(height: 16),
              _DayPicker(
                label: 'Día de cierre (facturación)',
                value: _statementDay,
                onChanged: (v) => setState(() => _statementDay = v),
              ),
              const SizedBox(height: 12),
              _DayPicker(
                label: 'Día de pago',
                value: _paymentDueDay,
                onChanged: (v) => setState(() => _paymentDueDay = v),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.fromHex(hex),
                        shape: BoxShape.circle,
                        border: _color == hex
                            ? Border.all(
                                width: 3,
                                color: Theme.of(context).colorScheme.onSurface)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ícono', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in kAccountIcons.entries)
                  GestureDetector(
                    onTap: () => setState(() => _icon = entry.key),
                    child: CircleAvatar(
                      backgroundColor: _icon == entry.key
                          ? AppColors.fromHex(_color)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        entry.value,
                        color: _icon == entry.key
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Guardar' : 'Crear'),
            ),
            if (_isEditing)
              TextButton(
                onPressed: _saving ? null : _archive,
                child: Text(
                  'Archivar cuenta',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selector de día del mes (1..28) para cierre/pago de tarjetas de crédito.
class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_outlined),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Sin definir')),
        for (var d = 1; d <= 28; d++)
          DropdownMenuItem(value: d, child: Text('Día $d')),
      ],
      onChanged: onChanged,
    );
  }
}

/// Hoja inferior para transferir entre cuentas.
class _TransferSheet extends ConsumerStatefulWidget {
  const _TransferSheet({required this.accounts});
  final List<Account> accounts;

  @override
  ConsumerState<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<_TransferSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late String _fromId;
  late String _toId;
  final DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _description = TextEditingController();
    _fromId = widget.accounts.first.id;
    _toId = widget.accounts[1].id;
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromId == _toId) {
      context.showError('Elige cuentas distintas');
      return;
    }
    final amount = Formatters.parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      context.showError('Ingresa un monto válido');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(accountActionsProvider).transfer(
            fromAccountId: _fromId,
            toAccountId: _toId,
            amount: amount,
            date: _date,
            description: _description.text.trim().isEmpty
                ? 'Transferencia'
                : _description.text.trim(),
          );
      if (mounted) {
        context.showSuccess('Transferencia realizada');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo transferir');
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
            Text('Transferir', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _fromId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Desde',
                prefixIcon: Icon(Icons.upload_outlined),
              ),
              items: [
                for (final a in widget.accounts)
                  DropdownMenuItem(value: a.id, child: Text(a.name)),
              ],
              onChanged: (v) => setState(() => _fromId = v ?? _fromId),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _toId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Hacia',
                prefixIcon: Icon(Icons.download_outlined),
              ),
              items: [
                for (final a in widget.accounts)
                  DropdownMenuItem(value: a.id, child: Text(a.name)),
              ],
              onChanged: (v) => setState(() => _toId = v ?? _toId),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: r'$ ',
              ),
              validator: Validators.amount,
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
                  : const Text('Transferir'),
            ),
          ],
        ),
      ),
    );
  }
}
