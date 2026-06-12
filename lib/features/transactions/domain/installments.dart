// Lógica pura de compras en cuotas (sin dependencias de Flutter).

/// Reparte un monto total CLP en [count] cuotas enteras cuya suma es exacta:
/// las primeras cuotas absorben el resto de la división.
/// `splitInstallments(100, 3)` → `[34, 33, 33]`.
List<int> splitInstallments(int total, int count) {
  assert(count > 0, 'count debe ser >= 1');
  final base = total ~/ count;
  final remainder = total - base * count;
  return [for (var i = 0; i < count; i++) base + (i < remainder ? 1 : 0)];
}

/// Fecha de la cuota [index] (0-based): mismo día de [first] en meses
/// sucesivos, ajustado al último día en meses más cortos (31 ene → 28 feb).
DateTime installmentDate(DateTime first, int index) {
  final month = DateTime(first.year, first.month + index, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(
    month.year,
    month.month,
    first.day > lastDay ? lastDay : first.day,
  );
}
