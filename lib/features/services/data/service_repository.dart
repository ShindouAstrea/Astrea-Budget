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

  /// Primer día del mes de [d] (formato de `services.first_charge_month`).
  String _monthDate(DateTime d) => _date(DateTime(d.year, d.month));

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ----------------------------- services -----------------------------

  Future<List<Service>> fetchServices(String householdId) async {
    final rows = await _client
        .from('services')
        .select()
        .eq('household_id', householdId)
        .order('name', ascending: true);
    return rows.map(Service.fromJson).toList();
  }

  Future<Service> createService({
    required String householdId,
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
    DateTime? firstChargeMonth,
    String? expenseCategoryId,
  }) async {
    final row = await _client
        .from('services')
        .insert({
          'household_id': householdId,
          'user_id': _uid,
          'name': name,
          'type': type.wire,
          'category': category.wire,
          'estimated_amount': estimatedAmount,
          'billing_day': billingDay,
          'frequency': frequency.wire,
          'first_charge_month': _monthDate(firstChargeMonth ?? DateTime.now()),
          'category_id': expenseCategoryId,
        })
        .select()
        .single();
    return Service.fromJson(row);
  }

  /// Actualiza el servicio y, si cambió el monto estimado, lo propaga a los
  /// pagos **pendientes que aún no vencen** cuyo monto no se ajustó a mano.
  /// Así, cuando una suscripción sube de precio de forma permanente, el cambio
  /// se refleja en los meses ya generados sin pisar los ajustes puntuales.
  Future<Service> updateService(
    String id, {
    required String name,
    required ServiceType type,
    required ServiceCategory category,
    required int estimatedAmount,
    int? billingDay,
    required ServiceFrequency frequency,
    DateTime? firstChargeMonth,
    String? expenseCategoryId,
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
          if (firstChargeMonth != null)
            'first_charge_month': _monthDate(firstChargeMonth),
          'category_id': expenseCategoryId,
          'active': active,
        })
        .eq('id', id)
        .select()
        .single();
    final service = Service.fromJson(row);

    await _client
        .from('service_payments')
        .update({'amount': estimatedAmount})
        .eq('service_id', id)
        .eq('status', PaymentStatus.pendiente.wire)
        .eq('amount_overridden', false)
        .gte('due_date', _date(_today()));

    await _dropObsoletePayments(service);
    return service;
  }

  /// Borra los pagos —del mes en curso en adelante— que la configuración
  /// actual ya no contempla: meses fuera del ciclo (un servicio que pasó de
  /// mensual a anual), vencimientos con el día de cobro viejo, o todos si el
  /// servicio quedó inactivo. La generación los vuelve a crear con la fecha
  /// correcta.
  ///
  /// Sólo toca pagos pendientes, sin transacción asociada y sin monto ajustado
  /// a mano; lo demás es dato del usuario y se respeta.
  Future<void> _dropObsoletePayments(Service service) async {
    final now = _today();
    final rows = await _client
        .from('service_payments')
        .select('id, due_date')
        .eq('service_id', service.id)
        .eq('status', PaymentStatus.pendiente.wire)
        .eq('amount_overridden', false)
        .isFilter('transaction_id', null)
        .gte('due_date', _date(DateTime(now.year, now.month)));

    final obsolete = <String>[];
    for (final row in rows) {
      final due = DateTime.parse(row['due_date'] as String);
      final month = DateTime(due.year, due.month);
      final keep = service.autoGenerates &&
          service.occursIn(month) &&
          service.dueDateFor(month) == due;
      if (!keep) obsolete.add(row['id'] as String);
    }
    if (obsolete.isEmpty) return;
    await _client.from('service_payments').delete().inFilter('id', obsolete);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  // -------------------------- service_payments -------------------------

  /// Pagos con vencimiento en el rango `[start, end)` (mes financiero).
  Future<List<ServicePayment>> fetchPaymentsBetween(
    String householdId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _client
        .from('service_payments')
        .select()
        .eq('household_id', householdId)
        .gte('due_date', _date(start))
        .lt('due_date', _date(end))
        .order('due_date', ascending: true);
    return rows.map(ServicePayment.fromJson).toList();
  }

  /// Pagos pendientes con vencimiento desde [from] en adelante (para programar
  /// los recordatorios de notificación).
  Future<List<ServicePayment>> fetchPendingFrom(
    String householdId,
    DateTime from,
  ) async {
    final rows = await _client
        .from('service_payments')
        .select()
        .eq('household_id', householdId)
        .eq('status', PaymentStatus.pendiente.wire)
        .gte('due_date', _date(from))
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

  /// Genera la instancia de pago del mes para los servicios FIJOS activos con
  /// `billing_day` **a los que les toca cobro ese mes** según su frecuencia:
  /// un servicio anual anclado en marzo sólo genera pago en marzo.
  ///
  /// Regla: **un pago por mes y por servicio**. Si el servicio ya tiene un pago
  /// ese mes no se crea otro, aunque el día de cobro haya cambiado (antes eso
  /// dejaba dos pendientes en el mismo mes: el del día viejo y el del nuevo).
  ///
  /// De paso limpia los pagos fantasma del mes: los que quedaron de la época
  /// en que todo servicio fijo cobraba mes a mes. Sólo borra pendientes, sin
  /// transacción y sin monto ajustado a mano.
  Future<void> generateMonthlyPayments(
    String householdId,
    DateTime month, {
    List<Service>? services,
  }) async {
    final all = services ?? await fetchServices(householdId);
    final auto = all.where((s) => s.autoGenerates).toList();
    if (auto.isEmpty) return;

    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final existing = await fetchPaymentsBetween(householdId, start, end);
    final withPayment = {for (final p in existing) p.serviceId};

    final rows = <Map<String, dynamic>>[];
    final obsolete = <String>[];
    for (final s in auto) {
      if (s.occursIn(month)) {
        if (withPayment.contains(s.id)) continue; // ya tiene el pago del mes
        rows.add({
          'household_id': householdId,
          'service_id': s.id,
          'user_id': _uid,
          'due_date': _date(s.dueDateFor(month)!),
          'amount': s.estimatedAmount,
          'status': PaymentStatus.pendiente.wire,
        });
      } else {
        // Mes fuera del ciclo: se borran los pagos automáticos que sobraron.
        obsolete.addAll(
          existing
              .where((p) => p.serviceId == s.id && _isDisposable(p))
              .map((p) => p.id),
        );
      }
    }

    if (rows.isNotEmpty) {
      // ignoreDuplicates protege ante dos clientes generando el mismo mes.
      await _client.from('service_payments').upsert(
            rows,
            onConflict: 'service_id,due_date',
            ignoreDuplicates: true,
          );
    }
    if (obsolete.isNotEmpty) {
      await _client.from('service_payments').delete().inFilter('id', obsolete);
    }
  }

  /// Un pago se puede borrar/regenerar sin perder información del usuario:
  /// sigue pendiente, no tiene gasto asociado y nadie le ajustó el monto.
  bool _isDisposable(ServicePayment p) =>
      !p.isPaid && p.transactionId == null && !p.amountOverridden;

  /// Crea manualmente una instancia de pago (útil para servicios esporádicos).
  /// Queda marcada como monto propio del período (`amount_overridden`): la
  /// escribió el usuario, así que ni la propagación de monto ni la limpieza de
  /// pagos fuera de ciclo la tocan.
  ///
  /// La BD tiene UNIQUE (service_id, due_date): dos vencimientos del mismo
  /// servicio no pueden compartir fecha.
  Future<ServicePayment> createPayment({
    required String householdId,
    required String serviceId,
    required DateTime dueDate,
    required int amount,
  }) async {
    try {
      final row = await _client
          .from('service_payments')
          .insert({
            'household_id': householdId,
            'service_id': serviceId,
            'user_id': _uid,
            'due_date': _date(dueDate),
            'amount': amount,
            'amount_overridden': true,
            'status': PaymentStatus.pendiente.wire,
          })
          .select()
          .single();
      return ServicePayment.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ServiceRepositoryException(
          'Ese servicio ya tiene un pago con esa fecha de vencimiento.',
        );
      }
      rethrow;
    }
  }

  /// Ajusta el monto de UN período concreto (la suscripción subió sólo este
  /// mes, la cuenta de luz llegó más alta, etc.). Si el pago ya estaba pagado,
  /// sincroniza también la transacción de gasto que lo respalda.
  ///
  /// La transacción se actualiza PRIMERO: la RLS sólo deja modificarla a su
  /// autor, y si el ajuste lo intenta otro miembro se aborta antes de tocar el
  /// pago (si no, el pago diría un monto y el gasto otro).
  Future<ServicePayment> updatePaymentAmount({
    required ServicePayment payment,
    required int amount,
  }) async {
    if (payment.transactionId != null) {
      final updated = await _client
          .from('transactions')
          .update({'amount': amount})
          .eq('id', payment.transactionId!)
          .select('id');
      if (updated.isEmpty) {
        throw const ServiceRepositoryException(
          'Sólo quien registró el pago puede cambiar su monto.',
        );
      }
    }

    final row = await _client
        .from('service_payments')
        .update({'amount': amount, 'amount_overridden': true})
        .eq('id', payment.id)
        .select()
        .single();
    return ServicePayment.fromJson(row);
  }

  /// Marca un pago como pagado: crea la transacción de gasto correspondiente y
  /// enlaza ambos registros (`transaction_id` ↔ `service_id`).
  /// [amount] permite pagar por un monto distinto al estimado (la boleta llegó
  /// más alta, la suscripción subió). El monto queda guardado en el pago del
  /// período, marcado como ajustado a mano.
  Future<void> markAsPaid({
    required String householdId,
    required ServicePayment payment,
    required String? categoryId,
    String? accountId,
    DateTime? paidDate,
    int? amount,
    String? serviceName,
  }) async {
    final date = paidDate ?? DateTime.now();
    final effectiveAmount = amount ?? payment.amount.round();
    final changed = effectiveAmount != payment.amount.round();

    // 1. Crea la transacción de gasto enlazada al servicio (a nombre de quien
    //    paga: RLS de transactions exige user_id = auth.uid()).
    final tx = await _client
        .from('transactions')
        .insert({
          'household_id': householdId,
          'user_id': _uid,
          'account_id': accountId,
          'type': TransactionType.expense.wire,
          'amount': effectiveAmount,
          'date': _date(date),
          'description':
              serviceName == null ? 'Pago de servicio' : 'Pago $serviceName',
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
          if (changed) ...{
            'amount': effectiveAmount,
            'amount_overridden': true,
          },
        })
        .eq('id', payment.id);
  }

  /// Revierte un pago: borra la transacción enlazada y vuelve a 'pendiente'.
  ///
  /// La RLS de `transactions` sólo deja borrar al autor. Si el borrado no
  /// afecta filas, se aborta en vez de dejar el gasto huérfano contando doble.
  Future<void> markAsPending(ServicePayment payment) async {
    if (payment.transactionId != null) {
      final deleted = await _client
          .from('transactions')
          .delete()
          .eq('id', payment.transactionId!)
          .select('id');
      if (deleted.isEmpty) {
        throw ServiceRepositoryException(
          'Sólo quien registró el pago puede revertirlo.',
        );
      }
    }
    await _client.from('service_payments').update({
      'status': PaymentStatus.pendiente.wire,
      'paid_date': null,
      'transaction_id': null,
    }).eq('id', payment.id);
  }
}

/// Error de negocio con mensaje listo para mostrar al usuario.
class ServiceRepositoryException implements Exception {
  const ServiceRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(ref.watch(supabaseClientProvider)),
);
