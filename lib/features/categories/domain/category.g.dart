// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#2563EB',
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'icon': instance.icon,
      'color': instance.color,
      'is_default': instance.isDefault,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
