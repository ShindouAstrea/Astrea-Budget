import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';

part 'service_payment.freezed.dart';
part 'service_payment.g.dart';

/// Instancia de pago de un servicio (lo que vence en una fecha concreta).
@freezed
abstract class ServicePayment with _$ServicePayment {
  const ServicePayment._();

  const factory ServicePayment({
    required String id,
    @JsonKey(name: 'service_id') required String serviceId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'due_date') required DateTime dueDate,
    required double amount,
    /// El monto de este período se ajustó a mano: no se pisa al editar el
    /// monto estimado del servicio ni al regenerar el mes.
    @JsonKey(name: 'amount_overridden') @Default(false) bool amountOverridden,
    @Default(PaymentStatus.pendiente) PaymentStatus status,
    @JsonKey(name: 'paid_date') DateTime? paidDate,
    @JsonKey(name: 'transaction_id') String? transactionId,
  }) = _ServicePayment;

  factory ServicePayment.fromJson(Map<String, dynamic> json) =>
      _$ServicePaymentFromJson(json);

  bool get isPaid => status.isPaid;

  /// Vencido = pendiente y con fecha ANTERIOR a hoy. Lo que vence hoy todavía
  /// no está vencido (por eso se compara contra el día, no contra `now`).
  bool get isOverdue => !isPaid && isOverdueAt(DateTime.now());

  bool isOverdueAt(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return !isPaid &&
        DateTime(dueDate.year, dueDate.month, dueDate.day).isBefore(today);
  }
}
