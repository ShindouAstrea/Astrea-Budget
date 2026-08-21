// Lógica pura del calendario de cobros de un servicio fijo (sin dependencias
// de Flutter ni de la base de datos), para poder testearla aislada.

import '../../../shared/enums.dart';

/// Meses entre un cobro y el siguiente. `unico` devuelve 0: no se repite.
int periodMonthsOf(ServiceFrequency frequency) => switch (frequency) {
      ServiceFrequency.mensual => 1,
      ServiceFrequency.bimestral => 2,
      ServiceFrequency.trimestral => 3,
      ServiceFrequency.semestral => 6,
      ServiceFrequency.anual => 12,
      ServiceFrequency.unico => 0,
    };

/// Meses calendario entre [from] y [to] (ignora el día).
int monthsBetween(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + (to.month - from.month);

/// ¿Le toca cobro a este servicio en el mes calendario [month]?
///
/// - `mensual`: todos los meses (el ancla sólo evita generar pagos anteriores
///   al primer cobro, si se conoce).
/// - resto: sólo los múltiplos del período contados desde [anchor].
/// - `unico`: sólo el mes del ancla.
///
/// [anchor] es el mes del primer cobro (`services.first_charge_month`). Si es
/// null —servicios creados antes de existir la columna— se asume que el
/// servicio ya está en régimen y se cobra según su período contando desde el
/// propio [month], lo que sólo permite generar los mensuales. Esto es
/// deliberado: sin ancla no hay forma de saber en qué mes cae el cobro de un
/// anual, y generar de más es justamente el error que se quiere evitar.
bool occursInMonth({
  required ServiceFrequency frequency,
  required DateTime? anchor,
  required DateTime month,
}) {
  final period = periodMonthsOf(frequency);
  if (anchor == null) return period == 1;

  final diff = monthsBetween(anchor, month);
  if (diff < 0) return false; // aún no empieza
  if (period == 0) return diff == 0; // único
  return diff % period == 0;
}

/// Primer mes con cobro igual o posterior a [from]. Null si el servicio es
/// `unico` y su cobro ya pasó, o si no hay ancla para calcularlo.
DateTime? nextChargeMonth({
  required ServiceFrequency frequency,
  required DateTime? anchor,
  required DateTime from,
}) {
  final month = DateTime(from.year, from.month);
  final period = periodMonthsOf(frequency);
  if (anchor == null) return period == 1 ? month : null;

  final anchorMonth = DateTime(anchor.year, anchor.month);
  final diff = monthsBetween(anchorMonth, month);
  if (diff <= 0) return anchorMonth;
  if (period == 0) return null; // único: su cobro ya pasó
  final remainder = diff % period;
  if (remainder == 0) return month;
  return DateTime(month.year, month.month + (period - remainder));
}

/// Día de vencimiento dentro de [month] para un `billing_day`, recortado al
/// último día del mes (día 31 en febrero → 28/29).
DateTime dueDateIn(DateTime month, int billingDay) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, billingDay.clamp(1, lastDay));
}
