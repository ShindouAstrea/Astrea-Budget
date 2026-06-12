// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  householdId: json['household_id'] as String?,
  accountId: json['account_id'] as String?,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  serviceId: json['service_id'] as String?,
  transferGroupId: json['transfer_group_id'] as String?,
  installmentGroupId: json['installment_group_id'] as String?,
  installmentsTotal: (json['installments_total'] as num?)?.toInt(),
  installmentNumber: (json['installment_number'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'household_id': instance.householdId,
  'account_id': instance.accountId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'description': instance.description,
  'category_id': instance.categoryId,
  'service_id': instance.serviceId,
  'transfer_group_id': instance.transferGroupId,
  'installment_group_id': instance.installmentGroupId,
  'installments_total': instance.installmentsTotal,
  'installment_number': instance.installmentNumber,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};
