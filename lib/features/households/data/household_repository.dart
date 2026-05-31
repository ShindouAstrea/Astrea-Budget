import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/household.dart';
import '../domain/household_invitation.dart';
import '../domain/household_member.dart';

/// Acceso a `households` y `household_members`. RLS limita las filas a los
/// households donde el usuario es miembro. La creación de households compartidos
/// y la aceptación de invitaciones pasan por RPCs (`create_household`,
/// `accept_invitation`) que controlan el límite de 3 y crean la membresía.
class HouseholdRepository {
  HouseholdRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// Households a los que pertenece el usuario (el personal primero).
  Future<List<Household>> fetchMine() async {
    final rows = await _client
        .from('households')
        .select()
        .order('is_personal', ascending: false)
        .order('created_at', ascending: true);
    return rows.map(Household.fromJson).toList();
  }

  /// Crea un presupuesto compartido (RPC controla el límite de 3 + owner).
  Future<String> createShared(String name) async {
    final id = await _client.rpc(
      'create_household',
      params: {'p_name': name},
    );
    return id as String;
  }

  // ----------------------------- miembros -----------------------------

  /// Miembros del household con su nombre visible (une members + profiles).
  Future<List<HouseholdMember>> fetchMembers(String householdId) async {
    final memberRows = await _client
        .from('household_members')
        .select('user_id, role')
        .eq('household_id', householdId);
    final ids = [for (final m in memberRows) m['user_id'] as String];
    final profileRows = ids.isEmpty
        ? const []
        : await _client.from('profiles').select('id, display_name').inFilter(
              'id',
              ids,
            );
    final names = {
      for (final p in profileRows) p['id'] as String: p['display_name'] as String,
    };
    final me = _uid;
    return [
      for (final m in memberRows)
        HouseholdMember(
          userId: m['user_id'] as String,
          role: HouseholdRole.fromWire(m['role'] as String),
          displayName: names[m['user_id']] ?? 'Usuario',
          isMe: m['user_id'] == me,
        ),
    ];
  }

  /// Salir de un household compartido (RLS permite borrar la propia membresía).
  Future<void> leave(String householdId) async {
    await _client
        .from('household_members')
        .delete()
        .eq('household_id', householdId)
        .eq('user_id', _uid);
  }

  /// Quitar a un miembro (sólo el owner, por RLS).
  Future<void> removeMember({
    required String householdId,
    required String userId,
  }) async {
    await _client
        .from('household_members')
        .delete()
        .eq('household_id', householdId)
        .eq('user_id', userId);
  }

  // --------------------------- invitaciones ---------------------------

  /// Invita por email a un household (RLS exige owner + invited_by = uid).
  Future<void> invite({
    required String householdId,
    required String email,
  }) async {
    await _client.from('household_invitations').insert({
      'household_id': householdId,
      'email': email.trim().toLowerCase(),
      'invited_by': _uid,
    });
  }

  /// Invitaciones pendientes emitidas para un household (vista del owner).
  Future<List<HouseholdInvitation>> fetchPendingInvitations(
    String householdId,
  ) async {
    final rows = await _client
        .from('household_invitations')
        .select()
        .eq('household_id', householdId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return rows.map(HouseholdInvitation.fromJson).toList();
  }

  Future<void> cancelInvitation(String id) async {
    await _client.from('household_invitations').delete().eq('id', id);
  }

  /// Invitaciones pendientes dirigidas a MÍ (RPC con nombre de household).
  Future<List<ReceivedInvitation>> fetchMyInvitations() async {
    final rows = await _client.rpc('my_invitations') as List;
    return rows
        .map((e) => ReceivedInvitation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Acepta una invitación (RPC crea la membresía y respeta el límite de 3).
  Future<void> acceptInvitation(String invitationId) async {
    await _client.rpc(
      'accept_invitation',
      params: {'invitation_id': invitationId},
    );
  }
}

final householdRepositoryProvider = Provider<HouseholdRepository>(
  (ref) => HouseholdRepository(ref.watch(supabaseClientProvider)),
);
