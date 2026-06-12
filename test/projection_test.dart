import 'package:astrea_budget/features/projection/presentation/projection_controller.dart';
import 'package:astrea_budget/features/transactions/domain/transaction.dart';
import 'package:astrea_budget/shared/enums.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel tx({
  required TransactionType type,
  required double amount,
  required DateTime date,
  String? serviceId,
}) {
  return TransactionModel(
    id: 'tx-${date.toIso8601String()}-$amount',
    userId: 'u1',
    type: type,
    amount: amount,
    date: date,
    serviceId: serviceId,
  );
}

void main() {
  group('MonthProjection.compute', () {
    final month = DateTime(2026, 6);
    final transactions = [
      tx(
        type: TransactionType.income,
        amount: 1000000,
        date: DateTime(2026, 6, 1),
      ),
      // Gasto variable.
      tx(type: TransactionType.expense, amount: 90000, date: DateTime(2026, 6, 5)),
      // Servicio ya pagado.
      tx(
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 6, 3),
        serviceId: 's1',
      ),
    ];

    test('mes en curso: extrapola el gasto variable y suma servicios', () {
      final p = MonthProjection.compute(
        transactions: transactions,
        pendingServices: 30000,
        month: month,
        cutoff: 1,
        today: DateTime(2026, 6, 10),
      );

      expect(p.isOngoing, isTrue);
      expect(p.income, 1000000);
      expect(p.currentExpense, 140000);
      expect(p.elapsedDays, 10);
      expect(p.totalDays, 30);
      // Variable 90.000 a 10/30 del mes → 270.000; + servicio pagado 50.000
      // + pendiente 30.000.
      expect(p.projectedExpense, closeTo(350000, 0.01));
      expect(p.projectedBalance, closeTo(650000, 0.01));
      expect(p.progress, closeTo(10 / 30, 0.001));
    });

    test('mes cerrado: la proyección es el gasto real', () {
      final p = MonthProjection.compute(
        transactions: transactions,
        pendingServices: 30000,
        month: month,
        cutoff: 1,
        today: DateTime(2026, 7, 2),
      );

      expect(p.isOngoing, isFalse);
      expect(p.elapsedDays, p.totalDays);
      expect(p.projectedExpense, 140000);
    });

    test('mes futuro: sólo proyecta servicios', () {
      final p = MonthProjection.compute(
        transactions: const [],
        pendingServices: 80000,
        month: DateTime(2026, 8),
        cutoff: 1,
        today: DateTime(2026, 6, 10),
      );

      expect(p.isOngoing, isFalse);
      expect(p.elapsedDays, 0);
      expect(p.projectedExpense, 80000);
    });

    test('respeta el día de corte para decidir si el mes está en curso', () {
      // "Julio" con corte 25 va del 25 de junio al 25 de julio.
      final p = MonthProjection.compute(
        transactions: const [],
        pendingServices: 0,
        month: DateTime(2026, 7),
        cutoff: 25,
        today: DateTime(2026, 6, 26),
      );

      expect(p.isOngoing, isTrue);
      expect(p.elapsedDays, 2); // 25 y 26 de junio
      expect(p.totalDays, 30);
    });
  });
}
