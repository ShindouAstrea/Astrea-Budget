import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';
import '../../categories/domain/category.dart' show kCategoryIcons;

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

/// Meta de ahorro: objetivo, monto ahorrado y (opcional) fecha límite.
@freezed
class SavingsGoal with _$SavingsGoal {
  const SavingsGoal._();

  const factory SavingsGoal({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'target_amount') @Default(0) double targetAmount,
    @JsonKey(name: 'current_amount') @Default(0) double currentAmount,
    @JsonKey(name: 'target_date') DateTime? targetDate,
    @JsonKey(name: 'account_id') String? accountId,
    @Default('savings') String icon,
    @Default('#16A34A') String color,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);

  double get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Avance 0..1 hacia la meta.
  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isComplete => currentAmount >= targetAmount;

  Color get colorValue => AppColors.fromHex(color);
  IconData get iconData => kCategoryIcons[icon] ?? Icons.savings;

  /// Meses completos restantes hasta la fecha objetivo (null si no hay fecha).
  int? get monthsLeft {
    final date = targetDate;
    if (date == null) return null;
    final now = DateTime.now();
    final months =
        (date.year - now.year) * 12 + (date.month - now.month);
    return months < 0 ? 0 : months;
  }

  /// Aporte mensual sugerido para llegar a tiempo (null si no aplica).
  double? get suggestedMonthly {
    final left = monthsLeft;
    if (left == null || isComplete) return null;
    if (left <= 0) return remaining; // vence este mes o ya pasó
    return remaining / left;
  }
}
