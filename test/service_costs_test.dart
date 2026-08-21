import 'package:astrea_budget/features/services/domain/service.dart';
import 'package:astrea_budget/features/services/domain/service_costs.dart';
import 'package:astrea_budget/shared/enums.dart';
import 'package:flutter_test/flutter_test.dart';

Service servicio({
  required String name,
  required double amount,
  ServiceFrequency frequency = ServiceFrequency.mensual,
  ServiceType type = ServiceType.fijo,
  ServiceCategory category = ServiceCategory.esencial,
  bool active = true,
  DateTime? lastChargeMonth,
}) =>
    Service(
      id: name,
      userId: 'u1',
      name: name,
      type: type,
      category: category,
      estimatedAmount: amount,
      billingDay: 5,
      frequency: frequency,
      firstChargeMonth: DateTime(2026, 1),
      lastChargeMonth: lastChargeMonth,
      active: active,
    );

void main() {
  group('summarizeFixedCosts', () {
    test('prorratea según la frecuencia', () {
      final r = summarizeFixedCosts([
        servicio(name: 'Arriendo', amount: 400000),
        servicio(
          name: 'Netflix',
          amount: 9990,
          category: ServiceCategory.suscripcion,
        ),
        servicio(
          name: 'Dominio',
          amount: 60000,
          frequency: ServiceFrequency.anual,
          category: ServiceCategory.suscripcion,
        ),
        servicio(
          name: 'Seguro',
          amount: 120000,
          frequency: ServiceFrequency.semestral,
        ),
      ]);

      expect(r.count, 4);
      expect(r.essential, 400000 + 20000); // seguro semestral = 120000/6
      expect(r.subscriptions, 9990 + 5000); // dominio anual = 60000/12
      expect(r.monthly, 434990);
      expect(r.yearly, 434990 * 12);
    });

    test('ignora esporádicos, pausados y de frecuencia única', () {
      final r = summarizeFixedCosts([
        servicio(name: 'Fijo', amount: 10000),
        servicio(name: 'Esporádico', amount: 50000, type: ServiceType.esporadico),
        servicio(name: 'Pausado', amount: 50000, active: false),
        servicio(
          name: 'Matrícula',
          amount: 500000,
          frequency: ServiceFrequency.unico,
        ),
      ]);

      expect(r.count, 1);
      expect(r.monthly, 10000);
    });

    test('descuenta los que ya llegaron a su mes de término', () {
      final servicios = [
        servicio(name: 'Vigente', amount: 10000),
        servicio(
          name: 'Cancelado',
          amount: 25000,
          lastChargeMonth: DateTime(2026, 7),
        ),
      ];

      // En julio todavía cuenta; en agosto ya no.
      expect(summarizeFixedCosts(servicios, asOf: DateTime(2026, 7, 20)).monthly,
          35000);
      expect(summarizeFixedCosts(servicios, asOf: DateTime(2026, 8, 1)).monthly,
          10000);
    });

    test('sin servicios el resumen queda vacío', () {
      expect(summarizeFixedCosts(const []).isEmpty, isTrue);
    });
  });
}
