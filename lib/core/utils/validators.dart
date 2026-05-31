import 'formatters.dart';

/// Validadores reutilizables para formularios.
class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final regex = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Monto en CLP: debe ser un entero positivo.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'El monto es obligatorio';
    final parsed = Formatters.parseAmount(value);
    if (parsed == null) return 'Monto inválido';
    if (parsed <= 0) return 'El monto debe ser mayor a 0';
    return null;
  }

  /// Día de facturación (1–31) para servicios fijos.
  static String? billingDay(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opcional
    final day = int.tryParse(value.trim());
    if (day == null || day < 1 || day > 31) return 'Día entre 1 y 31';
    return null;
  }

  /// PIN de 4 a 6 dígitos.
  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa un PIN';
    if (!RegExp(r'^\d{4,6}$').hasMatch(value)) return 'El PIN debe tener 4 a 6 dígitos';
    return null;
  }
}
