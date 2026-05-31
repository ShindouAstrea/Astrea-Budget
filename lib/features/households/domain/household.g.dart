// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseholdImpl _$$HouseholdImplFromJson(Map<String, dynamic> json) =>
    _$HouseholdImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      isPersonal: json['is_personal'] as bool? ?? false,
      createdBy: json['created_by'] as String,
    );

Map<String, dynamic> _$$HouseholdImplToJson(_$HouseholdImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_personal': instance.isPersonal,
      'created_by': instance.createdBy,
    };
