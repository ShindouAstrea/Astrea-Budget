import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mes actualmente seleccionado (normalizado al día 1). Compartido entre el
/// dashboard, el historial de transacciones y los servicios para mantener la
/// navegación de meses consistente.
class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);
  void next() => state = DateTime(state.year, state.month + 1);
  void set(DateTime month) => state = DateTime(month.year, month.month);
  void reset() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month);
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);
