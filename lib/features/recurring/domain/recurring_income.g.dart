// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringIncomeImpl _$$RecurringIncomeImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringIncomeImpl(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  userId: json['user_id'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  categoryId: json['category_id'] as String?,
  accountId: json['account_id'] as String?,
  dayOfMonth: (json['day_of_month'] as num).toInt(),
  active: json['active'] as bool? ?? true,
  lastGenerated: json['last_generated'] == null
      ? null
      : DateTime.parse(json['last_generated'] as String),
);

Map<String, dynamic> _$$RecurringIncomeImplToJson(
  _$RecurringIncomeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'user_id': instance.userId,
  'description': instance.description,
  'amount': instance.amount,
  'category_id': instance.categoryId,
  'account_id': instance.accountId,
  'day_of_month': instance.dayOfMonth,
  'active': instance.active,
  'last_generated': instance.lastGenerated?.toIso8601String(),
};
