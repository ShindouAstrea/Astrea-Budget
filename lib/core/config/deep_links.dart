/// Enlaces profundos (deep links) con los que Supabase devuelve al usuario a la
/// app desde un correo.
///
/// Sin un `redirectTo` explícito, Supabase usa el **Site URL** del proyecto,
/// que por defecto es `http://localhost:3000`: por eso el correo de "recuperar
/// contraseña" llevaba a localhost y no había forma de terminar el flujo desde
/// el teléfono.
///
/// El esquema debe estar declarado en las dos plataformas y, además,
/// autorizado en el panel de Supabase (Authentication → URL Configuration →
/// Redirect URLs). Ver README.
library;

/// Esquema propio de la app (`AndroidManifest.xml` y `Info.plist`).
const String kAppScheme = 'com.astrea.budget';

/// Destino del correo de recuperación: abre la pantalla de nueva contraseña.
const String kPasswordResetRedirect = '$kAppScheme://reset-password';

/// Destino del correo de confirmación de cuenta (registro y conversión de
/// invitado a cuenta permanente).
const String kEmailConfirmRedirect = '$kAppScheme://login-callback';
