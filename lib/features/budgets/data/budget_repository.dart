import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../domain/budget.dart';

/// Acceso a `budgets` (topes mensuales por categoría). Escritura limitada por
/// RLS al `owner` del household (Nivel B).
class BudgetRepository {
  BudgetRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Budget>> fetchByHousehold(String householdId) async {
    final rows = await _client
        .from('budgets')
        .select()
        .eq('household_id', householdId);
    return rows.map(Budget.fromJson).toList();
  }

  /// Define o actualiza el tope de una categoría (upsert por household+categoría).
  Future<void> setBudget({
    required String householdId,
    required String categoryId,
    required int amount,
  }) async {
    await _client.from('budgets').upsert({
      'household_id': householdId,
      'user_id': _uid,
      'category_id': categoryId,
      'amount': amount,
    }, onConflict: 'household_id,category_id');
  }

  /// Quita el tope de una categoría.
  Future<void> removeBudget({
    required String householdId,
    required String categoryId,
  }) async {
    await _client
        .from('budgets')
        .delete()
        .eq('household_id', householdId)
        .eq('category_id', categoryId);
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(ref.watch(supabaseClientProvider)),
);
