import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';

part 'service.freezed.dart';
part 'service.g.dart';

/// Servicio que el usuario paga (fijo o esporádico).
@freezed
class Service with _$Service {
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
    @Default(true) bool active,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  bool get isFixed => type == ServiceType.fijo;
}
