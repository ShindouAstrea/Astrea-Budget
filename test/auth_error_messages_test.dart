import 'package:astrea_budget/features/auth/data/auth_error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('sólo habla del largo mínimo cuando la clave es realmente débil', () {
    expect(
      authErrorMessage(
        AuthWeakPasswordException(
          message: 'Password should be at least 6 characters.',
          statusCode: '422',
          reasons: const ['length'],
        ),
      ),
      kWeakPasswordMessage,
    );
    expect(
      authErrorMessage(
        const AuthApiException(
          'Password should be at least 6 characters.',
          statusCode: '422',
          code: 'weak_password',
        ),
      ),
      kWeakPasswordMessage,
    );
  });

  test('repetir la contraseña anterior no se reporta como clave corta', () {
    final message = authErrorMessage(
      const AuthApiException(
        'New password should be different from the old password.',
        statusCode: '422',
        code: 'same_password',
      ),
    );
    expect(message, isNot(kWeakPasswordMessage));
    expect(message, contains('distinta'));
  });

  test('credenciales incorrectas al iniciar sesión', () {
    expect(
      authErrorMessage(
        const AuthApiException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      ),
      'Correo o contraseña incorrectos',
    );
    // Servidores antiguos: sin `code`, sólo el texto.
    expect(
      authErrorMessage(const AuthApiException('Invalid login credentials')),
      'Correo o contraseña incorrectos',
    );
  });

  test('enlace de recuperación caducado o ya usado', () {
    expect(
      authErrorMessage(
        const AuthException(
          'Email link is invalid or has expired',
          statusCode: 'otp_expired',
          code: 'access_denied',
        ),
      ),
      kExpiredLinkMessage,
    );
  });

  test('enlace abierto en otro dispositivo (falta el code verifier)', () {
    expect(
      authErrorMessage(
        AuthException('Code verifier could not be found in local storage.'),
      ),
      kMissingVerifierMessage,
    );
    expect(
      authErrorMessage(
        const AuthPKCEGrantCodeExchangeError(
          'No code detected in query parameters.',
        ),
      ),
      kMissingVerifierMessage,
    );
  });

  group('authLinkErrorMessage', () {
    test('lee el error que viene en el query del deep link', () {
      final uri = Uri.parse(
        'com.astrea.budget://reset-password'
        '?error=access_denied&error_code=otp_expired'
        '&error_description=Email+link+is+invalid+or+has+expired',
      );
      expect(authLinkErrorMessage(uri), kExpiredLinkMessage);
    });

    test('lee el error que viene en el fragmento', () {
      final uri = Uri.parse(
        'com.astrea.budget://reset-password'
        '#error=access_denied&error_code=otp_expired'
        '&error_description=Email+link+is+invalid+or+has+expired',
      );
      expect(authLinkErrorMessage(uri), kExpiredLinkMessage);
    });

    test('un enlace correcto no reporta nada', () {
      final uri = Uri.parse('com.astrea.budget://reset-password?code=abc123');
      expect(authLinkErrorMessage(uri), isNull);
    });
  });
}
