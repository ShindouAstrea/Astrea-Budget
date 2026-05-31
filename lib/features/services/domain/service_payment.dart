import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';

part 'service_payment.freezed.dart';
part 'service_payment.g.dart';

/// Instancia de pago de un servicio (lo que vence en una fecha concreta).
@freezed
class ServicePayment with _$ServicePayment {
  const ServicePayment._();

  const factory ServicePayment({
    required String id,
    @JsonKey(name: 'service_id') required String serviceId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'due_date') required DateTime dueDate,
    required double amount,
    @Default(PaymentStatus.pendiente) PaymentStatus status,
    @JsonKey(name: 'paid_date') DateTime? paidDate,
    @JsonKey(name: 'transaction_id') String? transactionId,
  }) = _ServicePayment;

  factory ServicePayment.fromJson(Map<String, dynamic> json) =>
      _$ServicePaymentFromJson(json);

  bool get isPaid => status.isPaid;
  bool get isOverdue =>
      !isPaid && dueDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0));
}
