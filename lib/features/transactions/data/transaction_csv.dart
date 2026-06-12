import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import '../domain/transaction.dart';

/// Construye el CSV de un listado de transacciones. Separador `;` (el que
/// espera Excel en locale es-CL) y fechas ISO. Función pura, testeable.
String buildTransactionsCsv(
  List<TransactionModel> transactions, {
  required Map<String, String> categoryNames,
  required Map<String, String> accountNames,
  Map<String, String> authorNames = const {},
}) {
  String escape(String value) {
    if (value.contains(RegExp(r'[;"\n\r]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  final buffer = StringBuffer(
    'Fecha;Tipo;Monto;Categoría;Cuenta;Descripción;Cuota;Registrado por\r\n',
  );
  for (final t in transactions) {
    buffer.write([
      date(t.date),
      t.type.label,
      t.amount.toInt().toString(),
      escape(categoryNames[t.categoryId] ?? ''),
      escape(accountNames[t.accountId] ?? ''),
      escape(t.description ?? ''),
      t.installmentLabel ?? '',
      escape(authorNames[t.userId] ?? ''),
    ].join(';'));
    buffer.write('\r\n');
  }
  return buffer.toString();
}

/// Abre la hoja de compartir del sistema con el CSV como archivo adjunto.
Future<void> shareTransactionsCsv({
  required String csv,
  required String fileName,
}) async {
  // BOM UTF-8 para que Excel detecte la codificación (tildes y eñes).
  final bytes = Uint8List.fromList(utf8.encode('\uFEFF$csv'));
  await Share.shareXFiles(
    [XFile.fromData(bytes, mimeType: 'text/csv')],
    fileNameOverrides: [fileName],
  );
}
