import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/budget_cycle.dart';
import '../../../shared/enums.dart';
import '../../../shared/selected_month_provider.dart';
import '../../accounts/presentation/accounts_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../../transactions/presentation/transactions_controller.dart';
import '../data/service_repository.dart';
import '../domain/service.dart';
import '../domain/service_payment.dart';

/// Listado de servicios del household activo con CRUD.
class ServicesNotifier extends AsyncNotifier<List<Service>> {
  ServiceRepository get _repo => ref.read(serviceRepositoryProvider);

  @override
  Future<List<Service>> build() async {
    final householdId = await ref.watch(activeHouseholdIdProvider.future);
    return _repo.fetchServices(householdId);
  }

  Future<void> add({
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await _repo.createService(
      householdId: householdId,
      name: name,
      type: type,
      category: category,
      estimatedAmount: estimatedAmount,
      billingDay: billingDay,
      frequency: frequency,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(
    String id, {
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
    required bool active,
  }) async {
    await _repo.updateService(
      id,
      name: name,
      type: type,
      category: category,
      estimatedAmount: estimatedAmount,
      billingDay: billingDay,
      frequency: frequency,
      active: active,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(String id) async {
    await _repo.deleteService(id);
    ref.invalidateSelf();
    await future;
  }
}

final servicesProvider =
    AsyncNotifierProvider<ServicesNotifier, List<Service>>(
  ServicesNotifier.new,
);

/// Pagos del mes financiero seleccionado. Antes de leerlos genera las
/// instancias de los servicios fijos (idempotente). La ventana del mes
/// financiero puede abarcar dos meses calendario (p. ej. con corte 28, junio va
/// del 28-may al 27-jun), así que se generan ambos.
final monthlyPaymentsProvider =
    FutureProvider<List<ServicePayment>>((ref) async {
  final householdId = await ref.watch(activeHouseholdIdProvider.future);
  final month = ref.watch(selectedMonthProvider);
  final cutoff = ref.watch(budgetCutoffProvider);
  final repo = ref.watch(serviceRepositoryProvider);
  final range = BudgetCycle.bounds(month, cutoff);

  await repo.generateMonthlyPayments(householdId, month);
  final startMonth = DateTime(range.start.year, range.start.month);
  if (startMonth != DateTime(month.year, month.month)) {
    await repo.generateMonthlyPayments(householdId, startMonth);
  }

  return repo.fetchPaymentsBetween(householdId, range.start, range.end);
});

/// Historial de pagos de un servicio concreto.
final servicePaymentsProvider =
    FutureProvider.family<List<ServicePayment>, String>((ref, serviceId) {
  return ref.watch(serviceRepositoryProvider).fetchPaymentsForService(serviceId);
});

/// Acciones sobre pagos (marcar pagado / pendiente / crear esporádico).
class PaymentActions {
  PaymentActions(this.ref);
  final Ref ref;

  Future<void> markAsPaid(ServicePayment payment, {String? categoryId}) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    final account = await ref.read(activeAccountProvider.future);
    await ref.read(serviceRepositoryProvider).markAsPaid(
          householdId: householdId,
          payment: payment,
          categoryId: categoryId,
          accountId: account?.id,
        );
    _refresh(payment.serviceId);
  }

  Future<void> markAsPending(ServicePayment payment) async {
    await ref.read(serviceRepositoryProvider).markAsPending(payment);
    _refresh(payment.serviceId);
  }

  Future<void> createPayment({
    required String serviceId,
    required DateTime dueDate,
    required int amount,
  }) async {
    final householdId = await ref.read(activeHouseholdIdProvider.future);
    await ref.read(serviceRepositoryProvider).createPayment(
          householdId: householdId,
          serviceId: serviceId,
          dueDate: dueDate,
          amount: amount,
        );
    _refresh(serviceId);
  }

  void _refresh(String serviceId) {
    ref.invalidate(monthlyPaymentsProvider);
    ref.invalidate(servicePaymentsProvider(serviceId));
    // El gasto creado/eliminado afecta el listado de transacciones y saldos.
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(accountBalancesProvider);
  }
}

final paymentActionsProvider = Provider<PaymentActions>(PaymentActions.new);
