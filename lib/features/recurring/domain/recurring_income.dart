import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_income.freezed.dart';
part 'recurring_income.g.dart';

/// Plantilla de ingreso recurrente (se registra solo cada mes, ej. sueldo).
@freezed
class RecurringIncome with _$RecurringIncome {
  const factory RecurringIncome({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'user_id') required String userId,
    required String description,
    @Default(0) double amount,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'account_id') String? accountId,
    @JsonKey(name: 'day_of_month') required int dayOfMonth,
    @Default(true) bool active,
    @JsonKey(name: 'last_generated') DateTime? lastGenerated,
  }) = _RecurringIncome;

  factory RecurringIncome.fromJson(Map<String, dynamic> json) =>
      _$RecurringIncomeFromJson(json);
}
