import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/domain/category.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/presentation/transactions_controller.dart';

/// Resumen financiero del mes seleccionado.
class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.byCategory,
  });

  final double income;
  final double expense;

  /// Gasto agregado por categoría (para el gráfico de dona), ordenado desc.
  final List<CategorySpending> byCategory;

  double get balance => income - expense;

  static const empty = MonthSummary(income: 0, expense: 0, byCategory: []);
}

class CategorySpending {
  const CategorySpending({
    required this.category,
    required this.amount,
  });

  /// Categoría asociada (null si la transacción no tiene categoría).
  final Category? category;
  final double amount;

  String get label => category?.name ?? 'Sin categoría';
}

/// Calcula el resumen del mes a partir de las transacciones y categorías.
final monthSummaryProvider = Provider<AsyncValue<MonthSummary>>((ref) {
  final txAsync = ref.watch(monthlyTransactionsProvider);
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  final byId = {for (final c in categories) c.id: c};

  return txAsync.whenData((transactions) {
    var income = 0.0;
    var expense = 0.0;
    final expenseByCat = <String?, double>{};

    for (final TransactionModel t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        expenseByCat.update(
          t.categoryId,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }

    final byCategory = expenseByCat.entries
        .map((e) => CategorySpending(category: byId[e.key], amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return MonthSummary(
      income: income,
      expense: expense,
      byCategory: byCategory,
    );
  });
});
