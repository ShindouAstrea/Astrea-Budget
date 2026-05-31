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

  Future<void> signUp({required String email, required String password}) async {
    await _auth.signUp(email: email.trim(), password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() async => _auth.signOut();
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
