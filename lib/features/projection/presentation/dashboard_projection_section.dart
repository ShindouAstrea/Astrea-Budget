import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'projection_controller.dart';

/// Tarjeta "Proyección de fin de mes": estima con qué balance cerrarás el mes
/// en curso. Sólo se muestra cuando el mes seleccionado está en curso.
class DashboardProjectionSection extends ConsumerWidget {
  const DashboardProjectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider).valueOrNull;
    if (projection == null || !projection.isOngoing) {
      return const SizedBox.shrink();
    }

    final finance = context.finance;
    final scheme = Theme.of(context).colorScheme;
    final balance = projection.projectedBalance;
    final positive = balance >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Proyección de fin de mes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              positive
                  ? 'Si sigues así, cerrarás el mes con'
                  : 'Si sigues así, cerrarás el mes en',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.currency(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: positive ? finance.income : finance.expense,
                  ),
            ),
            const SizedBox(height: 14),
            _Row(
              label: 'Gasto proyectado',
              value: Formatters.currency(projection.projectedExpense),
            ),
            if (projection.pendingServices > 0)
              _Row(
                label: 'Servicios por pagar',
                value: Formatters.currency(projection.pendingServices),
                muted: true,
              ),
            _Row(
              label: 'Gastado hasta hoy',
              value: Formatters.currency(projection.currentExpense),
              muted: true,
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: projection.progress,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Día ${projection.elapsedDays} de ${projection.totalDays} del mes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.muted = false});
  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: muted ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
