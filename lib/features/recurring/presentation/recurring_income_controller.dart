import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../households/presentation/household_controller.dart';
import '../data/recurring_income_repository.dart';
import '../domain/recurring_income.dart';

/// Ingresos recurrentes propios del usuario en el household activo.
final recurringIncomesProvider =
    FutureProvider<List<RecurringIncome>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  return ref.watch(recurringIncomeRepositoryProvider).fetchMine(householdId);
});

/// Dispara la generación de ingresos recurrentes vencidos del household activo.
/// Lo observa el dashboard al cargar; devuelve true si registró alguno.
final recurringIncomeGenerationProvider = FutureProvider<bool>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  return ref.watch(recurringIncomeRepositoryProvider).generateDue(householdId);
});

/// Acciones CRUD sobre ingresos recurrentes.
class RecurringIncomeActions {
  RecurringIncomeActions(this.ref);
  final Ref ref;

  Future<void> create({
    required String description,
    required int amount,
    String? categoryId,
    String? accountId,
    required int dayOfMonth,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(recurringIncomeRepositoryProvider).create(
          householdId: householdId,
          description: description,
          amount: amount,
          categoryId: categoryId,
          accountId: accountId,
          dayOfMonth: dayOfMonth,
        );
    ref.invalidate(recurringIncomesProvider);
  }

  Future<void> update(RecurringIncome income) async {
    await ref.read(recurringIncomeRepositoryProvider).update(income);
    ref.invalidate(recurringIncomesProvider);
  }

  Future<void> remove(String id) async {
    await ref.read(recurringIncomeRepositoryProvider).delete(id);
    ref.invalidate(recurringIncomesProvider);
  }
}

final recurringIncomeActionsProvider =
    Provider<RecurringIncomeActions>(RecurringIncomeActions.new);
