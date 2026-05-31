import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../domain/profile.dart';

/// Acceso a `profiles`. RLS permite ver el propio perfil y el de co-miembros.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<Profile?> fetchMine() async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', _uid)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<Profile> updateDisplayName(String displayName) async {
    final row = await _client
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', _uid)
        .select()
        .single();
    return Profile.fromJson(row);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);
