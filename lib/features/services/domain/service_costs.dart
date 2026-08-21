// Costo recurrente de los servicios fijos, prorrateado a un mes. Lógica pura.

import '../../../shared/enums.dart';
import 'service.dart';

/// Cuánto pesan al mes los servicios fijos, separando lo esencial de las
/// suscripciones.
class FixedCostSummary {
  const FixedCostSummary({
    required this.essential,
    required this.subscriptions,
    required this.count,
  });

  static const empty = FixedCostSummary(
    essential: 0,
    subscriptions: 0,
    count: 0,
  );

  /// Equivalente mensual de los servicios esenciales (arriendo, luz…).
  final double essential;

  /// Equivalente mensual de las suscripciones.
  final double subscriptions;

  /// Cuántos servicios entran en el cálculo.
  final int count;

  double get monthly => essential + subscriptions;

  double get yearly => monthly * 12;

  bool get isEmpty => count == 0;
}

/// Prorratea cada servicio fijo activo a su costo mensual —un anual de $60.000
/// son $5.000 al mes— y los suma.
///
/// Quedan fuera: los esporádicos (no son un compromiso fijo), los pausados,
/// los de frecuencia `unico` (no se repiten) y, si se pasa [asOf], los que ya
/// llegaron a su mes de término.
FixedCostSummary summarizeFixedCosts(
  List<Service> services, {
  DateTime? asOf,
}) {
  final month = asOf == null ? null : DateTime(asOf.year, asOf.month);
  var essential = 0.0;
  var subscriptions = 0.0;
  var count = 0;

  for (final s in services) {
    if (!s.isFixed || !s.active) continue;
    if (s.frequency == ServiceFrequency.unico) continue;
    if (month != null && s.endedBefore(month)) continue;
    final monthlyCost = s.monthlyEquivalent;
    if (monthlyCost <= 0) continue;

    count++;
    if (s.category == ServiceCategory.suscripcion) {
      subscriptions += monthlyCost;
    } else {
      essential += monthlyCost;
    }
  }

  return FixedCostSummary(
    essential: essential,
    subscriptions: subscriptions,
    count: count,
  );
}
