import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_cache.dart';
import '../../../shared/budget_cycle.dart';
import '../../../shared/enums.dart';
import '../../../shared/selected_month_provider.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../budgets/data/budget_alert_service.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';

/// Transacciones del mes financiero seleccionado (según el día de corte).
/// Pasa por [LocalCache]: sin conexión sirve la última lectura guardada.
final monthlyTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final month = ref.watch(selectedMonthProvider);
  final cutoff = ref.watch(budgetCutoffProvider);
  final range = BudgetCycle.bounds(month, cutoff);
  final repo = ref.watch(transactionRepositoryProvider);
  return ref.watch(localCacheProvider).fetchList(
        key: 'tx:$householdId:${range.start.year}-${range.start.month}-'
            '${range.start.day}:$cutoff',
        fetch: () => repo.fetchBetween(householdId, range.start, range.end),
        toJson: (t) => t.toJson(),
        fromJson: TransactionModel.fromJson,
      );
});

/// Filtros activos del historial.
class TransactionFilters {
  const TransactionFilters({
    this.type,
    this.categoryId,
    this.query = '',
    this.from,
    this.to,
  });

  final TransactionType? type;
  final String? categoryId;

  /// Texto de búsqueda (contra descripción, categoría y monto).
  final String query;

  /// Rango de fechas dentro del mes (ambos inclusive).
  final DateTime? from;
  final DateTime? to;

  TransactionFilters copyWith({
    Object? type = _sentinel,
    Object? categoryId = _sentinel,
    String? query,
    Object? from = _sentinel,
    Object? to = _sentinel,
  }) {
    return TransactionFilters(
      type: type == _sentinel ? this.type : type as TransactionType?,
      categoryId:
          categoryId == _sentinel ? this.categoryId : categoryId as String?,
      query: query ?? this.query,
      from: from == _sentinel ? this.from : from as DateTime?,
      to: to == _sentinel ? this.to : to as DateTime?,
    );
  }

  bool get hasDateRange => from != null || to != null;

  bool get isActive =>
      type != null || categoryId != null || query.isNotEmpty || hasDateRange;

  static const _sentinel = Object();
}

class TransactionFiltersNotifier extends Notifier<TransactionFilters> {
  @override
  TransactionFilters build() => const TransactionFilters();

  void setType(TransactionType? type) =>
      state = state.copyWith(type: type);
  void setCategory(String? categoryId) =>
      state = state.copyWith(categoryId: categoryId);
  void setQuery(String query) => state = state.copyWith(query: query);
  void setDateRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(from: from, to: to);
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
  final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
  final categoryNames = {for (final c in categories) c.id: c.name};
  final query = filters.query.trim().toLowerCase();

  return ref.watch(monthlyTransactionsProvider).whenData((list) {
    return list.where((t) {
      if (filters.type != null && t.type != filters.type) return false;
      if (filters.categoryId != null && t.categoryId != filters.categoryId) {
        return false;
      }
      if (filters.from != null && t.date.isBefore(filters.from!)) return false;
      if (filters.to != null) {
        // `to` es inclusive: descarta lo que cae después de ese día.
        final endExclusive = DateTime(
          filters.to!.year,
          filters.to!.month,
          filters.to!.day + 1,
        );
        if (!t.date.isBefore(endExclusive)) return false;
      }
      if (query.isNotEmpty) {
        final haystack = [
          t.description ?? '',
          categoryNames[t.categoryId] ?? '',
          t.amount.toInt().toString(),
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
  });
});

/// Acciones CRUD sobre transacciones. Invalida el listado del mes al terminar
/// y, si fue un gasto con categoría, revisa las alertas de presupuesto.
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
    _refresh();
    _checkBudgetAlert(type, categoryId, date);
  }

  /// Compra en cuotas: N gastos mensuales que suman el total.
  Future<void> createInstallments({
    required int totalAmount,
    required int count,
    required DateTime firstDate,
    String? description,
    String? categoryId,
    String? accountId,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    final account =
        accountId ?? (await ref.read(activeAccountProvider.future))?.id;
    await ref.read(transactionRepositoryProvider).createInstallments(
          householdId: householdId,
          accountId: account,
          totalAmount: totalAmount,
          count: count,
          firstDate: firstDate,
          description: description,
          categoryId: categoryId,
        );
    _refresh();
    _checkBudgetAlert(TransactionType.expense, categoryId, firstDate);
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
    _refresh();
    _checkBudgetAlert(type, categoryId, date);
  }

  Future<void> delete(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    _refresh();
  }

  /// Elimina la compra en cuotas completa (todas las cuotas del grupo).
  Future<void> deleteInstallmentGroup(String groupId) async {
    await ref.read(transactionRepositoryProvider).deleteInstallmentGroup(groupId);
    _refresh();
  }

  void _refresh() {
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
  }

  /// Dispara la revisión de alertas sin bloquear el guardado.
  void _checkBudgetAlert(TransactionType type, String? categoryId, DateTime date) {
    if (type.isIncome || categoryId == null) return;
    unawaited(
      ref
          .read(budgetAlertServiceProvider)
          .checkCategory(categoryId: categoryId, date: date),
    );
  }
}

final transactionActionsProvider =
    Provider<TransactionActions>(TransactionActions.new);
