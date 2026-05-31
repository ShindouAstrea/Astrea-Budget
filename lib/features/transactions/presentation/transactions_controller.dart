import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/budget_cycle.dart';
import '../../../shared/enums.dart';
import '../../../shared/selected_month_provider.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';

/// Transacciones del mes financiero seleccionado (según el día de corte).
final monthlyTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final month = ref.watch(selectedMonthProvider);
  final cutoff = ref.watch(budgetCutoffProvider);
  final range = BudgetCycle.bounds(month, cutoff);
  return ref
      .watch(transactionRepositoryProvider)
      .fetchBetween(householdId, range.start, range.end);
});

/// Filtros activos del historial.
class TransactionFilters {
  const TransactionFilters({this.type, this.categoryId});

  final TransactionType? type;
  final String? categoryId;

  TransactionFilters copyWith({
    Object? type = _sentinel,
    Object? categoryId = _sentinel,
  }) {
    return TransactionFilters(
      type: type == _sentinel ? this.type : type as TransactionType?,
      categoryId:
          categoryId == _sentinel ? this.categoryId : categoryId as String?,
    );
  }

  bool get isActive => type != null || categoryId != null;

  static const _sentinel = Object();
}

class TransactionFiltersNotifier extends Notifier<TransactionFilters> {
  @override
  TransactionFilters build() => const TransactionFilters();

  void setType(TransactionType? type) =>
      state = state.copyWith(type: type);
  void setCategory(String? categoryId) =>
      state = state.copyWith(categoryId: categoryId);
  void clear() => state = const TransactionFilters();
}

final transactionFiltersProvider =
    NotifierProvider<TransactionFiltersNotifier, TransactionFilters>(
  TransactionFiltersNotifier.new,
);

/// Transacciones del mes ya filtradas según [transactionFiltersProvider].
final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final filters = ref.watch(transactionFiltersProvider);
  return ref.watch(monthlyTransactionsProvider).whenData((list) {
    return list.where((t) {
      if (filters.type != null && t.type != filters.type) return false;
      if (filters.categoryId != null && t.categoryId != filters.categoryId) {
        return false;
      }
      return true;
    }).toList();
  });
});

/// Acciones CRUD sobre transacciones. Invalida el listado del mes al terminar.
class TransactionActions {
  TransactionActions(this.ref);
  final Ref ref;

  Future<void> create({
    required TransactionType type,
    required int amount,
    required DateTime date,
    String? description,
    String? categoryId,
    String? accountId,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    final account =
        accountId ?? (await ref.read(activeAccountProvider.future))?.id;
    await ref.read(transactionRepositoryProvider).create(
          householdId: householdId,
          accountId: account,
          type: type,
          amount: amount,
          date: date,
          description: description,
          categoryId: categoryId,
        );
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
  }

  Future<void> update({
    required String id,
    required TransactionType type,
    required int amount,
    required DateTime date,
    String? description,
    String? categoryId,
    String? accountId,
  }) async {
    await ref.read(transactionRepositoryProvider).update(
          id: id,
          type: type,
          amount: amount,
          date: date,
          description: description,
          categoryId: categoryId,
          accountId: accountId,
        );
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
  }

  Future<void> delete(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
  }
}

final transactionActionsProvider =
    Provider<TransactionActions>(TransactionActions.new);
