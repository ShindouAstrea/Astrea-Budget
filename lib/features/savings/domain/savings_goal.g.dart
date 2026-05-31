// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsGoalImpl _$$SavingsGoalImplFromJson(Map<String, dynamic> json) =>
    _$SavingsGoalImpl(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      targetDate: json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String),
      accountId: json['account_id'] as String?,
      icon: json['icon'] as String? ?? 'savings',
      color: json['color'] as String? ?? '#16A34A',
    );

Map<String, dynamic> _$$SavingsGoalImplToJson(_$SavingsGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'user_id': instance.userId,
      'name': instance.name,
      'target_amount': instance.targetAmount,
      'current_amount': instance.currentAmount,
      'target_date': instance.targetDate?.toIso8601String(),
      'account_id': instance.accountId,
      'icon': instance.icon,
      'color': instance.color,
    };
