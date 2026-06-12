import 'package:astrea_budget/shared/budget_cycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetCycle.bounds', () {
    test('con corte 1 coincide con el mes calendario', () {
      final r = BudgetCycle.bounds(DateTime(2026, 6), 1);
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 7, 1));
    });

    test('con corte 25, "Junio" va del 25 de mayo al 25 de junio', () {
      final r = BudgetCycle.bounds(DateTime(2026, 6), 25);
      expect(r.start, DateTime(2026, 5, 25));
      expect(r.end, DateTime(2026, 6, 25));
    });

    test('cruza el cambio de año (Enero con corte 25 parte el 25 de dic)', () {
      final r = BudgetCycle.bounds(DateTime(2026, 1), 25);
      expect(r.start, DateTime(2025, 12, 25));
      expect(r.end, DateTime(2026, 1, 25));
    });

    test('si el mes anterior no alcanza el día de corte, parte el día 1', () {
      // Marzo con corte 30: febrero no tiene día 30.
      final r = BudgetCycle.bounds(DateTime(2026, 3), 30);
      expect(r.start, DateTime(2026, 3, 1));
      expect(r.end, DateTime(2026, 3, 30));
    });
  });

  group('BudgetCycle.labelFor', () {
    test('con corte 1 devuelve el mes calendario', () {
      expect(BudgetCycle.labelFor(DateTime(2026, 6, 15), 1), DateTime(2026, 6));
    });

    test('un día >= corte cuenta para el mes siguiente', () {
      expect(
        BudgetCycle.labelFor(DateTime(2026, 5, 30), 25),
        DateTime(2026, 6),
      );
      expect(
        BudgetCycle.labelFor(DateTime(2026, 6, 24), 25),
        DateTime(2026, 6),
      );
      expect(
        BudgetCycle.labelFor(DateTime(2026, 6, 25), 25),
        DateTime(2026, 7),
      );
    });

    test('diciembre con día >= corte etiqueta enero del año siguiente', () {
      expect(
        BudgetCycle.labelFor(DateTime(2025, 12, 28), 25),
        DateTime(2026, 1),
      );
    });

    test('es inverso de bounds: toda fecha del ciclo lleva su etiqueta', () {
      const cutoff = 10;
      final label = DateTime(2026, 6);
      final r = BudgetCycle.bounds(label, cutoff);
      for (var d = r.start;
          d.isBefore(r.end);
          d = d.add(const Duration(days: 1))) {
        expect(BudgetCycle.labelFor(d, cutoff), label, reason: 'fecha $d');
      }
    });
  });

  test('daysInMonth maneja febrero y años bisiestos', () {
    expect(BudgetCycle.daysInMonth(2026, 2), 28);
    expect(BudgetCycle.daysInMonth(2028, 2), 29);
    expect(BudgetCycle.daysInMonth(2026, 12), 31);
  });
}
