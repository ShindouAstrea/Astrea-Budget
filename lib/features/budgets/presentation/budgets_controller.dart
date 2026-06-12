import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_cache.dart';
import '../../../shared/enums.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';

/// Topes de presupuesto del household activo. Con caché offline.
final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final repo = ref.watch(budgetRepositoryProvider);
  return ref.watch(localCacheProvider).fetchList(
        key: 'budgets:$householdId',
        fetch: () => repo.fetchByHousehold(householdId),
        toJson: (b) => b.toJson(),
        fromJson: Budget.fromJson,
      );
});

/// Estado de una categoría frente a su tope en el mes seleccionado.
class BudgetStatus {
  const BudgetStatus({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final Category category;
  final double limit; // 0 = sin tope definido
  final double spent;

  bool get hasBudget => limit > 0;
  double get remaining => limit - spent;

  /// Avance gastado/tope (puede superar 1 si se pasó del presupuesto).
  double get fraction => limit <= 0 ? 0 : spent / limit;

  bool get over => hasBudget && spent > limit;

  /// Casi al límite (>= 80% y aún no se pasa).
  bool get warning => hasBudget && !over && fraction >= 0.8;
}

/// Estado de TODAS las categorías de gasto frente a su tope en el mes activo.
/// Une el gasto por categoría (del resumen del mes) con los topes definidos.
final budgetStatusesProvider = Provider<AsyncValue<List<BudgetStatus>>>((ref) {
  final summaryAsync = ref.watch(monthSummaryProvider);
  final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
  final budgetByCat = {for (final b in budgets) b.categoryId: b.amount};

  return summaryAsync.whenData((summary) {
    final spentByCat = <String, double>{
      for (final cs in summary.byCategory)
        if (cs.category != null) cs.category!.id: cs.amount,
    };

    final statuses = [
      for (final c in categories)
        if (c.type == TransactionType.expense)
          BudgetStatus(
            category: c,
            limit: budgetByCat[c.id] ?? 0,
            spent: spentByCat[c.id] ?? 0,
          ),
    ];

    // Con tope primero (mayor avance arriba), luego sin tope por nombre.
    statuses.sort((a, b) {
      if (a.hasBudget != b.hasBudget) return a.hasBudget ? -1 : 1;
      if (a.hasBudget) return b.fraction.compareTo(a.fraction);
      return a.category.name.toLowerCase().compareTo(b.category.name.toLowerCase());
    });
    return statuses;
  });
});

/// Acciones sobre topes (definir/quitar). RLS limita la escritura al owner.
class BudgetActions {
  BudgetActions(this.ref);
  final Ref ref;

  Future<void> set(String categoryId, int amount) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(budgetRepositoryProvider).setBudget(
          householdId: householdId,
          categoryId: categoryId,
          amount: amount,
        );
    ref.invalidate(budgetsProvider);
  }

  Future<void> remove(String categoryId) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(budgetRepositoryProvider).removeBudget(
          householdId: householdId,
          categoryId: categoryId,
        );
    ref.invalidate(budgetsProvider);
  }
}

final budgetActionsProvider = Provider<BudgetActions>(BudgetActions.new);
