import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/prefs_provider.dart';

/// Cálculo del "mes financiero" (ciclo de presupuesto) según un día de corte.
///
/// Con día de corte `D` (2..28), el mes etiquetado como, por ejemplo, "Junio"
/// va del **día D de mayo (inclusive)** al **día D de junio (exclusive)**. Así,
/// un ingreso del 30 de mayo (>= D) se planifica en junio.
///
/// Con `D = 1` (default) el ciclo coincide con el mes calendario.
class BudgetCycle {
  const BudgetCycle._();

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Límites `[inicio, fin)` del mes financiero etiquetado por
  /// (`month.year`, `month.month`).
  static ({DateTime start, DateTime end}) bounds(DateTime month, int cutoff) {
    if (cutoff <= 1) {
      return (
        start: DateTime(month.year, month.month, 1),
        end: DateTime(month.year, month.month + 1, 1),
      );
    }
    return (
      start: _startOf(month.year, month.month, cutoff),
      end: _startOf(month.year, month.month + 1, cutoff),
    );
  }

  /// Mes financiero (etiqueta, día 1) al que pertenece [date] según [cutoff].
  /// Inverso de [bounds]: con corte D>1, una fecha con día >= D cuenta para el
  /// mes siguiente.
  static DateTime labelFor(DateTime date, int cutoff) {
    if (cutoff <= 1) return DateTime(date.year, date.month);
    if (date.day >= cutoff) return DateTime(date.year, date.month + 1);
    return DateTime(date.year, date.month);
  }

  /// Inicio del mes financiero (year, month): día `cutoff` del mes anterior.
  /// Si el mes anterior no alcanza ese día (meses cortos), usa el día 1 del mes.
  static DateTime _startOf(int year, int month, int cutoff) {
    final prev = DateTime(year, month - 1, 1); // normaliza el cambio de año
    final prevDays = daysInMonth(prev.year, prev.month);
    if (prevDays >= cutoff) return DateTime(prev.year, prev.month, cutoff);
    return DateTime(year, month, 1);
  }
}

/// Día de corte del mes financiero (1 = mes calendario). Rango 1..28 para que
/// exista en todos los meses (incluido febrero).
class BudgetCutoffNotifier extends Notifier<int> {
  static const _key = 'budget_cutoff_day';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  int build() => _prefs.getInt(_key) ?? 1;

  Future<void> set(int day) async {
    final clamped = day.clamp(1, 28);
    state = clamped;
    await _prefs.setInt(_key, clamped);
  }
}

final budgetCutoffProvider =
    NotifierProvider<BudgetCutoffNotifier, int>(BudgetCutoffNotifier.new);
