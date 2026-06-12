import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/budget_cycle.dart';
import '../../categories/presentation/categories_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../../notifications/data/notification_service.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import 'budget_repository.dart';

/// Nivel de alerta de una categoría frente a su tope: 0 = bajo el 80%,
/// 1 = advertencia (>= 80%), 2 = tope superado.
int budgetAlertLevel(double spent, double limit) {
  if (limit <= 0) return 0;
  if (spent > limit) return 2;
  if (spent >= limit * 0.8) return 1;
  return 0;
}

/// Notifica (una sola vez por nivel y por ciclo) cuando el gasto de una
/// categoría cruza el 80% o el 100% de su tope mensual. Se invoca después de
/// registrar/editar un gasto; cualquier error se ignora en silencio para no
/// interferir con el guardado.
class BudgetAlertService {
  BudgetAlertService(this.ref);

  final Ref ref;

  static const _levelPrefix = 'budget_alert_level';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  /// Revisa la categoría del gasto recién guardado y notifica si su ciclo
  /// cruzó un umbral nuevo (80% o 100% del tope).
  Future<void> checkCategory({
    required String categoryId,
    required DateTime date,
  }) async {
    try {
      // Requiere notificaciones activadas (permiso ya concedido) y la alerta
      // de presupuesto no desactivada en ajustes.
      if (!ref.read(notificationsControllerProvider).enabled ||
          !ref.read(budgetAlertsEnabledProvider)) {
        return;
      }

      final householdId = await ref.read(activeHouseholdIdProvider.future);
      final budgets =
          await ref.read(budgetRepositoryProvider).fetchByHousehold(householdId);
      var limit = 0.0;
      for (final b in budgets) {
        if (b.categoryId == categoryId) limit = b.amount;
      }
      if (limit <= 0) return;

      // Gasto acumulado de la categoría en el ciclo al que pertenece el gasto.
      final cutoff = ref.read(budgetCutoffProvider);
      final label = BudgetCycle.labelFor(date, cutoff);
      final bounds = BudgetCycle.bounds(label, cutoff);
      final txs = await ref
          .read(transactionRepositoryProvider)
          .fetchBetween(householdId, bounds.start, bounds.end);
      final spent = txs
          .where((t) => !t.isIncome && t.categoryId == categoryId)
          .fold<double>(0, (s, t) => s + t.amount);

      final level = budgetAlertLevel(spent, limit);
      final key = '$_levelPrefix:$householdId:$categoryId:'
          '${label.year}-${label.month.toString().padLeft(2, '0')}';
      final previous = _prefs.getInt(key) ?? 0;
      await _prefs.setInt(key, level); // bajar de nivel re-arma la alerta

      if (level <= previous) return;

      final categories = await ref.read(categoriesProvider.future);
      String? name;
      for (final c in categories) {
        if (c.id == categoryId) name = c.name;
      }
      if (name == null) return;

      final percent = (spent / limit * 100).round();
      await ref.read(notificationServiceProvider).showBudgetAlert(
            // Id estable por categoría: una alerta nueva reemplaza la anterior.
            id: 200000 + categoryId.hashCode.abs() % 9999,
            title: level == 2 ? 'Tope superado' : 'Presupuesto casi al límite',
            body: level == 2
                ? '$name superó su tope: llevas ${Formatters.currency(spent)} '
                    'de ${Formatters.currency(limit)}.'
                : '$name va en el $percent% de su tope '
                    '(${Formatters.currency(spent)} de ${Formatters.currency(limit)}).',
          );
    } catch (e) {
      if (kDebugMode) debugPrint('[BudgetAlert] check falló: $e');
    }
  }
}

final budgetAlertServiceProvider =
    Provider<BudgetAlertService>(BudgetAlertService.new);

/// Preferencia "alertas de presupuesto" (por defecto activadas). Sólo tienen
/// efecto si las notificaciones generales están activadas.
class BudgetAlertsEnabled extends Notifier<bool> {
  static const _key = 'budget_alerts_enabled';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() => _prefs.getBool(_key) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
}

final budgetAlertsEnabledProvider =
    NotifierProvider<BudgetAlertsEnabled, bool>(BudgetAlertsEnabled.new);
