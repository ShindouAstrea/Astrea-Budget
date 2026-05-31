import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/account.dart';

/// Acceso a `accounts` y a la vista `account_balances`. La escritura está
/// limitada por RLS al `owner` del household (Nivel B).
class AccountRepository {
  AccountRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Account>> fetchByHousehold(String householdId) async {
    final rows = await _client
        .from('accounts')
        .select()
        .eq('household_id', householdId)
        .eq('archived', false)
        .order('created_at', ascending: true);
    return rows.map(Account.fromJson).toList();
  }

  /// Saldos por cuenta del household: `{accountId: balance}`.
  Future<Map<String, double>> fetchBalances(String householdId) async {
    final rows = await _client
        .from('account_balances')
        .select('account_id, balance')
        .eq('household_id', householdId);
    return {
      for (final r in rows)
        r['account_id'] as String: (r['balance'] as num).toDouble(),
    };
  }

  Future<Account> create({
    required String householdId,
    required String name,
    required AccountType type,
    required int initialBalance,
    int? creditLimit,
    int? statementDay,
    int? paymentDueDay,
    required String color,
    required String icon,
  }) async {
    final isCredit = type.isCredit;
    final row = await _client
        .from('accounts')
        .insert({
          'household_id': householdId,
          'user_id': _uid,
          'name': name,
          'type': type.wire,
          'initial_balance': initialBalance,
          'credit_limit': isCredit ? creditLimit : null,
          'statement_day': isCredit ? statementDay : null,
          'payment_due_day': isCredit ? paymentDueDay : null,
          'color': color,
          'icon': icon,
        })
        .select()
        .single();
    return Account.fromJson(row);
  }

  Future<Account> update(Account account) async {
    final isCredit = account.isCredit;
    final row = await _client
        .from('accounts')
        .update({
          'name': account.name,
          'type': account.type.wire,
          'initial_balance': account.initialBalance,
          'credit_limit': isCredit ? account.creditLimit : null,
          'statement_day': isCredit ? account.statementDay : null,
          'payment_due_day': isCredit ? account.paymentDueDay : null,
          'color': account.color,
          'icon': account.icon,
          'archived': account.archived,
        })
        .eq('id', account.id)
        .select()
        .single();
    return Account.fromJson(row);
  }

  /// Archiva la cuenta (no se borra para preservar el historial de movimientos).
  Future<void> archive(String id) async {
    await _client.from('accounts').update({'archived': true}).eq('id', id);
  }

  /// Transfiere entre cuentas: par de transacciones atómico (RPC).
  Future<void> transfer({
    required String householdId,
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required DateTime date,
    String? description,
  }) async {
    await _client.rpc('create_transfer', params: {
      'p_household': householdId,
      'p_from_account': fromAccountId,
      'p_to_account': toAccountId,
      'p_amount': amount,
      'p_date': _date(date),
      'p_description': description,
    });
  }

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(supabaseClientProvider)),
);
