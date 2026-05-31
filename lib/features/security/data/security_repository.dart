import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Persiste la configuración de seguridad local (PIN y biometría) usando
/// almacenamiento seguro del sistema. El PIN NUNCA se guarda en texto plano.
class SecurityRepository {
  SecurityRepository(this._storage, this._localAuth);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _kPinHash = 'pin_hash';
  static const _kBiometric = 'biometric_enabled';

  Future<bool> get isPinEnabled async =>
      (await _storage.read(key: _kPinHash)) != null;

  Future<bool> get isBiometricEnabled async =>
      (await _storage.read(key: _kBiometric)) == 'true';

  /// ¿Es la app capaz de usar biometría en este dispositivo?
  Future<bool> get canUseBiometrics async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Guarda el PIN como hash (no se almacena el PIN en claro).
  Future<void> setPin(String pin) async {
    await _storage.write(key: _kPinHash, value: _hash(pin));
  }

  Future<void> disablePin() async {
    await _storage.delete(key: _kPinHash);
    await setBiometricEnabled(false);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _kPinHash);
    return stored != null && stored == _hash(pin);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _kBiometric, value: enabled.toString());
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Desbloquea Astrea Budget',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Hash simple del PIN. Para producción puede reemplazarse por un KDF como
  /// PBKDF2/Argon2; aquí evita guardar el PIN en claro en el secure storage.
  String _hash(String pin) {
    var hash = 0;
    for (final code in pin.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return 'h$hash';
  }
}

final securityRepositoryProvider = Provider<SecurityRepository>(
  (ref) => SecurityRepository(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
    LocalAuthentication(),
  ),
);
