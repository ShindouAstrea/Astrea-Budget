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
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'service_id') String? serviceId,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  bool get isIncome => type.isIncome;
}
