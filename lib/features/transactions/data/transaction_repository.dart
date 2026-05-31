import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/transaction.dart';

/// Acceso a la tabla `transactions`. RLS limita las filas al usuario actual.
class TransactionRepository {
  TransactionRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// Formatea una fecha como 'YYYY-MM-DD' para columnas `date` de Postgres.
  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Transacciones de un mes (desde el día 1 hasta el último día inclusive).
  Future<List<TransactionModel>> fetchForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final rows = await _client
        .from('transactions')
        .select()
        .gte('date', _date(start))
        .lt('date', _date(end))
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(TransactionModel.fromJson).toList();
  }

  Future<TransactionModel> create({
    required TransactionType type,
    required int amount,
    required DateTime date,
    String? description,
    String? categoryId,
    String? serviceId,
  }) async {
    final row = await _client
        .from('transactions')
        .insert({
          'user_id': _uid,
          'type': type.wire,
          'amount': amount,
          'date': _date(date),
          'description': description,
          'category_id': categoryId,
          'service_id': serviceId,
        })
        .select()
        .single();
    return TransactionModel.fromJson(row);
  }

  Future<TransactionModel> update({
    required String id,
    required TransactionType type,
    required int amount,
    required DateTime date,
    String? description,
    String? categoryId,
  }) async {
    final row = await _client
        .from('transactions')
        .update({
          'type': type.wire,
          'amount': amount,
          'date': _date(date),
          'description': description,
          'category_id': categoryId,
        })
        .eq('id', id)
        .select()
        .single();
    return TransactionModel.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(supabaseClientProvider)),
);
