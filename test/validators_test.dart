import 'package:astrea_budget/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.amount', () {
    test('rechaza vacío, inválido y cero', () {
      expect(Validators.amount(null), isNotNull);
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
      expect(Validators.amount('0'), isNotNull);
    });

    test('acepta montos con separadores de miles y símbolo', () {
      expect(Validators.amount('1500'), isNull);
      expect(Validators.amount(r'$1.250.000'), isNull);
    });
  });

  group('Validators.email', () {
    test('acepta correos válidos', () {
      expect(Validators.email('jsilva@cdgo.cl'), isNull);
      expect(Validators.email('a.b+c@dominio.com'), isNull);
    });

    test('rechaza correos inválidos o vacíos', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('sin-arroba'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
  });

  group('Validators.billingDay', () {
    test('es opcional', () {
      expect(Validators.billingDay(null), isNull);
      expect(Validators.billingDay(''), isNull);
    });

    test('acepta 1..31 y rechaza el resto', () {
      expect(Validators.billingDay('1'), isNull);
      expect(Validators.billingDay('31'), isNull);
      expect(Validators.billingDay('0'), isNotNull);
      expect(Validators.billingDay('32'), isNotNull);
      expect(Validators.billingDay('x'), isNotNull);
    });
  });

  group('Validators.pin', () {
    test('exige 4 a 6 dígitos', () {
      expect(Validators.pin('1234'), isNull);
      expect(Validators.pin('123456'), isNull);
      expect(Validators.pin('123'), isNotNull);
      expect(Validators.pin('1234567'), isNotNull);
      expect(Validators.pin('12a4'), isNotNull);
    });
  });
}
