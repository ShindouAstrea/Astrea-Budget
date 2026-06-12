import 'package:astrea_budget/features/transactions/data/transaction_csv.dart';
import 'package:astrea_budget/features/transactions/domain/transaction.dart';
import 'package:astrea_budget/shared/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final june5 = DateTime(2026, 6, 5);

  test('buildTransactionsCsv genera filas con separador ; y fechas ISO', () {
    final csv = buildTransactionsCsv(
      [
        TransactionModel(
          id: 't1',
          userId: 'u1',
          type: TransactionType.expense,
          amount: 45990,
          date: june5,
          description: 'Supermercado',
          categoryId: 'c1',
          accountId: 'a1',
        ),
      ],
      categoryNames: const {'c1': 'Alimentación'},
      accountNames: const {'a1': 'Tarjeta crédito'},
      authorNames: const {'u1': 'José'},
    );

    final lines = csv.trim().split('\r\n');
    expect(lines, hasLength(2));
    expect(lines.first.startsWith('Fecha;Tipo;Monto'), isTrue);
    expect(
      lines[1],
      '2026-06-05;Gasto;45990;Alimentación;Tarjeta crédito;Supermercado;;José',
    );
  });

  test('escapa descripciones con punto y coma o comillas', () {
    final csv = buildTransactionsCsv(
      [
        TransactionModel(
          id: 't1',
          userId: 'u1',
          type: TransactionType.expense,
          amount: 1000,
          date: june5,
          description: 'a;b "c"',
        ),
      ],
      categoryNames: const {},
      accountNames: const {},
    );

    expect(csv, contains('"a;b ""c"""'));
  });

  test('incluye la etiqueta de cuota', () {
    final csv = buildTransactionsCsv(
      [
        TransactionModel(
          id: 't1',
          userId: 'u1',
          type: TransactionType.expense,
          amount: 10000,
          date: june5,
          installmentGroupId: 'g1',
          installmentsTotal: 12,
          installmentNumber: 3,
        ),
      ],
      categoryNames: const {},
      accountNames: const {},
    );

    expect(csv, contains(';Cuota 3/12;'));
  });
}
