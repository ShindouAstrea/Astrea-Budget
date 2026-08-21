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
import '../../onboarding/presentation/feature_tour.dart';
import '../../onboarding/presentation/feature_tours.dart';
import '../domain/service.dart';
import '../domain/service_costs.dart';
import 'services_controller.dart';

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final payments = ref.watch(monthlyPaymentsProvider).value ?? [];
    // Estado del mes por servicio.
    final statusByService = <String, PaymentStatus>{};
    for (final p in payments) {
      // Si hay al menos un pago pendiente, el servicio queda "pendiente".
      final current = statusByService[p.serviceId];
      if (current == null || (!p.isPaid && current.isPaid)) {
        statusByService[p.serviceId] = p.status;
      }
    }

    final isOwner = ref.watch(isActiveHouseholdOwnerProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: const [
          FeatureTourButton(tour: servicesTour),
          HouseholdIndicator(),
        ],
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
                _FixedCostCard(services: services),
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

/// Cuánto pesan al mes los servicios fijos. Como un anual sólo aparece en su
/// mes, sin este prorrateo no hay forma de saber el costo real de tener todas
/// las suscripciones contratadas.
class _FixedCostCard extends StatelessWidget {
  const _FixedCostCard({required this.services});

  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    final summary = summarizeFixedCosts(services, asOf: DateTime.now());
    if (summary.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Costo fijo mensual',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.currency(summary.monthly),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${Formatters.currency(summary.yearly)} al año',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 20),
            _line(context, Icons.home_outlined, 'Esenciales', summary.essential),
            const SizedBox(height: 4),
            _line(context, Icons.subscriptions_outlined, 'Suscripciones',
                summary.subscriptions),
            const SizedBox(height: 8),
            Text(
              'Los cobros no mensuales se prorratean: un anual de \$60.000 '
              'cuenta como \$5.000 al mes.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, IconData icon, String label, double v) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          Formatters.currency(v),
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
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

  /// `Suscripción · Anual · Vence el 5 · $9.900`. La frecuencia se muestra
  /// siempre que no sea mensual: es lo que explica por qué un servicio no
  /// aparece todos los meses.
  String _subtitle() {
    final parts = <String>[service.category.label];
    if (service.isFixed && !service.frequency.isMonthly) {
      parts.add(service.frequency.label);
    }
    if (service.isFixed && service.billingDay != null) {
      parts.add(Formatters.billingDay(service.billingDay!));
    } else if (!service.isFixed) {
      parts.add('Esporádico');
    }
    parts.add(Formatters.currency(service.estimatedAmount));
    if (service.lastChargeMonth != null) {
      parts.add('hasta ${Formatters.monthYear(service.lastChargeMonth!)}');
    }
    return parts.join(' · ');
  }

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
        subtitle: Text(_subtitle()),
        trailing: _StatusBadge(
          status: status,
          active: service.active,
          ended: service.endedBefore(DateTime.now()),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.active,
    required this.ended,
  });
  final PaymentStatus? status;
  final bool active;

  /// Su mes de término ya pasó: no volverá a generar pagos.
  final bool ended;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return const Chip(
        label: Text('Inactivo'),
        visualDensity: VisualDensity.compact,
      );
    }
    if (ended) {
      return const Chip(
        label: Text('Terminado'),
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
