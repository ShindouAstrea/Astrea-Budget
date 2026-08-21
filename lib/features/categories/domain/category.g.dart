// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  icon: json['icon'] as String? ?? 'category',
  color: json['color'] as String? ?? '#2563EB',
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
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
