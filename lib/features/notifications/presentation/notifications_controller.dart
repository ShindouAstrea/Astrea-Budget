import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../households/presentation/household_controller.dart';
import '../../services/data/service_repository.dart';
import '../../services/presentation/services_controller.dart';
import '../data/notification_service.dart';

/// Configuración de recordatorios: activado + hora del día del aviso.
class NotificationSettings {
  const NotificationSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  NotificationSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

/// Activa/desactiva los recordatorios, define la hora del aviso y reprograma
/// las notificaciones de los servicios fijos con pagos pendientes
/// (vencimiento-3 días hasta el día mismo, a la hora elegida).
class NotificationsController extends Notifier<NotificationSettings> {
  static const _kEnabled = 'notifications_enabled';
  static const _kHour = 'notifications_hour';
  static const _kMinute = 'notifications_minute';
  static const _daysBefore = [3, 2, 1, 0];

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  NotificationSettings build() {
    return NotificationSettings(
      enabled: _prefs.getBool(_kEnabled) ?? false,
      time: TimeOfDay(
        hour: _prefs.getInt(_kHour) ?? 9,
        minute: _prefs.getInt(_kMinute) ?? 0,
      ),
    );
  }

  /// Activa o desactiva los recordatorios. Al activar pide permiso; si se
  /// deniega, devuelve false y no queda activado.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      final granted =
          await ref.read(notificationServiceProvider).requestPermission();
      if (!granted) return false;
    }
    state = state.copyWith(enabled: enabled);
    await _prefs.setBool(_kEnabled, enabled);
    await refresh();
    return true;
  }

  /// Cambia la hora del aviso y reprograma.
  Future<void> setTime(TimeOfDay time) async {
    state = state.copyWith(time: time);
    await _prefs.setInt(_kHour, time.hour);
    await _prefs.setInt(_kMinute, time.minute);
    await refresh();
  }

  /// Dispara una notificación de prueba (~5s). Solo para depuración.
  Future<void> sendTest() => ref.read(notificationServiceProvider).sendTest();

  /// Cancela y reprograma todos los recordatorios según los pagos pendientes.
  Future<void> refresh() async {
    final service = ref.read(notificationServiceProvider);
    await service.init();
    await service.cancelAll();
    if (!state.enabled) return;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final householdId = await ref.read(activeHouseholdIdProvider.future);
      final pending = await ref
          .read(serviceRepositoryProvider)
          .fetchPendingFrom(householdId, today);
      final services = await ref.read(servicesProvider.future);
      final byId = {for (final s in services) s.id: s};
      final t = state.time;

      var id = 0;
      for (final payment in pending) {
        final svc = byId[payment.serviceId];
        // Solo servicios fijos activos (los esporádicos no recuerdan).
        if (svc == null || !svc.isFixed || !svc.active) continue;

        for (final offset in _daysBefore) {
          final due = payment.dueDate;
          final when = DateTime(
            due.year,
            due.month,
            due.day - offset,
            t.hour,
            t.minute,
          );
          final isDueDay = offset == 0;
          await service.schedule(
            id: id++,
            title: isDueDay ? 'Vence hoy' : 'Pago próximo',
            body: '${svc.name} · ${Formatters.currency(payment.amount)} '
                '(vence ${Formatters.dayMonthYear(due)})',
            when: when,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Notif] refresh falló: $e');
    }
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationSettings>(
  NotificationsController.new,
);
