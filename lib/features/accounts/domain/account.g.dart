// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type:
          $enumDecodeNullable(_$AccountTypeEnumMap, json['type']) ??
          AccountType.debito,
      initialBalance: (json['initial_balance'] as num?)?.toDouble() ?? 0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble(),
      statementDay: (json['statement_day'] as num?)?.toInt(),
      paymentDueDay: (json['payment_due_day'] as num?)?.toInt(),
      color: json['color'] as String? ?? '#2563EB',
      icon: json['icon'] as String? ?? 'account_balance_wallet',
      archived: json['archived'] as bool? ?? false,
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'user_id': instance.userId,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'initial_balance': instance.initialBalance,
      'credit_limit': instance.creditLimit,
      'statement_day': instance.statementDay,
      'payment_due_day': instance.paymentDueDay,
      'color': instance.color,
      'icon': instance.icon,
      'archived': instance.archived,
    };

const _$AccountTypeEnumMap = {
  AccountType.efectivo: 'efectivo',
  AccountType.debito: 'debito',
  AccountType.credito: 'credito',
  AccountType.ahorro: 'ahorro',
};
