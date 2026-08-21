// Evolución del precio de un servicio a partir de sus pagos. Lógica pura.

import 'service_payment.dart';

/// Un tramo de precio: desde cuándo rige [amount] y cuánto era antes.
class PriceChange {
  const PriceChange({
    required this.since,
    required this.amount,
    this.previous,
  });

  /// Vencimiento del primer pago con este monto.
  final DateTime since;

  final double amount;

  /// Monto del tramo anterior; null en el primero.
  final double? previous;

  double? get difference => previous == null ? null : amount - previous!;

  /// Variación porcentual respecto al tramo anterior (null en el primero).
  double? get percent {
    final before = previous;
    if (before == null || before == 0) return null;
    return (amount - before) / before * 100;
  }

  bool get isIncrease => (difference ?? 0) > 0;
}

/// Reconstruye los cambios de precio a partir del historial de pagos.
///
/// Colapsa los meses con el mismo monto: si pagaste $9.900 de enero a junio y
/// $12.990 desde julio, devuelve dos tramos, no ocho. Con un solo tramo no hubo
/// cambios de precio.
List<PriceChange> priceHistory(List<ServicePayment> payments) {
  final sorted = [...payments]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  final changes = <PriceChange>[];

  for (final payment in sorted) {
    if (changes.isEmpty) {
      changes.add(PriceChange(since: payment.dueDate, amount: payment.amount));
      continue;
    }
    final last = changes.last;
    if (payment.amount != last.amount) {
      changes.add(PriceChange(
        since: payment.dueDate,
        amount: payment.amount,
        previous: last.amount,
      ));
    }
  }
  return changes;
}
