import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      state = AsyncError(_friendlyMessage(e), StackTrace.current);
      return false;
    } catch (_) {
      state = AsyncError(
        'Ocurrió un error inesperado. Inténtalo nuevamente.',
        StackTrace.current,
      );
      return false;
    }
  }

  /// Traduce los errores de Supabase a mensajes amigables (sin filtrar
  /// información sensible).
  String _friendlyMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login')) return 'Correo o contraseña incorrectos';
    if (msg.contains('already registered') ||
        msg.contains('already exists') ||
        msg.contains('already in use')) {
      return 'Ya existe una cuenta con este correo';
    }
    if (msg.contains('anonymous sign-ins are disabled')) {
      return 'El modo invitado no está habilitado. '
          'Activa "Anonymous sign-ins" en el dashboard de Supabase.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión';
    }
    if (msg.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento e inténtalo de nuevo';
    }
    if (msg.contains('password')) {
      return 'La contraseña no cumple los requisitos (mínimo 6 caracteres)';
    }
    // Falla del trigger de base de datos (típicamente el schema.sql no se ha
    // ejecutado en Supabase). Mostramos la causa para no dejarlo a ciegas.
    if (msg.contains('database error')) {
      return 'Error de base de datos al crear el usuario. '
          'Verifica que ejecutaste supabase/schema.sql en tu proyecto.';
    }
    // Para errores no contemplados, exponemos el mensaje real (sin datos
    // sensibles) para facilitar el diagnóstico.
    return e.message.isNotEmpty
        ? 'No se pudo completar: ${e.message}'
        : 'No se pudo completar la acción. Verifica tus datos';
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
