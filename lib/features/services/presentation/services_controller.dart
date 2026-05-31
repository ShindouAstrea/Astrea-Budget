import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/enums.dart';
import '../../../shared/selected_month_provider.dart';
import '../../transactions/presentation/transactions_controller.dart';
import '../data/service_repository.dart';
import '../domain/service.dart';
import '../domain/service_payment.dart';

/// Listado de servicios del usuario con CRUD.
class ServicesNotifier extends AsyncNotifier<List<Service>> {
  ServiceRepository get _repo => ref.read(serviceRepositoryProvider);

  @override
  Future<List<Service>> build() => _repo.fetchServices();

  Future<void> add({
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
  }) async {
    await _repo.createService(
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

/// Pagos del mes seleccionado. Antes de leerlos, genera las instancias de los
/// servicios fijos del mes (idempotente).
final monthlyPaymentsProvider =
    FutureProvider<List<ServicePayment>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final repo = ref.watch(serviceRepositoryProvider);
  await repo.generateMonthlyPayments(month);
  return repo.fetchPaymentsForMonth(month);
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
    await ref
        .read(serviceRepositoryProvider)
        .markAsPaid(payment: payment, categoryId: categoryId);
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
    await ref.read(serviceRepositoryProvider).createPayment(
          serviceId: serviceId,
          dueDate: dueDate,
          amount: amount,
        );
    _refresh(serviceId);
  }

  void _refresh(String serviceId) {
    ref.invalidate(monthlyPaymentsProvider);
    ref.invalidate(servicePaymentsProvider(serviceId));
    // El gasto creado/eliminado afecta el listado de transacciones del mes.
    ref.invalidate(monthlyTransactionsProvider);
  }
}

final paymentActionsProvider = Provider<PaymentActions>(PaymentActions.new);
