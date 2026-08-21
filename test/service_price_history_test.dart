import 'package:astrea_budget/features/services/domain/service_payment.dart';
import 'package:astrea_budget/features/services/domain/service_price_history.dart';
import 'package:flutter_test/flutter_test.dart';

ServicePayment pago(String date, double amount) => ServicePayment(
      id: '$date-$amount',
      serviceId: 's1',
      userId: 'u1',
      dueDate: DateTime.parse(date),
      amount: amount,
    );

void main() {
  group('priceHistory', () {
    test('colapsa los meses con el mismo monto', () {
      final r = priceHistory([
        pago('2026-01-05', 9990),
        pago('2026-02-05', 9990),
        pago('2026-03-05', 9990),
        pago('2026-04-05', 12990),
        pago('2026-05-05', 12990),
      ]);

      expect(r.length, 2);
      expect(r.first.amount, 9990);
      expect(r.first.previous, isNull);
      expect(r.last.amount, 12990);
      expect(r.last.since, DateTime(2026, 4, 5));
    });

    test('calcula la variación del último tramo', () {
      final r = priceHistory([
        pago('2026-01-05', 10000),
        pago('2026-02-05', 13000),
      ]);

      expect(r.last.difference, 3000);
      expect(r.last.percent, closeTo(30, 0.001));
      expect(r.last.isIncrease, isTrue);
    });

    test('detecta las bajadas de precio', () {
      final r = priceHistory([
        pago('2026-01-05', 10000),
        pago('2026-02-05', 8000),
      ]);

      expect(r.last.difference, -2000);
      expect(r.last.percent, closeTo(-20, 0.001));
      expect(r.last.isIncrease, isFalse);
    });

    test('ordena por vencimiento aunque lleguen al revés', () {
      // El repositorio devuelve el historial de más nuevo a más viejo.
      final r = priceHistory([
        pago('2026-03-05', 12990),
        pago('2026-02-05', 9990),
        pago('2026-01-05', 9990),
      ]);

      expect(r.map((c) => c.amount).toList(), [9990, 12990]);
      expect(r.first.since, DateTime(2026, 1, 5));
    });

    test('un solo monto no es un cambio de precio', () {
      expect(priceHistory([pago('2026-01-05', 9990)]).length, 1);
      expect(priceHistory(const []), isEmpty);
    });

    test('vuelve a subir tras bajar: son tres tramos', () {
      final r = priceHistory([
        pago('2026-01-05', 10000),
        pago('2026-02-05', 8000),
        pago('2026-03-05', 10000),
      ]);

      expect(r.length, 3);
      expect(r.last.previous, 8000);
      expect(r.last.amount, 10000);
    });
  });
}
