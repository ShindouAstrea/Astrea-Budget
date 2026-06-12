import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
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
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() async => _auth.signOut();

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
