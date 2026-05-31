import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de entorno.
///
/// Las variables se cargan en runtime desde el archivo `.env` (ver
/// `flutter_dotenv`), por lo que el botón Run/Debug del IDE funciona sin pasar
/// `--dart-define`. El `.env` está en `.gitignore`: copia `.env.example` a
/// `.env` y completa tus valores.
class Env {
  const Env._();

  /// Carga el archivo `.env`. Tolera su ausencia (la app mostrará la pantalla
  /// de configuración faltante en vez de fallar).
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env ausente o vacío: isConfigured devolverá false.
    }
  }

  static String get supabaseUrl => dotenv.maybeGet('SUPABASE_URL') ?? '';

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  /// Locale y moneda por defecto (Chile).
  static const String defaultLocale = 'es_CL';
  static const String defaultCurrency = 'CLP';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
