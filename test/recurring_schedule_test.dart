import 'package:astrea_budget/features/recurring/domain/recurring_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pendingOccurrences', () {
    test('plantilla nueva: sólo el mes actual, sin inventar historia', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 5,
          lastGenerated: null,
          today: DateTime(2026, 8, 20),
        ),
        [DateTime(2026, 8, 5)],
      );
    });

    test('plantilla nueva cuyo día aún no llega: nada', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 25,
          lastGenerated: null,
          today: DateTime(2026, 8, 20),
        ),
        isEmpty,
      );
    });

    test('el día mismo ya cuenta', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 20,
          lastGenerated: null,
          today: DateTime(2026, 8, 20),
        ),
        [DateTime(2026, 8, 20)],
      );
    });

    test('recupera los meses saltados (app cerrada dos meses)', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 5,
          lastGenerated: DateTime(2026, 6, 5),
          today: DateTime(2026, 8, 20),
        ),
        [DateTime(2026, 7, 5), DateTime(2026, 8, 5)],
      );
    });

    test('si ya se registró este mes, no repite', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 5,
          lastGenerated: DateTime(2026, 8, 5),
          today: DateTime(2026, 8, 20),
        ),
        isEmpty,
      );
    });

    test('al día pero el día del mes todavía no llega', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 5,
          lastGenerated: DateTime(2026, 8, 5),
          today: DateTime(2026, 9, 4),
        ),
        isEmpty,
      );
    });

    test('cruza el cambio de año', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 10,
          lastGenerated: DateTime(2025, 11, 10),
          today: DateTime(2026, 1, 15),
        ),
        [DateTime(2025, 12, 10), DateTime(2026, 1, 10)],
      );
    });

    test('no recupera más de 12 meses hacia atrás', () {
      final r = pendingOccurrences(
        dayOfMonth: 5,
        lastGenerated: DateTime(2020, 1, 5),
        today: DateTime(2026, 8, 20),
      );
      expect(r.length, 12);
      expect(r.first, DateTime(2025, 9, 5));
      expect(r.last, DateTime(2026, 8, 5));
    });

    test('el día se recorta a 28 para que exista en febrero', () {
      expect(
        pendingOccurrences(
          dayOfMonth: 31,
          lastGenerated: null,
          today: DateTime(2026, 2, 28),
        ),
        [DateTime(2026, 2, 28)],
      );
    });
  });

  group('nextOccurrence', () {
    test('al día: la del mes siguiente', () {
      expect(
        nextOccurrence(
          dayOfMonth: 5,
          lastGenerated: DateTime(2026, 8, 5),
          today: DateTime(2026, 8, 20),
        ),
        DateTime(2026, 9, 5),
      );
    });

    test('atrasado: la primera pendiente', () {
      expect(
        nextOccurrence(
          dayOfMonth: 5,
          lastGenerated: DateTime(2026, 6, 5),
          today: DateTime(2026, 8, 20),
        ),
        DateTime(2026, 7, 5),
      );
    });

    test('nuevo y el día aún no llega: este mes', () {
      expect(
        nextOccurrence(
          dayOfMonth: 25,
          lastGenerated: null,
          today: DateTime(2026, 8, 20),
        ),
        DateTime(2026, 8, 25),
      );
    });
  });
}
