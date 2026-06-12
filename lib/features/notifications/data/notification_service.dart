import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio de notificaciones locales (recordatorios de pago).
///
/// Usa zona horaria fija de Chile (la app es es_CL). La base de datos tz
/// maneja el horario de verano de `America/Santiago`.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'service_reminders';
  static const _channelName = 'Recordatorios de pago';
  static const _channelDesc =
      'Avisos de servicios fijos próximos a vencer.';

  static const _budgetChannelId = 'budget_alerts';
  static const _budgetChannelName = 'Alertas de presupuesto';
  static const _budgetChannelDesc =
      'Avisos cuando una categoría se acerca o supera su tope mensual.';

  /// Inicializa el plugin y la base de zonas horarias. Idempotente.
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Santiago'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      // El permiso se pide explícitamente en requestPermission().
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    _initialized = true;
  }

  /// Solicita permiso de notificaciones. Devuelve true si quedó concedido.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        // Mostrar también cuando la app está en primer plano (iOS).
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      );

  static const _budgetDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _budgetChannelId,
      _budgetChannelName,
      channelDescription: _budgetChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
    ),
  );

  /// Muestra una notificación inmediata en el canal de alertas de presupuesto.
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    try {
      await _plugin.show(id, title, body, _budgetDetails);
    } catch (e) {
      if (kDebugMode) debugPrint('[Notif] no se pudo mostrar: $e');
    }
  }

  /// Envía una notificación de prueba ~5 segundos en el futuro. Útil para
  /// verificar el pipeline (permiso + canal + despliegue) sin esperar.
  Future<void> sendTest() async {
    await schedule(
      id: 999999,
      title: 'Prueba de notificación',
      body: 'Si ves esto, los recordatorios funcionan ✅',
      when: DateTime.now().add(const Duration(seconds: 5)),
    );
  }

  /// Programa una notificación para [when] (si es futura).
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details,
        // Inexacto: no requiere el permiso especial SCHEDULE_EXACT_ALARM y
        // basta para un recordatorio diario.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Notif] no se pudo programar: $e');
    }
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
