import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// Tope mensual de gasto para una categoría dentro de un household.
@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'category_id') required String categoryId,
    @Default(0) double amount,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}
