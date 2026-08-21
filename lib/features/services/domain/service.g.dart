// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  type:
      $enumDecodeNullable(_$ServiceTypeEnumMap, json['type']) ??
      ServiceType.fijo,
  category:
      $enumDecodeNullable(_$ServiceCategoryEnumMap, json['category']) ??
      ServiceCategory.esencial,
  estimatedAmount: (json['estimated_amount'] as num?)?.toDouble() ?? 0,
  billingDay: (json['billing_day'] as num?)?.toInt(),
  frequency:
      $enumDecodeNullable(_$ServiceFrequencyEnumMap, json['frequency']) ??
      ServiceFrequency.mensual,
  firstChargeMonth: json['first_charge_month'] == null
      ? null
      : DateTime.parse(json['first_charge_month'] as String),
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'type': _$ServiceTypeEnumMap[instance.type]!,
  'category': _$ServiceCategoryEnumMap[instance.category]!,
  'estimated_amount': instance.estimatedAmount,
  'billing_day': instance.billingDay,
  'frequency': _$ServiceFrequencyEnumMap[instance.frequency]!,
  'first_charge_month': instance.firstChargeMonth?.toIso8601String(),
  'active': instance.active,
};

const _$ServiceTypeEnumMap = {
  ServiceType.fijo: 'fijo',
  ServiceType.esporadico: 'esporadico',
};

const _$ServiceCategoryEnumMap = {
  ServiceCategory.esencial: 'esencial',
  ServiceCategory.suscripcion: 'suscripcion',
};

const _$ServiceFrequencyEnumMap = {
  ServiceFrequency.mensual: 'mensual',
  ServiceFrequency.bimestral: 'bimestral',
  ServiceFrequency.trimestral: 'trimestral',
  ServiceFrequency.semestral: 'semestral',
  ServiceFrequency.anual: 'anual',
  ServiceFrequency.unico: 'unico',
};
