import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/budget_cycle.dart';
import '../../../shared/selected_month_provider.dart';
import '../../households/presentation/household_controller.dart';
import '../../transactions/data/transaction_repository.dart';

/// Ingreso/gasto de un mes financiero (para el gráfico de tendencias).
class MonthTrend {
  const MonthTrend({
    required this.month,
    required this.income,
    required this.expense,
  });

  /// Etiqueta del mes financiero (día 1).
  final DateTime month;
  final double income;
  final double expense;

  double get balance => income - expense;
}

/// Número de meses mostrados en la tendencia.
const int kTrendMonths = 6;

/// Ingreso/gasto de los últimos [kTrendMonths] meses financieros, terminando en
/// el mes seleccionado. Una sola consulta cubre todo el rango y se agrupa en la
/// app por mes financiero (respeta el día de corte y excluye transferencias).
final monthlyTrendsProvider = FutureProvider<List<MonthTrend>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final cutoff = ref.watch(budgetCutoffProvider);
  final anchor = ref.watch(selectedMonthProvider);

  final labels = [
    for (var i = kTrendMonths - 1; i >= 0; i--)
      DateTime(anchor.year, anchor.month - i),
  ];
  final rangeStart = BudgetCycle.bounds(labels.first, cutoff).start;
  final rangeEnd = BudgetCycle.bounds(labels.last, cutoff).end;

  final txs = await ref
      .watch(transactionRepositoryProvider)
      .fetchBetween(householdId, rangeStart, rangeEnd);

  String key(DateTime d) => '${d.year}-${d.month}';
  final income = {for (final l in labels) key(l): 0.0};
  final expense = {for (final l in labels) key(l): 0.0};

  for (final t in txs) {
    final k = key(BudgetCycle.labelFor(t.date, cutoff));
    if (!income.containsKey(k)) continue;
    if (t.isIncome) {
      income[k] = income[k]! + t.amount;
    } else {
      expense[k] = expense[k]! + t.amount;
    }
  }

  return [
    for (final l in labels)
      MonthTrend(
        month: l,
        income: income[key(l)]!,
        expense: expense[key(l)]!,
      ),
  ];
});

/// Comparación del mes activo vs el anterior (variación % de gasto e ingreso).
class TrendComparison {
  const TrendComparison({required this.current, required this.previous});

  final MonthTrend current;
  final MonthTrend previous;

  /// Variación porcentual del gasto (null si el mes previo no tuvo gasto).
  double? get expenseChangePct => _pct(previous.expense, current.expense);
  double? get incomeChangePct => _pct(previous.income, current.income);

  static double? _pct(double from, double to) {
    if (from <= 0) return null;
    return (to - from) / from * 100;
  }
}

/// Comparación lista para la UI; null si no hay al menos dos meses con datos.
final trendComparisonProvider = Provider<TrendComparison?>((ref) {
  final trends = ref.watch(monthlyTrendsProvider).valueOrNull;
  if (trends == null || trends.length < 2) return null;
  return TrendComparison(
    current: trends.last,
    previous: trends[trends.length - 2],
  );
});
