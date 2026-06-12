import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_cache.dart';
import '../../../shared/enums.dart';
import '../../households/presentation/household_controller.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';

/// Lista de categorías del household activo con operaciones CRUD.
/// La lectura pasa por [LocalCache] para funcionar sin conexión.
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  CategoryRepository get _repo => ref.read(categoryRepositoryProvider);

  @override
  Future<List<Category>> build() async {
    final householdId = await ref.watch(activeHouseholdIdProvider.future);
    return ref.watch(localCacheProvider).fetchList(
          key: 'categories:$householdId',
          fetch: () => _repo.fetchAll(householdId),
          toJson: (c) => c.toJson(),
          fromJson: Category.fromJson,
        );
  }

  Future<void> add({
    required String name,
    required TransactionType type,
    required String icon,
    required String color,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await _repo.create(
      householdId: householdId,
      name: name,
      type: type,
      icon: icon,
      color: color,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(Category category) async {
    await _repo.update(category);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
    await future;
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

/// Categorías filtradas por tipo (para el formulario de transacción).
final categoriesByTypeProvider =
    Provider.family<List<Category>, TransactionType>((ref, type) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  return categories.where((c) => c.type == type).toList();
});
