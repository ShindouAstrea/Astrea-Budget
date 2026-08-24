import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/deep_links.dart';
import '../../../core/config/supabase_provider.dart';

/// Encapsula todas las llamadas a Supabase Auth.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;

  /// Emite un evento cada vez que cambia el estado de sesión.
  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  /// En móvil los correos deben volver a la app por deep link; en web/escritorio
  /// no hay esquema propio que registrar, así que se deja el Site URL del
  /// proyecto.
  String? _redirect(String link) => kIsWeb ? null : link;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
      emailRedirectTo: _redirect(kEmailConfirmRedirect),
    );
  }

  /// Crea una sesión de invitado (usuario anónimo de Supabase). Sus datos
  /// viven en la nube igual que los de una cuenta normal; si después se
  /// registra vía [linkAccount], conserva el mismo usuario y todos sus datos.
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  /// Convierte al invitado actual en cuenta permanente asociándole correo y
  /// contraseña. Si el proyecto exige confirmación de correo, queda pendiente
  /// hasta que el usuario confirme; si no, la conversión es inmediata (queda
  /// `emailConfirmedAt`). El `user_id` (y por tanto todos los datos) no cambia.
  Future<void> linkAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    await _auth.updateUser(
      UserAttributes(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      ),
      emailRedirectTo: _redirect(kEmailConfirmRedirect),
    );
  }

  /// Envía el correo de recuperación. `redirectTo` es lo que hace que el enlace
  /// abra la app (pantalla de nueva contraseña) en vez del Site URL del
  /// proyecto, que por defecto es localhost.
  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: _redirect(kPasswordResetRedirect),
    );
  }

  /// Define la contraseña nueva. Sólo funciona con la sesión temporal que crea
  /// el enlace de recuperación (o con una sesión normal ya iniciada).
  Future<void> updatePassword(String password) async {
    await _auth.updateUser(UserAttributes(password: password));
  }

  /// Cierra la sesión. El SDK borra la sesión local **antes** de avisar al
  /// servidor, así que aunque esa llamada falle (sin conexión, token ya
  /// vencido) el usuario queda igualmente fuera. Propagar el error sólo
  /// conseguía mostrar "no se pudo cerrar sesión" sobre una sesión ya cerrada:
  /// el mensaje contradecía lo que el usuario veía pasar.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (_) {
      // Sesión local ya limpiada; el refresh token caduca solo en el servidor.
    }
  }

  /// Elimina la cuenta de invitado y TODOS sus datos (el borrado en
  /// `auth.users` cascadea a perfil, household, transacciones, etc.) y luego
  /// limpia la sesión local. La sesión anónima no es recuperable, así que sin
  /// esto los datos quedarían huérfanos para siempre en la base de datos.
  Future<void> deleteGuestAccount() async {
    await _client.rpc('delete_own_guest_account');
    // El usuario ya no existe en el servidor: solo hay que limpiar la sesión
    // local (un signOut global fallaría contra un usuario eliminado).
    await _auth.signOut(scope: SignOutScope.local);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

/// Stream del estado de autenticación (usado por el guard del router).
final authStateChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Usuario actual (o null). Se recalcula con cada cambio de sesión.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

/// True si la sesión actual es de invitado (usuario anónimo sin correo).
final isGuestProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider)?.isAnonymous ?? false,
);
