import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/household.dart';
import 'household_controller.dart';

/// Abre la hoja para cambiar de presupuesto activo o crear uno compartido.
Future<void> showHouseholdSwitcher(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const HouseholdSwitcherSheet(),
  );
}

/// Chip para la AppBar que muestra el presupuesto activo y permite cambiarlo.
/// Así el usuario siempre sabe en qué presupuesto está, desde cualquier vista.
class HouseholdIndicator extends ConsumerWidget {
  const HouseholdIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(currentHouseholdProvider).valueOrNull;
    if (household == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final shared = !household.isPersonal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ActionChip(
        avatar: Icon(
          shared ? Icons.group_outlined : Icons.person_outline,
          size: 18,
          color: shared ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
        ),
        label: Text(
          household.name,
          style: TextStyle(
            color:
                shared ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: shared ? scheme.secondaryContainer : null,
        side: shared ? BorderSide.none : null,
        onPressed: () => showHouseholdSwitcher(context),
      ),
    );
  }
}

/// Hoja para cambiar de presupuesto activo o crear uno compartido.
class HouseholdSwitcherSheet extends ConsumerWidget {
  const HouseholdSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final households = ref.watch(householdsProvider).valueOrNull ?? const [];
    final activeId = ref.watch(currentHouseholdProvider).valueOrNull?.id;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cambiar de presupuesto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          for (final Household h in households)
            ListTile(
              leading: Icon(
                h.isPersonal ? Icons.person_outline : Icons.group_outlined,
              ),
              title: Text(h.name),
              subtitle: Text(h.isPersonal ? 'Personal' : 'Compartido'),
              trailing: activeId == h.id
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              onTap: () {
                ref.read(householdActionsProvider).switchActive(h.id);
                Navigator.pop(context);
              },
            ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.add, color: scheme.primary),
            title: const Text('Crear presupuesto compartido'),
            onTap: () => _createShared(context, ref),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _createShared(BuildContext context, WidgetRef ref) async {
    // Capturamos antes de cerrar la hoja: tras `pop` el contexto/ref mueren.
    final actions = ref.read(householdActionsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo presupuesto compartido'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre (ej. Casa)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text.isEmpty ? null : text);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (navigator.canPop()) navigator.pop();
    if (name == null) return;
    try {
      await actions.createShared(name);
      messenger.showSnackBar(
        SnackBar(content: Text('Presupuesto "$name" creado')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo crear (¿máximo de 3?)')),
      );
    }
  }
}
