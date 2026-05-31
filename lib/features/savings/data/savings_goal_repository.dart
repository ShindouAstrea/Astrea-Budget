import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../domain/savings_goal.dart';

/// Acceso a `savings_goals`. En household compartido la meta es colaborativa
/// (cualquier miembro ve/crea/aporta; borra el creador o el owner).
class SavingsGoalRepository {
  SavingsGoalRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<List<SavingsGoal>> fetchByHousehold(String householdId) async {
    final rows = await _client
        .from('savings_goals')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: true);
    return rows.map(SavingsGoal.fromJson).toList();
  }

  Future<void> create({
    required String householdId,
    required String name,
    required int targetAmount,
    required int currentAmount,
    DateTime? targetDate,
    String? accountId,
    required String icon,
    required String color,
  }) async {
    await _client.from('savings_goals').insert({
      'household_id': householdId,
      'user_id': _uid,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate == null ? null : _date(targetDate),
      'account_id': accountId,
      'icon': icon,
      'color': color,
    });
  }

  Future<void> update(SavingsGoal goal) async {
    await _client.from('savings_goals').update({
      'name': goal.name,
      'target_amount': goal.targetAmount,
      'target_date':
          goal.targetDate == null ? null : _date(goal.targetDate!),
      'account_id': goal.accountId,
      'icon': goal.icon,
      'color': goal.color,
    }).eq('id', goal.id);
  }

  Future<void> delete(String id) async {
    await _client.from('savings_goals').delete().eq('id', id);
  }

  /// Aporta (o retira, con monto negativo) de forma atómica vía RPC.
  Future<void> contribute({required String goalId, required int amount}) async {
    await _client.rpc('add_savings_contribution', params: {
      'goal_id': goalId,
      'p_amount': amount,
    });
  }
}

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>(
  (ref) => SavingsGoalRepository(ref.watch(supabaseClientProvider)),
);
