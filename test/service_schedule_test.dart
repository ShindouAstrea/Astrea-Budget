import 'package:astrea_budget/features/services/domain/service.dart';
import 'package:astrea_budget/features/services/domain/service_schedule.dart';
import 'package:astrea_budget/shared/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('occursInMonth', () {
    final marzo = DateTime(2026, 3);

    test('mensual cobra todos los meses desde el ancla', () {
      for (var m = 3; m <= 12; m++) {
        expect(
          occursInMonth(
            frequency: ServiceFrequency.mensual,
            anchor: marzo,
            month: DateTime(2026, m),
          ),
          isTrue,
          reason: 'mes $m',
        );
      }
    });

    test('anual sólo cobra en el mes del ancla, año a año', () {
      bool cobra(int year, int month) => occursInMonth(
            frequency: ServiceFrequency.anual,
            anchor: marzo,
            month: DateTime(year, month),
          );
      expect(cobra(2026, 3), isTrue);
      expect(cobra(2026, 4), isFalse);
      expect(cobra(2026, 9), isFalse);
      expect(cobra(2027, 3), isTrue);
      expect(cobra(2028, 3), isTrue);
    });

    test('semestral cobra cada 6 meses (marzo y septiembre)', () {
      bool cobra(int year, int month) => occursInMonth(
            frequency: ServiceFrequency.semestral,
            anchor: marzo,
            month: DateTime(year, month),
          );
      expect(cobra(2026, 3), isTrue);
      expect(cobra(2026, 9), isTrue);
      expect(cobra(2027, 3), isTrue);
      expect(cobra(2026, 6), isFalse);
      expect(cobra(2026, 8), isFalse);
    });

    test('bimestral y trimestral respetan su período', () {
      expect(
        occursInMonth(
          frequency: ServiceFrequency.bimestral,
          anchor: marzo,
          month: DateTime(2026, 5),
        ),
        isTrue,
      );
      expect(
        occursInMonth(
          frequency: ServiceFrequency.bimestral,
          anchor: marzo,
          month: DateTime(2026, 6),
        ),
        isFalse,
      );
      expect(
        occursInMonth(
          frequency: ServiceFrequency.trimestral,
          anchor: marzo,
          month: DateTime(2026, 6),
        ),
        isTrue,
      );
    });

    test('único cobra sólo el mes del ancla', () {
      expect(
        occursInMonth(
          frequency: ServiceFrequency.unico,
          anchor: marzo,
          month: marzo,
        ),
        isTrue,
      );
      expect(
        occursInMonth(
          frequency: ServiceFrequency.unico,
          anchor: marzo,
          month: DateTime(2026, 4),
        ),
        isFalse,
      );
    });

    test('no genera pagos anteriores al primer cobro', () {
      expect(
        occursInMonth(
          frequency: ServiceFrequency.mensual,
          anchor: marzo,
          month: DateTime(2026, 2),
        ),
        isFalse,
      );
      expect(
        occursInMonth(
          frequency: ServiceFrequency.anual,
          anchor: marzo,
          month: DateTime(2025, 3),
        ),
        isFalse,
      );
    });

    test('sin ancla sólo se generan los mensuales', () {
      expect(
        occursInMonth(
          frequency: ServiceFrequency.mensual,
          anchor: null,
          month: marzo,
        ),
        isTrue,
      );
      expect(
        occursInMonth(
          frequency: ServiceFrequency.anual,
          anchor: null,
          month: marzo,
        ),
        isFalse,
      );
    });
  });

  group('nextChargeMonth', () {
    final marzo = DateTime(2026, 3);

    test('semestral: desde mayo, el próximo cobro es septiembre', () {
      expect(
        nextChargeMonth(
          frequency: ServiceFrequency.semestral,
          anchor: marzo,
          from: DateTime(2026, 5, 20),
        ),
        DateTime(2026, 9),
      );
    });

    test('anual: desde abril, el próximo cobro es marzo del año siguiente', () {
      expect(
        nextChargeMonth(
          frequency: ServiceFrequency.anual,
          anchor: marzo,
          from: DateTime(2026, 4, 1),
        ),
        DateTime(2027, 3),
      );
    });

    test('si el mes actual toca cobro, devuelve el mes actual', () {
      expect(
        nextChargeMonth(
          frequency: ServiceFrequency.anual,
          anchor: marzo,
          from: DateTime(2026, 3, 28),
        ),
        marzo,
      );
    });

    test('antes del ancla devuelve el ancla', () {
      expect(
        nextChargeMonth(
          frequency: ServiceFrequency.anual,
          anchor: marzo,
          from: DateTime(2025, 12, 1),
        ),
        marzo,
      );
    });

    test('único ya cobrado no tiene próximo cobro', () {
      expect(
        nextChargeMonth(
          frequency: ServiceFrequency.unico,
          anchor: marzo,
          from: DateTime(2026, 4),
        ),
        isNull,
      );
    });
  });

  group('dueDateIn', () {
    test('usa el día de cobro dentro del mes', () {
      expect(dueDateIn(DateTime(2026, 5), 10), DateTime(2026, 5, 10));
    });

    test('recorta al último día en meses cortos (31 → 28 de febrero)', () {
      expect(dueDateIn(DateTime(2026, 2), 31), DateTime(2026, 2, 28));
    });

    test('febrero bisiesto llega al 29', () {
      expect(dueDateIn(DateTime(2028, 2), 31), DateTime(2028, 2, 29));
    });
  });
group('Service.nextChargeFrom', () {
    Service servicio(ServiceFrequency f, {int? day = 5, DateTime? anchor}) =>
        Service(
          id: 's1',
          userId: 'u1',
          name: 'Suscripción',
          billingDay: day,
          frequency: f,
          firstChargeMonth: anchor ?? DateTime(2026, 3),
        );

    test('si el cobro del mes ya venció, salta al período siguiente', () {
      // Anual anclado en marzo, cobra el 5. Hoy es 30 de marzo: ya pasó.
      expect(
        servicio(ServiceFrequency.anual).nextChargeFrom(DateTime(2026, 3, 30)),
        DateTime(2027, 3),
      );
    });

    test('si el cobro del mes aún no vence, es este mes', () {
      expect(
        servicio(ServiceFrequency.anual).nextChargeFrom(DateTime(2026, 3, 1)),
        DateTime(2026, 3),
      );
      // El mismo día del cobro todavía cuenta.
      expect(
        servicio(ServiceFrequency.anual).nextChargeFrom(DateTime(2026, 3, 5)),
        DateTime(2026, 3),
      );
    });

    test('mensual vencido pasa al mes siguiente', () {
      expect(
        servicio(ServiceFrequency.mensual).nextChargeFrom(DateTime(2026, 3, 30)),
        DateTime(2026, 4),
      );
    });

    test('único ya vencido no tiene próximo cobro', () {
      expect(
        servicio(ServiceFrequency.unico).nextChargeFrom(DateTime(2026, 3, 30)),
        isNull,
      );
    });

    test('sin día de cobro no se puede generar el pago', () {
      final s = servicio(ServiceFrequency.mensual, day: null);
      expect(s.autoGenerates, isFalse);
      expect(s.dueDateFor(DateTime(2026, 3)), isNull);
    });
  });
}
