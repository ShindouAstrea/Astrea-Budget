import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand_illustration.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/enums.dart';
import '../../households/presentation/household_controller.dart';
import '../../households/presentation/household_switcher.dart';
import '../domain/service.dart';
import 'services_controller.dart';

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final payments = ref.watch(monthlyPaymentsProvider).valueOrNull ?? [];
    // Estado del mes por servicio.
    final statusByService = <String, PaymentStatus>{};
    for (final p in payments) {
      // Si hay al menos un pago pendiente, el servicio queda "pendiente".
      final current = statusByService[p.serviceId];
      if (current == null || (!p.isPaid && current.isPaid)) {
        statusByService[p.serviceId] = p.status;
      }
    }

    final isOwner = ref.watch(isActiveHouseholdOwnerProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: const [HouseholdIndicator()],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              heroTag: 'fab-services',
              onPressed: () => context.pushNamed(AppRoute.serviceForm.name),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar los servicios.',
          onRetry: () => ref.invalidate(servicesProvider),
        ),
        data: (services) {
          if (services.isEmpty) {
            return EmptyStateView(
              illustration: const BrandEmptyArt(EmptyArt.services),
              title: 'Sin servicios',
              message:
                  'Agrega tus servicios (arriendo, suscripciones, etc.) para '
                  'seguir tus pagos del mes.',
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(AppRoute.serviceForm.name),
                icon: const Icon(Icons.add),
                label: const Text('Agregar servicio'),
              ),
            );
          }
          final fixed = services.where((s) => s.isFixed).toList();
          final sporadic = services.where((s) => !s.isFixed).toList();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(servicesProvider);
              ref.invalidate(monthlyPaymentsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                if (fixed.isNotEmpty) ...[
                  _SectionHeader('Servicios fijos'),
                  for (final s in fixed)
                    _ServiceTile(service: s, status: statusByService[s.id]),
                ],
                if (sporadic.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionHeader('Servicios esporádicos'),
                  for (final s in sporadic)
                    _ServiceTile(service: s, status: statusByService[s.id]),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.status});

  final Service service;
  final PaymentStatus? status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.pushNamed(
          AppRoute.serviceDetail.name,
          extra: service,
        ),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            service.category == ServiceCategory.suscripcion
                ? Icons.subscriptions_outlined
                : Icons.home_outlined,
            color: scheme.primary,
          ),
        ),
        title: Text(service.name),
        subtitle: Text(
          '${service.category.label} · '
          '${service.isFixed && service.billingDay != null ? Formatters.billingDay(service.billingDay!) : service.frequency.label} · '
          '${Formatters.currency(service.estimatedAmount)}',
        ),
        trailing: _StatusBadge(status: status, active: service.active),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.active});
  final PaymentStatus? status;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return const Chip(
        label: Text('Inactivo'),
        visualDensity: VisualDensity.compact,
      );
    }
    if (status == null) return const Icon(Icons.chevron_right);
    final paid = status!.isPaid;
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: paid ? Colors.green.withValues(alpha: 0.15) : null,
      label: Text(paid ? 'Pagado' : 'Por pagar'),
      labelStyle: TextStyle(
        color: paid ? Colors.green.shade700 : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
