import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_error_messages.dart';
import '../data/auth_repository.dart';

/// Controla las acciones de autenticación y expone su estado de carga/error.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn(String email, String password) =>
      _run(() => ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          ));

  Future<bool> signUp(String email, String password, String name) =>
      _run(() => ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            name: name,
          ));

  Future<bool> signInAsGuest() =>
      _run(() => ref.read(authRepositoryProvider).signInAnonymously());

  Future<bool> linkAccount(String email, String password, String name) =>
      _run(() => ref.read(authRepositoryProvider).linkAccount(
            email: email,
            password: password,
            name: name,
          ));

  Future<bool> sendPasswordReset(String email) =>
      _run(() => ref.read(authRepositoryProvider).sendPasswordReset(email));

  /// Define la contraseña nueva tras llegar por el enlace de recuperación.
  Future<bool> updatePassword(String password) =>
      _run(() => ref.read(authRepositoryProvider).updatePassword(password));

  Future<bool> signOut() =>
      _run(() => ref.read(authRepositoryProvider).signOut());

  /// Cierra la sesión de un invitado eliminando su cuenta y todos sus datos.
  Future<bool> deleteGuestAccount() =>
      _run(() => ref.read(authRepositoryProvider).deleteGuestAccount());

  /// Ejecuta una acción async actualizando el estado y traduciendo errores.
  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } on AuthException catch (e) {
      state = AsyncError(authErrorMessage(e), StackTrace.current);
      return false;
    } catch (_) {
      state = AsyncError(
        'Ocurrió un error inesperado. Inténtalo nuevamente.',
        StackTrace.current,
      );
      return false;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// ¿El usuario llegó por un enlace de recuperación y aún no define su nueva
/// contraseña?
///
/// La sesión que crea ese enlace es una sesión normal para Supabase, así que
/// sin esta bandera el guard del router lo mandaría directo al inicio y nunca
/// vería la pantalla para cambiarla. La levanta el router al recibir el evento
/// `passwordRecovery` y la baja la pantalla al guardar (o al cancelar).
class PasswordRecoveryNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;

  void finish() => state = false;
}

final passwordRecoveryProvider =
    NotifierProvider<PasswordRecoveryNotifier, bool>(
  PasswordRecoveryNotifier.new,
);

/// Último error de un enlace de correo (recuperar contraseña o confirmar
/// cuenta), pendiente de mostrarse.
///
/// Cuando el enlace falla, Supabase no lanza la excepción hacia quien la pidió:
/// la publica como error del stream `onAuthStateChange`. Nadie la escuchaba, y
/// como sin sesión el guard manda al login, la app se abría ahí muda. El router
/// deja aquí el mensaje y la pantalla de login lo muestra.
class AuthLinkErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void report(String message) => state = message;

  /// La consume la pantalla que ya la mostró, para no repetirla.
  void clear() => state = null;
}

final authLinkErrorProvider =
    NotifierProvider<AuthLinkErrorNotifier, String?>(
  AuthLinkErrorNotifier.new,
);
