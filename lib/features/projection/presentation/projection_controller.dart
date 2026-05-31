import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/budget_cycle.dart';
import '../../../shared/selected_month_provider.dart';
import '../../services/presentation/services_controller.dart';
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

/// Proyecta el cierre del mes: extrapola el gasto **variable** (no de servicios)
/// al ritmo actual y le suma los servicios fijos del mes (pagados + pendientes).
/// El ingreso se mantiene en lo registrado (no se extrapola).
final monthProjectionProvider = Provider<AsyncValue<MonthProjection>>((ref) {
  final txAsync = ref.watch(monthlyTransactionsProvider);
  final payments = ref.watch(monthlyPaymentsProvider).valueOrNull ?? const [];
  final month = ref.watch(selectedMonthProvider);
  final cutoff = ref.watch(budgetCutoffProvider);

  return txAsync.whenData((txs) {
    var income = 0.0;
    var expense = 0.0;
    var serviceExpense = 0.0; // gasto de servicios ya pagado este mes
    for (final t in txs) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        if (t.serviceId != null) serviceExpense += t.amount;
      }
    }
    final pending = payments
        .where((p) => !p.isPaid)
        .fold<double>(0, (s, p) => s + p.amount);

    final bounds = BudgetCycle.bounds(month, cutoff);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = bounds.end.difference(bounds.start).inDays;

    final isPast = !today.isBefore(bounds.end); // hoy >= fin
    final isFuture = today.isBefore(bounds.start);
    final isOngoing = !isPast && !isFuture;

    final int elapsedDays;
    if (isPast) {
      elapsedDays = totalDays;
    } else if (isFuture) {
      elapsedDays = 0;
    } else {
      elapsedDays = today.difference(bounds.start).inDays + 1;
    }

    final discretionary = expense - serviceExpense;
    final double projectedExpense;
    if (isPast) {
      projectedExpense = expense; // ya cerrado: el real
    } else if (elapsedDays <= 0) {
      projectedExpense = serviceExpense + pending; // futuro: sólo servicios
    } else {
      final fraction = (elapsedDays / totalDays).clamp(0.0001, 1.0);
      final projectedDiscretionary = discretionary / fraction;
      projectedExpense = projectedDiscretionary + serviceExpense + pending;
    }

    return MonthProjection(
      isOngoing: isOngoing,
      income: income,
      currentExpense: expense,
      pendingServices: pending,
      projectedExpense: projectedExpense,
      elapsedDays: elapsedDays,
      totalDays: totalDays,
    );
  });
});
