import 'package:freezed_annotation/freezed_annotation.dart';

part 'household.freezed.dart';
part 'household.g.dart';

/// Presupuesto compartido (o personal) al que pertenecen los datos del usuario.
@freezed
class Household with _$Household {
  const factory Household({
    required String id,
    required String name,
    @JsonKey(name: 'is_personal') @Default(false) bool isPersonal,
    @JsonKey(name: 'created_by') required String createdBy,
  }) = _Household;

  factory Household.fromJson(Map<String, dynamic> json) =>
      _$HouseholdFromJson(json);
}
