import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente Supabase compartido por toda la app.
///
/// `Supabase.initialize(...)` se ejecuta una sola vez en `main()`; aquí sólo
/// exponemos la instancia ya inicializada como provider para inyectarla en los
/// repositorios.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
