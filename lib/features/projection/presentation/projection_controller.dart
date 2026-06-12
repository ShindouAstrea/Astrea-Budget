import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/budget_cycle.dart';
import '../../../shared/selected_month_provider.dart';
import '../../services/presentation/services_controller.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/presentation/transactions_controller.dart';

/// Proyección financiera del mes seleccionado.
class MonthProjection {
  const MonthProjection({
    required this.isOngoing,
    required this.income,
    required this.currentExpense,
    required this.pendingServices,
    required this.projectedExpense,
    required this.elapsedDays,
    required this.totalDays,
  });

  /// Proyecta el cierre del mes: extrapola el gasto **variable** (no de
  /// servicios) al ritmo actual y le suma los servicios fijos del mes
  /// (pagados + pendientes). El ingreso se mantiene en lo registrado.
  ///
  /// Lógica pura: [today] se inyecta para poder testearla.
  factory MonthProjection.compute({
    required List<TransactionModel> transactions,
    required double pendingServices,
    required DateTime month,
    required int cutoff,
    required DateTime today,
  }) {
    var income = 0.0;
    var expense = 0.0;
    var serviceExpense = 0.0; // gasto de servicios ya pagado este mes
    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        if (t.serviceId != null) serviceExpense += t.amount;
      }
    }

    final bounds = BudgetCycle.bounds(month, cutoff);
    final day = DateTime(today.year, today.month, today.day);
    final totalDays = bounds.end.difference(bounds.start).inDays;

    final isPast = !day.isBefore(bounds.end); // hoy >= fin
    final isFuture = day.isBefore(bounds.start);
    final isOngoing = !isPast && !isFuture;

    final int elapsedDays;
    if (isPast) {
      elapsedDays = totalDays;
    } else if (isFuture) {
      elapsedDays = 0;
    } else {
      elapsedDays = day.difference(bounds.start).inDays + 1;
    }

    final discretionary = expense - serviceExpense;
    final double projectedExpense;
    if (isPast) {
      projectedExpense = expense; // ya cerrado: el real
    } else if (elapsedDays <= 0) {
      // futuro: sólo servicios
      projectedExpense = serviceExpense + pendingServices;
    } else {
      final fraction = (elapsedDays / totalDays).clamp(0.0001, 1.0);
      final projectedDiscretionary = discretionary / fraction;
      projectedExpense =
          projectedDiscretionary + serviceExpense + pendingServices;
    }

    return MonthProjection(
      isOngoing: isOngoing,
      income: income,
      currentExpense: expense,
      pendingServices: pendingServices,
      projectedExpense: projectedExpense,
      elapsedDays: elapsedDays,
      totalDays: totalDays,
    );
  }

  /// El mes está en curso (hoy cae dentro de sus límites): la proyección aplica.
  final bool isOngoing;

  final double income;
  final double currentExpense;

  /// Servicios fijos pendientes de pago este mes (gasto comprometido).
  final double pendingServices;

  /// Gasto estimado al cierre del mes (variable extrapolado + servicios).
  final double projectedExpense;

  final int elapsedDays;
  final int totalDays;

  double get projectedBalance => income - projectedExpense;

  /// Fracción del mes transcurrida (0..1).
  double get progress =>
      totalDays <= 0 ? 1 : (elapsedDays / totalDays).clamp(0.0, 1.0);
}

/// Proyección del mes seleccionado a partir de transacciones y pagos.
final monthProjectionProvider = Provider<AsyncValue<MonthProjection>>((ref) {
  final txAsync = ref.watch(monthlyTransactionsProvider);
  final payments = ref.watch(monthlyPaymentsProvider).valueOrNull ?? const [];
  final month = ref.watch(selectedMonthProvider);
  final cutoff = ref.watch(budgetCutoffProvider);

  return txAsync.whenData((txs) {
    final pending = payments
        .where((p) => !p.isPaid)
        .fold<double>(0, (s, p) => s + p.amount);
    return MonthProjection.compute(
      transactions: txs,
      pendingServices: pending,
      month: month,
      cutoff: cutoff,
      today: DateTime.now(),
    );
  });
});
