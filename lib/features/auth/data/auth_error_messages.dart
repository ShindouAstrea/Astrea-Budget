import 'package:supabase_flutter/supabase_flutter.dart';

/// Mensajes de error de Supabase Auth traducidos a algo que el usuario entienda.
///
/// Vive fuera del controlador porque también los necesita el router: los fallos
/// de un deep link (el enlace del correo de recuperación) no pasan por
/// `AuthController`, Supabase los publica como **error del stream**
/// `onAuthStateChange`. Sin traducirlos ahí, el usuario sólo veía que la app se
/// abría en el login sin ninguna explicación.

const String kWeakPasswordMessage =
    'La contraseña no cumple los requisitos (mínimo 6 caracteres)';

const String kExpiredSessionMessage =
    'Tu sesión expiró. Vuelve a intentarlo desde el inicio.';

const String kExpiredLinkMessage =
    'El enlace ya no sirve: expiró o se usó antes. Pide uno nuevo desde '
    '"¿Olvidaste tu contraseña?".';

/// El intercambio PKCE necesita el `code_verifier` que se guardó en este
/// dispositivo al pedir el correo. Si el enlace se abre en otro teléfono, en
/// otro navegador o después de reinstalar, ese dato no está.
const String kMissingVerifierMessage =
    'Abre el enlace en el mismo dispositivo donde pediste el cambio de '
    'contraseña. Si lo reinstalaste, solicita un enlace nuevo.';

/// Traduce los errores de Supabase a mensajes amigables (sin filtrar
/// información sensible).
///
/// Se decide por el `code` que devuelve Supabase Auth: buscar palabras sueltas
/// dentro del mensaje es frágil y hacía que cualquier error que mencionara
/// "password" (por ejemplo `same_password`: "New password should be different
/// from the old password") se mostrara como si la contraseña fuera muy corta.
String authErrorMessage(AuthException e) {
  // Único caso en que corresponde hablar del largo mínimo.
  if (e is AuthWeakPasswordException) return kWeakPasswordMessage;
  if (e is AuthSessionMissingException) return kExpiredSessionMessage;
  if (e is AuthPKCEGrantCodeExchangeError) return kMissingVerifierMessage;
  if (e is AuthRetryableFetchException) {
    return 'No pudimos conectarnos. Revisa tu conexión e inténtalo de nuevo.';
  }

  // `getSessionFromUrl` mete el `error_code` del enlace en `statusCode` y el
  // `error` en `code`: así llegan los enlaces caducados o ya consumidos.
  final statusCode = e.statusCode;
  if (statusCode == 'otp_expired' || statusCode == 'access_denied') {
    return kExpiredLinkMessage;
  }

  final rawCode = e.code;
  if (rawCode != null) {
    // Códigos que el enum del paquete todavía no cubre.
    if (rawCode == 'invalid_credentials') {
      return 'Correo o contraseña incorrectos';
    }
    if (rawCode == 'access_denied') return kExpiredLinkMessage;

    switch (ErrorCode.fromCode(rawCode)) {
      case ErrorCode.weakPassword:
        return kWeakPasswordMessage;
      case ErrorCode.samePassword:
        return 'La nueva contraseña debe ser distinta a la actual';
      case ErrorCode.emailExists:
      case ErrorCode.userAlreadyExists:
      case ErrorCode.identityAlreadyExists:
        return 'Ya existe una cuenta con este correo';
      case ErrorCode.emailNotConfirmed:
        return 'Debes confirmar tu correo antes de iniciar sesión';
      case ErrorCode.userNotFound:
        return 'No encontramos una cuenta con esos datos';
      case ErrorCode.anonymousProviderDisabled:
        return 'El modo invitado no está habilitado. '
            'Activa "Anonymous sign-ins" en el dashboard de Supabase.';
      case ErrorCode.signupDisabled:
        return 'El registro de cuentas nuevas está deshabilitado';
      case ErrorCode.emailProviderDisabled:
        return 'El inicio de sesión con correo no está habilitado';
      case ErrorCode.overRequestRateLimit:
      case ErrorCode.overEmailSendRateLimit:
      case ErrorCode.overSmsSendRateLimit:
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo';
      case ErrorCode.otpExpired:
      case ErrorCode.flowStateExpired:
      case ErrorCode.flowStateNotFound:
      case ErrorCode.badCodeVerifier:
        return kExpiredLinkMessage;
      case ErrorCode.reauthenticationNeeded:
        return 'Por seguridad, vuelve a iniciar sesión antes de cambiar tu '
            'contraseña';
      case ErrorCode.userBanned:
        return 'Esta cuenta está bloqueada';
      case ErrorCode.sessionExpired:
      case ErrorCode.sessionNotFound:
      case ErrorCode.sessionMissing:
        return kExpiredSessionMessage;
      default:
        break;
    }
  }

  // Respaldo por texto, para respuestas que llegan sin `code`.
  final msg = e.message.toLowerCase();
  if (msg.contains('code verifier')) return kMissingVerifierMessage;
  if (msg.contains('link is invalid') ||
      msg.contains('link has expired') ||
      msg.contains('has expired')) {
    return kExpiredLinkMessage;
  }
  if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
    return 'Correo o contraseña incorrectos';
  }
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
  if (msg.contains('rate limit') || msg.contains('for security purposes')) {
    return 'Demasiados intentos. Espera un momento e inténtalo de nuevo';
  }
  if (msg.contains('should be different')) {
    return 'La nueva contraseña debe ser distinta a la actual';
  }
  if (msg.contains('auth session missing')) return kExpiredSessionMessage;
  // Sólo cuando el servidor de verdad se queja del largo o la fortaleza.
  if (msg.contains('password') &&
      (msg.contains('at least') ||
          msg.contains('too short') ||
          msg.contains('too weak') ||
          msg.contains('characters'))) {
    return kWeakPasswordMessage;
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

/// Traduce el error que Supabase devuelve **dentro del propio deep link**.
///
/// Cuando el token del correo ya no sirve, Supabase no redirige con `code`
/// sino con `?error=access_denied&error_code=otp_expired&error_description=...`.
/// Devuelve `null` si el enlace no trae ningún error.
String? authLinkErrorMessage(Uri uri) {
  // Los parámetros pueden venir en el query o en el fragmento (`#`).
  final params = {
    ...uri.queryParameters,
    ...Uri.splitQueryString(uri.fragment),
  };

  final errorCode = params['error_code'];
  final error = params['error'];
  final description = params['error_description'];
  if (errorCode == null && error == null && description == null) return null;

  return authErrorMessage(
    AuthException(
      description ?? 'El enlace no es válido',
      statusCode: errorCode,
      code: error,
    ),
  );
}
