import 'package:intl/intl.dart';

/// Utilidades de formato para Chile (es_CL): moneda CLP sin decimales y fechas.
class Formatters {
  const Formatters._();

  static const String locale = 'es_CL';

  // El locale es_CL coloca el símbolo al final (`1.250.000 $`). Como la app
  // muestra siempre `$1.250.000`, usamos el patrón decimal (separador de miles
  // con punto) y anteponemos el símbolo nosotros.
  static final NumberFormat _decimal = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = 0; // CLP sin decimales

  /// `1250000` → `$1.250.000`
  static String currency(num amount) {
    final negative = amount < 0;
    final formatted = _decimal.format(amount.abs());
    return '${negative ? '-' : ''}\$$formatted';
  }

  /// Igual que [currency] pero con signo explícito para ingresos/gastos.
  static String signedCurrency(num amount, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${currency(amount.abs())}';
  }

  /// `31 may 2026`
  static String dayMonthYear(DateTime date) =>
      DateFormat('d MMM yyyy', locale).format(date);

  /// `Mayo 2026` (capitalizado).
  static String monthYear(DateTime date) {
    final raw = DateFormat('MMMM yyyy', locale).format(date);
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// `Ene`, `Feb`, … (abreviado y capitalizado, sin punto).
  static String monthShort(DateTime date) {
    final raw = DateFormat('MMM', locale).format(date).replaceAll('.', '');
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// `$1,2M`, `$350k`, `$900` — moneda compacta para ejes de gráficos.
  static String compactCurrency(num amount) {
    final a = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (a >= 1000000) {
      return '$sign\$${(a / 1000000).toStringAsFixed(a >= 10000000 ? 0 : 1)}M';
    }
    if (a >= 1000) return '$sign\$${(a / 1000).round()}k';
    return '$sign\$${a.round()}';
  }

  /// `5` → `Vence el 5` (día del mes para servicios fijos).
  static String billingDay(int day) => 'Vence el $day';

  /// Parsea un texto de monto ingresado por el usuario (acepta separadores de
  /// miles y descarta el símbolo) a un entero CLP. Devuelve null si es inválido.
  static int? parseAmount(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }
}
