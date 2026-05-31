import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_provider.dart';
import '../../../shared/enums.dart';
import '../domain/service.dart';
import '../domain/service_payment.dart';

/// Acceso a `services` y `service_payments`, con la lógica de generación de
/// pagos mensuales y de marcado como pagado (que crea la transacción de gasto
/// y enlaza ambos registros).
class ServiceRepository {
  ServiceRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ----------------------------- services -----------------------------

  Future<List<Service>> fetchServices() async {
    final rows =
        await _client.from('services').select().order('name', ascending: true);
    return rows.map(Service.fromJson).toList();
  }

  Future<Service> createService({
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
  }) async {
    final row = await _client
        .from('services')
        .insert({
          'user_id': _uid,
          'name': name,
          'type': type.wire,
          'category': category.wire,
          'estimated_amount': estimatedAmount,
          'billing_day': billingDay,
          'frequency': frequency.wire,
        })
        .select()
        .single();
    return Service.fromJson(row);
  }

  Future<Service> updateService(
    String id, {
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
    required bool active,
  }) async {
    final row = await _client
        .from('services')
        .update({
          'name': name,
          'type': type.wire,
          'category': category.wire,
          'estimated_amount': estimatedAmount,
          'billing_day': billingDay,
          'frequency': frequency.wire,
          'active': active,
        })
        .eq('id', id)
        .select()
        .single();
    return Service.fromJson(row);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  // -------------------------- service_payments -------------------------

  Future<List<ServicePayment>> fetchPaymentsForMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final rows = await _client
        .from('service_payments')
        .select()
        .gte('due_date', _date(start))
        .lt('due_date', _date(end))
        .order('due_date', ascending: true);
    return rows.map(ServicePayment.fromJson).toList();
  }

  Future<List<ServicePayment>> fetchPaymentsForService(String serviceId) async {
    final rows = await _client
        .from('service_payments')
        .select()
        .eq('service_id', serviceId)
        .order('due_date', ascending: false);
    return rows.map(ServicePayment.fromJson).toList();
  }

  /// Genera (si no existe) la instancia de pago del mes para los servicios
  /// FIJOS activos con `billing_day`. Idempotente gracias al UNIQUE
  /// (service_id, due_date) + upsert que ignora duplicados.
  Future<void> generateMonthlyPayments(DateTime month) async {
    final services = await fetchServices();
    final fixed = services.where(
      (s) => s.active && s.isFixed && s.billingDay != null,
    );
    if (fixed.isEmpty) return;

    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final rows = <Map<String, dynamic>>[];
    for (final s in fixed) {
      final day = s.billingDay!.clamp(1, lastDay);
      final due = DateTime(month.year, month.month, day);
      rows.add({
        'service_id': s.id,
        'user_id': _uid,
        'due_date': _date(due),
        'amount': s.estimatedAmount,
        'status': PaymentStatus.pendiente.wire,
      });
    }

    // ignoreDuplicates evita recrear pagos ya existentes para el mismo mes.
    await _client.from('service_payments').upsert(
          rows,
          onConflict: 'service_id,due_date',
          ignoreDuplicates: true,
        );
  }

  /// Crea manualmente una instancia de pago (útil para servicios esporádicos).
  Future<ServicePayment> createPayment({
    required String serviceId,
    required DateTime dueDate,
    required int amount,
  }) async {
    final row = await _client
        .from('service_payments')
        .insert({
          'service_id': serviceId,
          'user_id': _uid,
          'due_date': _date(dueDate),
          'amount': amount,
          'status': PaymentStatus.pendiente.wire,
        })
        .select()
        .single();
    return ServicePayment.fromJson(row);
  }

  /// Marca un pago como pagado: crea la transacción de gasto correspondiente y
  /// enlaza ambos registros (`transaction_id` ↔ `service_id`).
  Future<void> markAsPaid({
    required ServicePayment payment,
    required String? categoryId,
    DateTime? paidDate,
  }) async {
    final date = paidDate ?? DateTime.now();

    // 1. Crea la transacción de gasto enlazada al servicio.
    final tx = await _client
        .from('transactions')
        .insert({
          'user_id': _uid,
          'type': TransactionType.expense.wire,
          'amount': payment.amount,
          'date': _date(date),
          'description': 'Pago de servicio',
          'category_id': categoryId,
          'service_id': payment.serviceId,
        })
        .select()
        .single();

    // 2. Actualiza el pago a 'pagado' enlazando la transacción.
    await _client
        .from('service_payments')
        .update({
          'status': PaymentStatus.pagado.wire,
          'paid_date': _date(date),
          'transaction_id': tx['id'],
        })
        .eq('id', payment.id);
  }

  /// Revierte un pago: borra la transacción enlazada y vuelve a 'pendiente'.
  Future<void> markAsPending(ServicePayment payment) async {
    if (payment.transactionId != null) {
      await _client.from('transactions').delete().eq('id', payment.transactionId!);
    }
    await _client.from('service_payments').update({
      'status': PaymentStatus.pendiente.wire,
      'paid_date': null,
      'transaction_id': null,
    }).eq('id', payment.id);
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(ref.watch(supabaseClientProvider)),
);
