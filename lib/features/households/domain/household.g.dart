// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Household _$HouseholdFromJson(Map<String, dynamic> json) => _Household(
  id: json['id'] as String,
  name: json['name'] as String,
  isPersonal: json['is_personal'] as bool? ?? false,
  createdBy: json['created_by'] as String,
);

Map<String, dynamic> _$HouseholdToJson(_Household instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_personal': instance.isPersonal,
      'created_by': instance.createdBy,
    };
