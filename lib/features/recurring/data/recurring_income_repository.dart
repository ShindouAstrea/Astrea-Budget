import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/recurring_income.dart';

/// Acceso a `recurring_incomes`. Cada usuario gestiona y genera SUS plantillas
/// (la transacción de ingreso resultante lleva su user_id, Nivel A).
class RecurringIncomeRepository {
  RecurringIncomeRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Plantillas propias del usuario en el household.
  Future<List<RecurringIncome>> fetchMine(String householdId) async {
    final rows = await _client
        .from('recurring_incomes')
        .select()
        .eq('household_id', householdId)
        .eq('user_id', _uid)
        .order('description', ascending: true);
    return rows.map(RecurringIncome.fromJson).toList();
  }

  Future<void> create({
    required String householdId,
    required String description,
    required int amount,
    String? categoryId,
    String? accountId,
    required int dayOfMonth,
  }) async {
    await _client.from('recurring_incomes').insert({
      'household_id': householdId,
      'user_id': _uid,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'account_id': accountId,
      'day_of_month': dayOfMonth,
    });
  }

  Future<void> update(RecurringIncome income) async {
    await _client.from('recurring_incomes').update({
      'description': income.description,
      'amount': income.amount,
      'category_id': income.categoryId,
      'account_id': income.accountId,
      'day_of_month': income.dayOfMonth,
      'active': income.active,
    }).eq('id', income.id);
  }

  Future<void> delete(String id) async {
    await _client.from('recurring_incomes').delete().eq('id', id);
  }

  /// Genera los ingresos propios que ya vencen este mes y aún no se registran.
  /// Idempotente vía `last_generated`. Devuelve true si creó alguno.
  Future<bool> generateDue(String householdId) async {
    final templates = await fetchMine(householdId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var generatedAny = false;

    for (final t in templates) {
      if (!t.active) continue;
      final day = t.dayOfMonth.clamp(1, 28);
      final target = DateTime(now.year, now.month, day);
      if (today.isBefore(target)) continue; // aún no llega el día
      final last = t.lastGenerated;
      if (last != null && !last.isBefore(target)) continue; // ya generado

      await _client.from('transactions').insert({
        'household_id': householdId,
        'user_id': _uid,
        'account_id': t.accountId,
        'type': TransactionType.income.wire,
        'amount': t.amount,
        'date': _date(target),
        'description': t.description,
        'category_id': t.categoryId,
      });
      await _client
          .from('recurring_incomes')
          .update({'last_generated': _date(target)}).eq('id', t.id);
      generatedAny = true;
    }
    return generatedAny;
  }
}

final recurringIncomeRepositoryProvider = Provider<RecurringIncomeRepository>(
  (ref) => RecurringIncomeRepository(ref.watch(supabaseClientProvider)),
);
