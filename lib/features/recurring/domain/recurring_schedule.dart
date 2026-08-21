// Lógica pura del calendario de un ingreso recurrente (sin dependencias de
// Flutter ni de la base de datos), para poder testearla aislada.

/// Día efectivo del cobro dentro del mes. La BD acepta 1..28 para que exista
/// en todos los meses (incluido febrero).
int effectiveDay(int dayOfMonth) => dayOfMonth.clamp(1, 28);

/// Ocurrencias que **faltan por registrar** hasta [today] inclusive.
///
/// - Si nunca se generó ([lastGenerated] null), se parte del mes actual: crear
///   una plantilla no inventa ingresos de meses anteriores.
/// - Si ya se generó alguna vez, se recuperan **todos los meses saltados**
///   desde el siguiente al último generado. Antes sólo se miraba el mes en
///   curso, así que si no abrías la app en dos meses ese ingreso se perdía.
/// - [maxCatchUp] acota cuánto se recupera hacia atrás (12 meses por defecto).
List<DateTime> pendingOccurrences({
  required int dayOfMonth,
  required DateTime? lastGenerated,
  required DateTime today,
  int maxCatchUp = 12,
}) {
  final day = effectiveDay(dayOfMonth);
  final currentMonth = DateTime(today.year, today.month);

  var month = lastGenerated == null
      ? currentMonth
      : DateTime(lastGenerated.year, lastGenerated.month + 1);
  final floor = DateTime(today.year, today.month - (maxCatchUp - 1));
  if (month.isBefore(floor)) month = floor;

  final out = <DateTime>[];
  while (!month.isAfter(currentMonth)) {
    final target = DateTime(month.year, month.month, day);
    if (target.isAfter(today)) break; // este mes aún no le toca
    if (lastGenerated == null || lastGenerated.isBefore(target)) {
      out.add(target);
    }
    month = DateTime(month.year, month.month + 1);
  }
  return out;
}

/// Próxima fecha que se registrará: la primera pendiente si el ingreso está
/// atrasado, o la del próximo ciclo si está al día.
DateTime nextOccurrence({
  required int dayOfMonth,
  required DateTime? lastGenerated,
  required DateTime today,
}) {
  final pending = pendingOccurrences(
    dayOfMonth: dayOfMonth,
    lastGenerated: lastGenerated,
    today: today,
  );
  if (pending.isNotEmpty) return pending.first;

  final day = effectiveDay(dayOfMonth);
  final thisMonth = DateTime(today.year, today.month, day);
  if (thisMonth.isAfter(today)) return thisMonth;
  return DateTime(today.year, today.month + 1, day);
}
