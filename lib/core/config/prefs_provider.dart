import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instancia de SharedPreferences. Se sobrescribe en `main()` con la instancia
/// ya inicializada para poder leerla de forma síncrona.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Debe sobrescribirse en main()'),
);
