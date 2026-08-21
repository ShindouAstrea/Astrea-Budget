import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/recurring_income.dart';
import '../domain/recurring_schedule.dart';

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

  /// Registra los ingresos propios que ya vencieron y aún no se anotaron,
  /// incluidos los **meses saltados** (si no se abrió la app en un tiempo).
  /// Idempotente vía `last_generated`. Devuelve cuántos creó.
  ///
  /// Un error en una plantilla no impide procesar las demás, pero se propaga
  /// al final: si esto falla en silencio, el sueldo simplemente "nunca se
  /// registra" y no hay forma de darse cuenta.
  Future<int> generateDue(String householdId) async {
    final templates = await fetchMine(householdId);
    var total = 0;
    Object? failure;

    for (final t in templates) {
      if (!t.active) continue;
      try {
        total += await generateFor(householdId, t);
      } catch (e) {
        failure ??= e;
      }
    }
    if (failure != null && total == 0) throw failure;
    return total;
  }

  /// Registra las ocurrencias pendientes de UNA plantilla. Devuelve cuántas.
  Future<int> generateFor(
    String householdId,
    RecurringIncome template, {
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final pending = pendingOccurrences(
      dayOfMonth: template.dayOfMonth,
      lastGenerated: template.lastGenerated,
      today: today,
    );
    if (pending.isEmpty) return 0;

    await _client.from('transactions').insert([
      for (final date in pending)
        {
          'household_id': householdId,
          'user_id': _uid,
          'account_id': template.accountId,
          'type': TransactionType.income.wire,
          'amount': template.amount,
          'date': _date(date),
          'description': template.description,
          'category_id': template.categoryId,
        },
    ]);
    await _client
        .from('recurring_incomes')
        .update({'last_generated': _date(pending.last)}).eq('id', template.id);
    return pending.length;
  }
}

final recurringIncomeRepositoryProvider = Provider<RecurringIncomeRepository>(
  (ref) => RecurringIncomeRepository(ref.watch(supabaseClientProvider)),
);
