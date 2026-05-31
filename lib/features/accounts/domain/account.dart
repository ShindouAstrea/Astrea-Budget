import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/enums.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// Cuenta / billetera (efectivo, débito, crédito, ahorro) de un household.
@freezed
class Account with _$Account {
  const Account._();

  const factory Account({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @Default(AccountType.debito) AccountType type,
    @JsonKey(name: 'initial_balance') @Default(0) double initialBalance,
    // Campos de crédito (sólo cuando type == credito).
    @JsonKey(name: 'credit_limit') double? creditLimit,
    @JsonKey(name: 'statement_day') int? statementDay,
    @JsonKey(name: 'payment_due_day') int? paymentDueDay,
    @Default('#2563EB') String color,
    @Default('account_balance_wallet') String icon,
    @Default(false) bool archived,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  bool get isCredit => type.isCredit;

  Color get colorValue => AppColors.fromHex(color);

  IconData get iconData => kAccountIcons[icon] ?? Icons.account_balance_wallet;
}

/// Íconos disponibles para cuentas (nombres estables guardados en BD).
const Map<String, IconData> kAccountIcons = {
  'account_balance_wallet': Icons.account_balance_wallet,
  'account_balance': Icons.account_balance,
  'credit_card': Icons.credit_card,
  'savings': Icons.savings,
  'payments': Icons.payments,
  'attach_money': Icons.attach_money,
};
