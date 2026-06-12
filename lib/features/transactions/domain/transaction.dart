import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Movimiento de dinero (ingreso o gasto).
@freezed
class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'household_id') String? householdId,
    @JsonKey(name: 'account_id') String? accountId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'service_id') String? serviceId,
    @JsonKey(name: 'transfer_group_id') String? transferGroupId,
    // Compras en cuotas: N filas (una por mes) con el mismo grupo.
    @JsonKey(name: 'installment_group_id') String? installmentGroupId,
    @JsonKey(name: 'installments_total') int? installmentsTotal,
    @JsonKey(name: 'installment_number') int? installmentNumber,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isIncome => type.isIncome;
  bool get isTransfer => transferGroupId != null;
  bool get isInstallment => installmentGroupId != null;

  /// `Cuota 2/12` o null si no es una compra en cuotas.
  String? get installmentLabel =>
      isInstallment ? 'Cuota $installmentNumber/$installmentsTotal' : null;
}
