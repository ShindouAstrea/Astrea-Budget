import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/prefs_provider.dart';

/// Caché local de "última lectura" para tolerar falta de conexión: cada fetch
/// exitoso se guarda como JSON en SharedPreferences y, si el fetch falla
/// (p. ej. sin internet), se devuelve la copia guardada en su lugar.
/// Si no hay copia, el error original se propaga (la UI muestra su estado de
/// error con reintento, como siempre).
class LocalCache {
  LocalCache(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'cache:';

  /// Lista de modelos serializables (transacciones, cuentas, categorías…).
  Future<List<T>> fetchList<T>({
    required String key,
    required Future<List<T>> Function() fetch,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final fresh = await fetch();
      await _prefs.setString(
        '$_prefix$key',
        jsonEncode([for (final e in fresh) toJson(e)]),
      );
      return fresh;
    } catch (_) {
      final raw = _prefs.getString('$_prefix$key');
      if (raw == null) rethrow;
      final decoded = jsonDecode(raw) as List;
      return [
        for (final e in decoded) fromJson(e as Map<String, dynamic>),
      ];
    }
  }

  /// Mapa `String → double` (saldos por cuenta).
  Future<Map<String, double>> fetchDoubleMap({
    required String key,
    required Future<Map<String, double>> Function() fetch,
  }) async {
    try {
      final fresh = await fetch();
      await _prefs.setString('$_prefix$key', jsonEncode(fresh));
      return fresh;
    } catch (_) {
      final raw = _prefs.getString('$_prefix$key');
      if (raw == null) rethrow;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
  }
}

final localCacheProvider = Provider<LocalCache>(
  (ref) => LocalCache(ref.watch(sharedPreferencesProvider)),
);
