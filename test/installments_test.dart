import 'package:astrea_budget/features/transactions/domain/installments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splitInstallments', () {
    test('reparte en partes iguales cuando la división es exacta', () {
      expect(splitInstallments(120000, 12), List.filled(12, 10000));
    });

    test('las primeras cuotas absorben el resto y la suma es exacta', () {
      expect(splitInstallments(100, 3), [34, 33, 33]);
      expect(splitInstallments(99990, 12).reduce((a, b) => a + b), 99990);
    });

    test('una sola cuota devuelve el total', () {
      expect(splitInstallments(45990, 1), [45990]);
    });
  });

  group('installmentDate', () {
    test('mantiene el día del mes en meses sucesivos', () {
      expect(installmentDate(DateTime(2026, 6, 15), 0), DateTime(2026, 6, 15));
      expect(installmentDate(DateTime(2026, 6, 15), 1), DateTime(2026, 7, 15));
      expect(installmentDate(DateTime(2026, 6, 15), 6), DateTime(2026, 12, 15));
    });

    test('ajusta al último día en meses más cortos', () {
      expect(installmentDate(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(installmentDate(DateTime(2026, 1, 31), 3), DateTime(2026, 4, 30));
      // Año bisiesto.
      expect(installmentDate(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    });

    test('cruza el cambio de año', () {
      expect(installmentDate(DateTime(2026, 11, 5), 3), DateTime(2027, 2, 5));
    });
  });
}
