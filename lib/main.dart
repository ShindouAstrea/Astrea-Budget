import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/config/prefs_provider.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Mantiene el splash nativo visible durante toda la inicialización
  // (Supabase, prefs, localización) en vez de ocultarse al primer frame.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Carga las variables de entorno desde el archivo .env.
  await Env.load();

  // Datos de localización para es_CL (formato de fechas/números).
  await initializeDateFormatting('es_CL');

  // Preferencias locales (modo de tema y paleta), leídas de forma síncrona
  // después por el ThemeController vía sharedPreferencesProvider.
  final prefs = await SharedPreferences.getInstance();

  if (!Env.isConfigured) {
    // Falta configurar Supabase: mostramos una pantalla guía en vez de crashear.
    runApp(const _MissingConfigApp());
    widgetsBinding.addPostFrameCallback((_) => FlutterNativeSplash.remove());
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AstreaBudgetApp(),
    ),
  );

  // Quita el splash una vez pintado el primer frame de la app.
  widgetsBinding.addPostFrameCallback((_) => FlutterNativeSplash.remove());
}

/// Pantalla mostrada cuando faltan las variables de entorno de Supabase.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Configura Supabase',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Falta definir SUPABASE_URL y SUPABASE_ANON_KEY.\n'
                  'Ejecuta la app con --dart-define (ver README).',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
