import 'package:astrea_budget/features/budgets/data/budget_alert_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('budgetAlertLevel', () {
    test('sin tope definido nunca alerta', () {
      expect(budgetAlertLevel(500000, 0), 0);
      expect(budgetAlertLevel(500000, -1), 0);
    });

    test('bajo el 80% no alerta', () {
      expect(budgetAlertLevel(79999, 100000), 0);
      expect(budgetAlertLevel(0, 100000), 0);
    });

    test('al 80% (inclusive) advierte', () {
      expect(budgetAlertLevel(80000, 100000), 1);
      expect(budgetAlertLevel(99999, 100000), 1);
      // Exactamente el tope todavía no lo supera.
      expect(budgetAlertLevel(100000, 100000), 1);
    });

    test('sobre el tope marca nivel 2', () {
      expect(budgetAlertLevel(100001, 100000), 2);
    });
  });
}
