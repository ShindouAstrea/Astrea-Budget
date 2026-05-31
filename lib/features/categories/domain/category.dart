import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/enums.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Categoría de transacción (ingreso o gasto).
@freezed
class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required TransactionType type,
    @Default('category') String icon,
    @Default('#2563EB') String color,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Color resuelto a [Color] de Flutter.
  Color get colorValue => AppColors.fromHex(color);

  /// Ícono Material resuelto desde el nombre guardado.
  IconData get iconData => kCategoryIcons[icon] ?? Icons.category;
}

/// Mapa de nombres de ícono (guardados en BD) a [IconData]. Usamos nombres
/// estables en vez de codePoints para que sea legible y portable.
const Map<String, IconData> kCategoryIcons = {
  'category': Icons.category,
  'payments': Icons.payments,
  'savings': Icons.savings,
  'home': Icons.home,
  'restaurant': Icons.restaurant,
  'directions_bus': Icons.directions_bus,
  'bolt': Icons.bolt,
  'favorite': Icons.favorite,
  'sports_esports': Icons.sports_esports,
  'subscriptions': Icons.subscriptions,
  'more_horiz': Icons.more_horiz,
  'shopping_cart': Icons.shopping_cart,
  'school': Icons.school,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'fitness_center': Icons.fitness_center,
  'phone_android': Icons.phone_android,
  'card_giftcard': Icons.card_giftcard,
};
