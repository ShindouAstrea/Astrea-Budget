// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServicePaymentImpl _$$ServicePaymentImplFromJson(Map<String, dynamic> json) =>
    _$ServicePaymentImpl(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      userId: json['user_id'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.pendiente,
      paidDate: json['paid_date'] == null
          ? null
          : DateTime.parse(json['paid_date'] as String),
      transactionId: json['transaction_id'] as String?,
    );

Map<String, dynamic> _$$ServicePaymentImplToJson(
  _$ServicePaymentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'service_id': instance.serviceId,
  'user_id': instance.userId,
  'due_date': instance.dueDate.toIso8601String(),
  'amount': instance.amount,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'paid_date': instance.paidDate?.toIso8601String(),
  'transaction_id': instance.transactionId,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pendiente: 'pendiente',
  PaymentStatus.pagado: 'pagado',
};
