import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';
import '../../../core/config/supabase_provider.dart';
import '../../../core/data/local_cache.dart';
import '../data/household_repository.dart';
import '../domain/household.dart';
import '../domain/household_invitation.dart';
import '../domain/household_member.dart';

/// Households a los que pertenece el usuario (personal + compartidos).
/// Con caché offline: es la raíz de la que dependen los providers de datos.
final householdsProvider = FutureProvider<List<Household>>((ref) {
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  final repo = ref.watch(householdRepositoryProvider);
  if (uid == null) return repo.fetchMine();
  return ref.watch(localCacheProvider).fetchList(
        key: 'households:$uid',
        fetch: repo.fetchMine,
        toJson: (h) => h.toJson(),
        fromJson: Household.fromJson,
      );
});

/// Id del household activo, persistido en SharedPreferences **por usuario**
/// (clave `active_household_<uid>`). Así cada cuenta recuerda su último
/// presupuesto (= su predeterminado) y no se filtra entre usuarios en el mismo
/// dispositivo. La resolución real la hace [currentHouseholdProvider], que cae
/// al personal si el id guardado ya no es válido.
class CurrentHouseholdId extends Notifier<String?> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  String? get _key {
    final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
    return uid == null ? null : 'active_household_$uid';
  }

  @override
  String? build() {
    final key = _key;
    return key == null ? null : _prefs.getString(key);
  }

  Future<void> set(String id) async {
    state = id;
    final key = _key;
    if (key != null) await _prefs.setString(key, id);
  }
}

final currentHouseholdIdProvider =
    NotifierProvider<CurrentHouseholdId, String?>(CurrentHouseholdId.new);

/// Household activo resuelto: el seleccionado si sigue siendo válido, si no el
/// personal (o el primero disponible).
final currentHouseholdProvider = FutureProvider<Household>((ref) async {
  final households = await ref.watch(householdsProvider.future);
  final selectedId = ref.watch(currentHouseholdIdProvider);
  return households.firstWhere(
    (h) => h.id == selectedId,
    orElse: () => households.firstWhere(
      (h) => h.isPersonal,
      orElse: () => households.first,
    ),
  );
});

/// Atajo al id del household activo (lo consumen los providers de datos).
final activeHouseholdIdProvider = FutureProvider<String>((ref) async {
  final household = await ref.watch(currentHouseholdProvider.future);
  return household.id;
});

/// Si el usuario es `owner` del household activo. El creador siempre es owner;
/// quien acepta una invitación entra como `member`. Gobierna la edición de
/// estructura (cuentas/categorías/servicios), que RLS limita al owner.
final isActiveHouseholdOwnerProvider = FutureProvider<bool>((ref) async {
  final household = await ref.watch(currentHouseholdProvider.future);
  final uid = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  return household.createdBy == uid;
});

/// Miembros del household activo (con su nombre visible).
final householdMembersProvider = FutureProvider<List<HouseholdMember>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  return ref.watch(householdRepositoryProvider).fetchMembers(householdId);
});

/// `true` si el household activo es compartido (no el personal). Útil para
/// mostrar distintivos de autor sólo cuando hay más de una persona.
final isSharedHouseholdProvider = Provider<bool>((ref) {
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  return household != null && !household.isPersonal;
});

/// Mapa `userId → nombre visible` de los miembros del household activo, para
/// etiquetar quién registró cada movimiento en presupuestos compartidos.
final householdMemberNamesProvider = Provider<Map<String, String>>((ref) {
  final members = ref.watch(householdMembersProvider).valueOrNull ?? const [];
  return {for (final m in members) m.userId: m.displayName};
});

/// Invitaciones pendientes emitidas para el household activo (vista del owner).
final sentInvitationsProvider =
    FutureProvider<List<HouseholdInvitation>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  return ref
      .watch(householdRepositoryProvider)
      .fetchPendingInvitations(householdId);
});

/// Invitaciones pendientes dirigidas al usuario actual.
final receivedInvitationsProvider =
    FutureProvider<List<ReceivedInvitation>>((ref) {
  return ref.watch(householdRepositoryProvider).fetchMyInvitations();
});

/// Acciones sobre households compartidos: crear, invitar, aceptar, salir, etc.
class HouseholdActions {
  HouseholdActions(this.ref);
  final Ref ref;

  HouseholdRepository get _repo => ref.read(householdRepositoryProvider);

  /// Crea un presupuesto compartido y lo deja como activo.
  Future<void> createShared(String name) async {
    final id = await _repo.createShared(name);
    ref.invalidate(householdsProvider);
    await ref.read(currentHouseholdIdProvider.notifier).set(id);
  }

  Future<void> invite(String email) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await _repo.invite(householdId: householdId, email: email);
    ref.invalidate(sentInvitationsProvider);
  }

  Future<void> cancelInvitation(String id) async {
    await _repo.cancelInvitation(id);
    ref.invalidate(sentInvitationsProvider);
  }

  Future<void> accept(String invitationId) async {
    await _repo.acceptInvitation(invitationId);
    ref.invalidate(householdsProvider);
    ref.invalidate(receivedInvitationsProvider);
  }

  /// Sale de un household compartido y vuelve al personal.
  Future<void> leave(String householdId) async {
    await _repo.leave(householdId);
    final households = await _repo.fetchMine();
    final personal = households.firstWhere(
      (h) => h.isPersonal,
      orElse: () => households.first,
    );
    await ref.read(currentHouseholdIdProvider.notifier).set(personal.id);
    ref.invalidate(householdsProvider);
  }

  Future<void> removeMember(String householdId, String userId) async {
    await _repo.removeMember(householdId: householdId, userId: userId);
    ref.invalidate(householdMembersProvider);
  }

  /// Cambia el household activo (los providers de datos recomputan solos).
  Future<void> switchActive(String householdId) async {
    await ref.read(currentHouseholdIdProvider.notifier).set(householdId);
  }
}

final householdActionsProvider =
    Provider<HouseholdActions>(HouseholdActions.new);
