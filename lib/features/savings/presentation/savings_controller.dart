import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../households/presentation/household_controller.dart';
import '../data/savings_goal_repository.dart';
import '../domain/savings_goal.dart';

/// Metas de ahorro del household activo.
final savingsGoalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  return ref.watch(savingsGoalRepositoryProvider).fetchByHousehold(householdId);
});

/// Acciones CRUD + aportes sobre metas de ahorro.
class SavingsActions {
  SavingsActions(this.ref);
  final Ref ref;

  Future<void> create({
    required String name,
    required int targetAmount,
    required int currentAmount,
    DateTime? targetDate,
    String? accountId,
    required String icon,
    required String color,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(savingsGoalRepositoryProvider).create(
          householdId: householdId,
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: targetDate,
          accountId: accountId,
          icon: icon,
          color: color,
        );
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> update(SavingsGoal goal) async {
    await ref.read(savingsGoalRepositoryProvider).update(goal);
    ref.invalidate(savingsGoalsProvider);
  }

  Future<void> remove(String id) async {
    await ref.read(savingsGoalRepositoryProvider).delete(id);
    ref.invalidate(savingsGoalsProvider);
  }

  /// Aporta (amount>0) o retira (amount<0) del monto ahorrado.
  Future<void> contribute(String goalId, int amount) async {
    await ref
        .read(savingsGoalRepositoryProvider)
        .contribute(goalId: goalId, amount: amount);
    ref.invalidate(savingsGoalsProvider);
  }
}

final savingsActionsProvider = Provider<SavingsActions>(SavingsActions.new);
