import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import '../domain/profile.dart';

/// Perfil del usuario autenticado (nombre visible + avatar).
final currentProfileProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).fetchMine();
});

/// Acción para editar el nombre visible del perfil.
final profileActionsProvider = Provider<ProfileActions>(ProfileActions.new);

class ProfileActions {
  ProfileActions(this.ref);
  final Ref ref;

  Future<void> updateDisplayName(String name) async {
    await ref.read(profileRepositoryProvider).updateDisplayName(name.trim());
    ref.invalidate(currentProfileProvider);
  }
}
