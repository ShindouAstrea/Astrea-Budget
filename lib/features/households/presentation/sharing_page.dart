import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/household_member.dart';
import 'household_controller.dart';

/// Gestión del presupuesto compartido activo: invitar, ver miembros y salir.
class SharingPage extends ConsumerWidget {
  const SharingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final isOwner = ref.watch(isActiveHouseholdOwnerProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Compartir')),
      body: householdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
          message: 'No pudimos cargar el presupuesto.',
          onRetry: () => ref.invalidate(currentHouseholdProvider),
        ),
        data: (household) {
          if (household.isPersonal) {
            return EmptyStateView(
              icon: Icons.group_add_outlined,
              title: 'Presupuesto personal',
              message: 'Crea un presupuesto compartido para invitar a otra '
                  'persona y llevar las cuentas juntos.',
              action: FilledButton.icon(
                onPressed: () => _createShared(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Crear presupuesto compartido'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                household.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Presupuesto compartido',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              if (isOwner) ...[
                _InviteSection(),
                const SizedBox(height: 24),
                _PendingInvitations(),
                const SizedBox(height: 24),
              ],
              _MembersSection(householdId: household.id, isOwner: isOwner),
              const SizedBox(height: 24),
              if (!isOwner)
                OutlinedButton.icon(
                  onPressed: () => _leave(context, ref, household.id),
                  icon: const Icon(Icons.logout),
                  label: const Text('Salir del presupuesto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createShared(BuildContext context, WidgetRef ref) async {
    final name = await _promptName(context);
    if (name == null) return;
    try {
      await ref.read(householdActionsProvider).createShared(name);
      if (context.mounted) context.showSuccess('Presupuesto creado');
    } catch (_) {
      if (context.mounted) {
        context.showError('No se pudo crear (¿llegaste al máximo de 3?)');
      }
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salir del presupuesto'),
        content: const Text(
          'Dejarás de ver sus movimientos. Puedes volver con una nueva '
          'invitación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(householdActionsProvider).leave(id);
    if (context.mounted) context.showSuccess('Saliste del presupuesto');
  }
}

Future<String?> _promptName(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
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
}

class _InviteSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InviteSection> createState() => _InviteSectionState();
}

class _InviteSectionState extends ConsumerState<_InviteSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref.read(householdActionsProvider).invite(_email.text);
      if (mounted) {
        context.showSuccess('Invitación enviada');
        _email.clear();
      }
    } catch (_) {
      if (mounted) context.showError('No se pudo enviar la invitación');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitar por correo',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: Validators.email,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sending ? null : _invite,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(64, 56),
                ),
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingInvitations extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(sentInvitationsProvider).valueOrNull ?? const [];
    if (invitations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invitaciones pendientes',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final inv in invitations)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(inv.email),
              subtitle: const Text('Pendiente'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancelar',
                onPressed: () => ref
                    .read(householdActionsProvider)
                    .cancelInvitation(inv.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _MembersSection extends ConsumerWidget {
  const _MembersSection({required this.householdId, required this.isOwner});

  final String householdId;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Miembros',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        membersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const Text('No se pudieron cargar los miembros.'),
          data: (members) => Column(
            children: [
              for (final m in members)
                _MemberTile(
                  member: m,
                  canRemove: isOwner && !m.isMe && !m.role.isOwner,
                  onRemove: () => ref
                      .read(householdActionsProvider)
                      .removeMember(householdId, m.userId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });

  final HouseholdMember member;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            member.displayName.isNotEmpty
                ? member.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
        ),
        title: Text(member.displayName + (member.isMe ? ' (tú)' : '')),
        subtitle: Text(member.role.label),
        trailing: canRemove
            ? IconButton(
                icon: Icon(Icons.person_remove_outlined, color: scheme.error),
                tooltip: 'Quitar',
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}
