import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/category.dart';

/// Acceso a la tabla `categories` en Supabase. RLS garantiza que sólo se
/// devuelvan las filas del usuario autenticado.
class CategoryRepository {
  CategoryRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Category>> fetchAll() async {
    final rows = await _client
        .from('categories')
        .select()
        .order('name', ascending: true);
    return rows.map(Category.fromJson).toList();
  }

  Future<Category> create({
    required String name,
    required TransactionType type,
    required String icon,
    required String color,
  }) async {
    final row = await _client
        .from('categories')
        .insert({
          'user_id': _uid,
          'name': name,
          'type': type.wire,
          'icon': icon,
          'color': color,
        })
        .select()
        .single();
    return Category.fromJson(row);
  }

  Future<Category> update(Category category) async {
    final row = await _client
        .from('categories')
        .update({
          'name': category.name,
          'type': category.type.wire,
          'icon': category.icon,
          'color': category.color,
        })
        .eq('id', category.id)
        .select()
        .single();
    return Category.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(supabaseClientProvider)),
);
