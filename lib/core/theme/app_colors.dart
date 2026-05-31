import 'package:flutter/material.dart';

/// Paleta semántica de Astrea Budget.
///
/// Azul confianza como color de marca (fintech), con verde para ingresos y
/// rojo para gastos. Estos tokens se exponen además vía [ThemeExtension] para
/// que funcionen en modo claro y oscuro sin hardcodear hex en los widgets.
class AppColors {
  const AppColors._();

  // Marca
  static const Color brand = Color(0xFF2563EB); // azul confianza (seed)
  static const Color accent = Color(0xFFF97316); // naranja CTA / FAB

  // Semántica financiera — modo claro
  static const Color incomeLight = Color(0xFF16A34A);
  static const Color expenseLight = Color(0xFFDC2626);

  // Semántica financiera — modo oscuro (variantes más claras/desaturadas)
  static const Color incomeDark = Color(0xFF4ADE80);
  static const Color expenseDark = Color(0xFFF87171);

  /// Paleta para los segmentos del gráfico de gasto por categoría.
  static const List<Color> chartPalette = [
    Color(0xFF2563EB),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEAB308),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF64748B),
  ];

  /// Convierte un color hex (`#RRGGBB` o `#AARRGGBB`) a [Color].
  static Color fromHex(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }
}

/// Tokens semánticos sensibles al tema (claro/oscuro).
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({required this.income, required this.expense});

  final Color income;
  final Color expense;

  static const light = FinanceColors(
    income: AppColors.incomeLight,
    expense: AppColors.expenseLight,
  );

  static const dark = FinanceColors(
    income: AppColors.incomeDark,
    expense: AppColors.expenseDark,
  );

  @override
  FinanceColors copyWith({Color? income, Color? expense}) => FinanceColors(
        income: income ?? this.income,
        expense: expense ?? this.expense,
      );

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) {
    if (other is! FinanceColors) return this;
    return FinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }
}

/// Acceso ergonómico a los tokens semánticos desde el contexto.
extension FinanceColorsX on BuildContext {
  FinanceColors get finance => Theme.of(this).extension<FinanceColors>()!;
}
