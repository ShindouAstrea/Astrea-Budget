// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  categoryId: json['category_id'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'category_id': instance.categoryId,
  'amount': instance.amount,
};
