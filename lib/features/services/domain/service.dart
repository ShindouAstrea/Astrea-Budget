import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';
import 'service_schedule.dart';

part 'service.freezed.dart';
part 'service.g.dart';

/// Servicio que el usuario paga (fijo o esporádico).
@freezed
abstract class Service with _$Service {
  const Service._();

  const factory Service({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @Default(ServiceType.fijo) ServiceType type,
    @Default(ServiceCategory.esencial) ServiceCategory category,
    @JsonKey(name: 'estimated_amount') @Default(0) double estimatedAmount,
    @JsonKey(name: 'billing_day') int? billingDay,
    @Default(ServiceFrequency.mensual) ServiceFrequency frequency,
    /// Mes (día 1) del primer cobro: ancla del ciclo para frecuencias no
    /// mensuales. Null en servicios creados antes de existir la columna.
    @JsonKey(name: 'first_charge_month') DateTime? firstChargeMonth,
    /// Categoría de GASTO a la que se imputa el pago (distinta de [category],
    /// que sólo clasifica el servicio en esencial/suscripción). Sin ella, el
    /// gasto no cuenta en los presupuestos por categoría.
    @JsonKey(name: 'category_id') String? expenseCategoryId,
    @Default(true) bool active,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  bool get isFixed => type == ServiceType.fijo;

  /// Meses entre un cobro y el siguiente (0 = no se repite).
  int get periodMonths => periodMonthsOf(frequency);

  /// ¿Le toca cobro en el mes calendario [month]?
  bool occursIn(DateTime month) => occursInMonth(
        frequency: frequency,
        anchor: firstChargeMonth,
        month: month,
      );

  /// Primer mes con cobro desde [from] (incluido). Si el cobro de ese mes ya
  /// venció, salta al período siguiente. Null si ya no habrá más cobros.
  DateTime? nextChargeFrom(DateTime from) {
    final today = DateTime(from.year, from.month, from.day);
    final candidate = nextChargeMonth(
      frequency: frequency,
      anchor: firstChargeMonth,
      from: from,
    );
    if (candidate == null) return null;
    final due = dueDateFor(candidate);
    if (due == null || !due.isBefore(today)) return candidate;
    return nextChargeMonth(
      frequency: frequency,
      anchor: firstChargeMonth,
      from: DateTime(candidate.year, candidate.month + 1),
    );
  }

  /// Fecha de vencimiento dentro de [month] según el día de cobro.
  DateTime? dueDateFor(DateTime month) =>
      billingDay == null ? null : dueDateIn(month, billingDay!);

  /// Genera pagos automáticos sólo si es fijo, activo y con día de cobro.
  bool get autoGenerates => isFixed && active && billingDay != null;
}
