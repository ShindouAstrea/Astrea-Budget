// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceImpl _$$ServiceImplFromJson(Map<String, dynamic> json) =>
    _$ServiceImpl(
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
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$$ServiceImplToJson(_$ServiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'type': _$ServiceTypeEnumMap[instance.type]!,
      'category': _$ServiceCategoryEnumMap[instance.category]!,
      'estimated_amount': instance.estimatedAmount,
      'billing_day': instance.billingDay,
      'frequency': _$ServiceFrequencyEnumMap[instance.frequency]!,
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
  ServiceFrequency.anual: 'anual',
  ServiceFrequency.unico: 'unico',
};
