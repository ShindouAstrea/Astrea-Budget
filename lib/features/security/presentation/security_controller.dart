import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/security_repository.dart';

/// Estado de los ajustes de seguridad local.
class SecuritySettings {
  const SecuritySettings({
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.canUseBiometrics,
  });

  final bool pinEnabled;
  final bool biometricEnabled;
  final bool canUseBiometrics;

  static const initial = SecuritySettings(
    pinEnabled: false,
    biometricEnabled: false,
    canUseBiometrics: false,
  );
}

/// Carga y administra la configuración de seguridad (PIN / biometría).
class SecurityController extends AsyncNotifier<SecuritySettings> {
  SecurityRepository get _repo => ref.read(securityRepositoryProvider);

  @override
  Future<SecuritySettings> build() async {
    return SecuritySettings(
      pinEnabled: await _repo.isPinEnabled,
      biometricEnabled: await _repo.isBiometricEnabled,
      canUseBiometrics: await _repo.canUseBiometrics,
    );
  }

  Future<void> setPin(String pin) async {
    await _repo.setPin(pin);
    ref.invalidateSelf();
    await future;
  }

  Future<void> disablePin() async {
    await _repo.disablePin();
    // Al deshabilitar el PIN, la app deja de estar bloqueada.
    ref.read(appLockProvider.notifier).unlock();
    ref.invalidateSelf();
    await future;
  }

  Future<void> setBiometric(bool enabled) async {
    await _repo.setBiometricEnabled(enabled);
    ref.invalidateSelf();
    await future;
  }
}

final securityControllerProvider =
    AsyncNotifierProvider<SecurityController, SecuritySettings>(
  SecurityController.new,
);

/// Indica si la app está bloqueada (requiere PIN/biometría para continuar).
///
/// Se inicializa bloqueada cuando hay un PIN configurado; el guard del router
/// redirige a la pantalla de bloqueo mientras `state == true`.
class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Invocado al arrancar: bloquea si hay PIN configurado.
  Future<void> evaluateOnStartup() async {
    final hasPin = await ref.read(securityRepositoryProvider).isPinEnabled;
    state = hasPin;
  }

  void lock() => state = true;
  void unlock() => state = false;
}

final appLockProvider =
    NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);
