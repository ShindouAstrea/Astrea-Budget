import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';
import '../../../core/config/supabase_provider.dart';
import '../../../core/data/local_cache.dart';
import '../../../shared/enums.dart';
import '../../households/presentation/household_controller.dart';
import '../../transactions/presentation/transactions_controller.dart';
import '../data/account_repository.dart';
import '../domain/account.dart';

/// Cuentas del household activo (no archivadas). Con caché offline.
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final repo = ref.watch(accountRepositoryProvider);
  return ref.watch(localCacheProvider).fetchList(
        key: 'accounts:$householdId',
        fetch: () => repo.fetchByHousehold(householdId),
        toJson: (a) => a.toJson(),
        fromJson: Account.fromJson,
      );
});

/// Saldos calculados por cuenta del household activo: `{accountId: balance}`.
/// Con caché offline.
final accountBalancesProvider = FutureProvider<Map<String, double>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final repo = ref.watch(accountRepositoryProvider);
  return ref.watch(localCacheProvider).fetchDoubleMap(
        key: 'balances:$householdId',
        fetch: () => repo.fetchBalances(householdId),
      );
});

/// Cuenta seleccionada por defecto para nuevos movimientos, persistida por
/// usuario (clave `current_account_<uid>`).
class CurrentAccountId extends Notifier<String?> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  String? get _key {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    return uid == null ? null : 'current_account_$uid';
  }

  @override
  String? build() {
    final key = _key;
    return key == null ? null : _prefs.getString(key);
  }

  Future<void> set(String id) async {
    state = id;
    final key = _key;
    if (key != null) await _prefs.setString(key, id);
  }
}

final currentAccountIdProvider =
    NotifierProvider<CurrentAccountId, String?>(CurrentAccountId.new);

/// Cuenta activa resuelta para nuevos movimientos: la seleccionada si pertenece
/// al household activo, si no la primera disponible (o `null` si no hay cuentas).
final activeAccountProvider = FutureProvider<Account?>((ref) async {
  final accounts = await ref.watch(accountsProvider.future);
  if (accounts.isEmpty) return null;
  final selectedId = ref.watch(currentAccountIdProvider);
  return accounts.firstWhere(
    (a) => a.id == selectedId,
    orElse: () => accounts.first,
  );
});

/// Acciones CRUD + transferencia sobre cuentas. Sólo el `owner` del household
/// puede crear/editar/archivar (lo garantiza RLS); la UI lo refleja.
class AccountActions {
  AccountActions(this.ref);
  final Ref ref;

  Future<void> create({
    required String name,
    required AccountType type,
    required int initialBalance,
    int? creditLimit,
    int? statementDay,
    int? paymentDueDay,
    required String color,
    required String icon,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(accountRepositoryProvider).create(
          householdId: householdId,
          name: name,
          type: type,
          initialBalance: initialBalance,
          creditLimit: creditLimit,
          statementDay: statementDay,
          paymentDueDay: paymentDueDay,
          color: color,
          icon: icon,
        );
    _refresh();
  }

  Future<void> update(Account account) async {
    await ref.read(accountRepositoryProvider).update(account);
    _refresh();
  }

  Future<void> archive(String id) async {
    await ref.read(accountRepositoryProvider).archive(id);
    _refresh();
  }

  Future<void> transfer({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required DateTime date,
    String? description,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(accountRepositoryProvider).transfer(
          householdId: householdId,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          date: date,
          description: description,
        );
    _refresh();
    // La transferencia crea transacciones; refresca el listado del mes.
    ref.invalidate(monthlyTransactionsProvider);
  }

  void _refresh() {
    ref.invalidate(accountsProvider);
    ref.invalidate(accountBalancesProvider);
  }
}

final accountActionsProvider = Provider<AccountActions>(AccountActions.new);
