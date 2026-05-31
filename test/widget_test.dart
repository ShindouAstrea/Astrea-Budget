import 'package:astrea_budget/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es_CL'));

  group('Formatters', () {
    test('formatea CLP sin decimales', () {
      expect(Formatters.currency(1250000), r'$1.250.000');
    });

    test('parsea montos ignorando separadores y símbolos', () {
      expect(Formatters.parseAmount(r'$1.250.000'), 1250000);
      expect(Formatters.parseAmount('abc'), isNull);
    });

    test('signedCurrency antepone el signo correcto', () {
      expect(Formatters.signedCurrency(1000, isIncome: true), r'+$1.000');
      expect(Formatters.signedCurrency(1000, isIncome: false), r'-$1.000');
    });
  });
}
