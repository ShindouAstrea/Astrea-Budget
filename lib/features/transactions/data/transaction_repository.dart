import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../core/utils/uuid.dart';
import '../../../shared/enums.dart';
import '../domain/installments.dart';
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

  /// Transacciones en el rango `[start, end)` (límites del mes financiero).
  /// Excluye las transferencias entre cuentas (no son ingreso/gasto real).
  Future<List<TransactionModel>> fetchBetween(
    String householdId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('transactions')
        .select()
        .eq('household_id', householdId)
        .isFilter('transfer_group_id', null)
        .gte('date', _date(start))
        .lt('date', _date(end))
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(TransactionModel.fromJson).toList();
  }

  Future<TransactionModel> create({
    required String householdId,
    String? accountId,
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
          'household_id': householdId,
          'user_id': _uid,
          'account_id': accountId,
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
    String? accountId,
  }) async {
    final row = await _client
        .from('transactions')
        .update({
          'type': type.wire,
          'amount': amount,
          'date': _date(date),
          'description': description,
          'category_id': categoryId,
          'account_id': accountId,
        })
        .eq('id', id)
        .select()
        .single();
    return TransactionModel.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  /// Crea una compra en cuotas: [count] gastos (uno por mes desde [firstDate])
  /// que suman exactamente [totalAmount], unidos por un grupo común.
  Future<void> createInstallments({
    required String householdId,
    String? accountId,
    required int totalAmount,
    required int count,
    required DateTime firstDate,
    String? description,
    String? categoryId,
  }) async {
    final groupId = uuidV4();
    final amounts = splitInstallments(totalAmount, count);
    await _client.from('transactions').insert([
      for (var i = 0; i < count; i++)
        {
          'household_id': householdId,
          'user_id': _uid,
          'account_id': accountId,
          'type': TransactionType.expense.wire,
          'amount': amounts[i],
          'date': _date(installmentDate(firstDate, i)),
          'description': description,
          'category_id': categoryId,
          'installment_group_id': groupId,
          'installments_total': count,
          'installment_number': i + 1,
        },
    ]);
  }

  /// Elimina todas las cuotas de un grupo (la compra completa).
  Future<void> deleteInstallmentGroup(String groupId) async {
    await _client
        .from('transactions')
        .delete()
        .eq('installment_group_id', groupId);
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(supabaseClientProvider)),
);
