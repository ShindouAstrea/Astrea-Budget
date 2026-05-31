// Enumeraciones compartidas. Sus valores `wire` coinciden con los enum de
// Postgres definidos en `supabase/schema.sql`.

enum TransactionType {
  income('income', 'Ingreso'),
  expense('expense', 'Gasto');

  const TransactionType(this.wire, this.label);
  final String wire;
  final String label;

  bool get isIncome => this == TransactionType.income;

  static TransactionType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

enum ServiceType {
  fijo('fijo', 'Fijo'),
  esporadico('esporadico', 'Esporádico');

  const ServiceType(this.wire, this.label);
  final String wire;
  final String label;

  static ServiceType fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

enum ServiceCategory {
  esencial('esencial', 'Esencial'),
  suscripcion('suscripcion', 'Suscripción');

  const ServiceCategory(this.wire, this.label);
  final String wire;
  final String label;

  static ServiceCategory fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

enum ServiceFrequency {
  mensual('mensual', 'Mensual'),
  bimestral('bimestral', 'Bimestral'),
  anual('anual', 'Anual'),
  unico('unico', 'Único');

  const ServiceFrequency(this.wire, this.label);
  final String wire;
  final String label;

  static ServiceFrequency fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}

enum PaymentStatus {
  pendiente('pendiente', 'Pendiente'),
  pagado('pagado', 'Pagado');

  const PaymentStatus(this.wire, this.label);
  final String wire;
  final String label;

  bool get isPaid => this == PaymentStatus.pagado;

  static PaymentStatus fromWire(String value) =>
      values.firstWhere((e) => e.wire == value);
}
