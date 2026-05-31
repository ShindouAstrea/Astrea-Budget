import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/budget_cycle.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../households/presentation/household_controller.dart';
import '../../households/presentation/household_switcher.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../security/presentation/security_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(currentProfileProvider);
    final security = ref.watch(securityControllerProvider);

    final name = profile.valueOrNull?.displayName ??
        user?.userMetadata?['name'] as String? ??
        'Usuario';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // -------- Perfil --------
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(name),
              subtitle: Text(user?.email ?? 'Sesión iniciada'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editName(context, ref, name),
            ),
          ),
          const SizedBox(height: 16),

          // -------- Presupuesto --------
          _SectionTitle('Presupuesto'),
          const _BudgetSection(),
          const SizedBox(height: 16),

          // -------- Apariencia --------
          _SectionTitle('Apariencia'),
          const _AppearanceCard(),
          const SizedBox(height: 16),

          // -------- Mes financiero --------
          _SectionTitle('Mes financiero'),
          const _BudgetCycleCard(),
          const SizedBox(height: 16),

          // -------- Recordatorios --------
          _SectionTitle('Recordatorios'),
          Builder(
            builder: (context) {
              final notif = ref.watch(notificationsControllerProvider);
              final controller =
                  ref.read(notificationsControllerProvider.notifier);
              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary:
                          const Icon(Icons.notifications_active_outlined),
                      title: const Text('Avisar pagos por vencer'),
                      subtitle: const Text(
                        'Notifica los servicios fijos desde 3 días antes hasta '
                        'el día de vencimiento, mientras estén pendientes.',
                      ),
                      value: notif.enabled,
                      onChanged: (v) async {
                        final ok = await controller.setEnabled(v);
                        if (!ok && context.mounted) {
                          context.showError(
                            'Activa los permisos de notificación para recibir '
                            'recordatorios.',
                          );
                        }
                      },
                    ),
                    if (notif.enabled) ...[
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: const Text('Hora del recordatorio'),
                        subtitle: const Text('A qué hora avisar cada día'),
                        trailing: Text(
                          notif.time.format(context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: notif.time,
                          );
                          if (picked != null) await controller.setTime(picked);
                        },
                      ),
                      // Solo en debug: dispara una notificación de prueba (~5s).
                      if (kDebugMode) ...[
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.bug_report_outlined),
                          title: const Text('Enviar notificación de prueba'),
                          subtitle: const Text('Llega en ~5 segundos (debug)'),
                          onTap: () async {
                            await controller.sendTest();
                            if (context.mounted) {
                              context.showSuccess(
                                'Prueba programada: llega en ~5 s.',
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // -------- Seguridad --------
          _SectionTitle('Seguridad'),
          security.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => const Card(
              child: ListTile(title: Text('No se pudo cargar la seguridad')),
            ),
            data: (settings) => Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.pin_outlined),
                    title: const Text('Bloqueo con PIN'),
                    subtitle: const Text('Pide un PIN al abrir la app'),
                    value: settings.pinEnabled,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await _setPinDialog(context, ref);
                      } else {
                        await ref
                            .read(securityControllerProvider.notifier)
                            .disablePin();
                      }
                    },
                  ),
                  if (settings.pinEnabled && settings.canUseBiometrics)
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Desbloqueo biométrico'),
                      subtitle: const Text('Usa huella o Face ID'),
                      value: settings.biometricEnabled,
                      onChanged: (v) => ref
                          .read(securityControllerProvider.notifier)
                          .setBiometric(v),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // -------- Preferencias --------
          _SectionTitle('Preferencias'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Cuentas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.accounts.name),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Categorías'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.categories.name),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.donut_small_outlined),
                  title: const Text('Presupuestos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.budgets.name),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: const Text('Ingresos recurrentes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.recurringIncomes.name),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Metas de ahorro'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.savings.name),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Moneda'),
                  subtitle: Text('${Env.defaultCurrency} · ${Env.defaultLocale}'),
                  trailing: const Text('CLP'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -------- Cerrar sesión --------
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await ref.read(authControllerProvider.notifier).signOut();
              if (!ok && context.mounted) {
                context.showError('No se pudo cerrar sesión');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo para definir un PIN (con confirmación). El diálogo gestiona sus
  /// propios controllers (ver [_SetPinDialog]) para evitar usarlos tras dispose.
  Future<void> _setPinDialog(BuildContext context, WidgetRef ref) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _SetPinDialog(),
    );

    if (pin != null) {
      await ref.read(securityControllerProvider.notifier).setPin(pin);
      if (context.mounted) context.showSuccess('PIN activado');
    }
  }

  /// Diálogo para editar el nombre visible del perfil.
  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre visible'),
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (name == null) return;
    await ref.read(profileActionsProvider).updateDisplayName(name);
    if (context.mounted) context.showSuccess('Nombre actualizado');
  }
}

/// Contenido del diálogo "Definir PIN". Es StatefulWidget para que los
/// [TextEditingController] vivan y se liberen con el ciclo de vida del diálogo.
class _SetPinDialog extends StatefulWidget {
  const _SetPinDialog();

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _pin.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Definir PIN'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'PIN (4 a 6 dígitos)'),
              validator: Validators.pin,
            ),
            TextFormField(
              controller: _confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Confirmar PIN'),
              validator: (v) =>
                  v == _pin.text ? null : 'Los PIN no coinciden',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

/// Sección de presupuesto: household activo, selector, compartir e invitaciones.
class _BudgetSection extends ConsumerWidget {
  const _BudgetSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final received =
        ref.watch(receivedInvitationsProvider).valueOrNull ?? const [];
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          child: Column(
            children: [
              householdAsync.when(
                loading: () =>
                    const ListTile(title: Text('Cargando presupuesto...')),
                error: (e, _) =>
                    const ListTile(title: Text('No se pudo cargar')),
                data: (h) => ListTile(
                  leading: Icon(
                    h.isPersonal ? Icons.person_outline : Icons.group_outlined,
                  ),
                  title: Text(h.name),
                  subtitle: Text(h.isPersonal ? 'Personal' : 'Compartido'),
                  trailing: const Icon(Icons.unfold_more),
                  onTap: () => showHouseholdSwitcher(context),
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Compartir y miembros'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(AppRoute.sharing.name),
              ),
            ],
          ),
        ),
        for (final inv in received)
          Card(
            color: scheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined),
              title: Text('Invitación a "${inv.householdName}"'),
              subtitle: Text(
                inv.invitedByName != null
                    ? 'De ${inv.invitedByName}'
                    : 'Te invitaron a un presupuesto compartido',
              ),
              trailing: FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(householdActionsProvider).accept(inv.id);
                    if (context.mounted) {
                      context.showSuccess('Te uniste a ${inv.householdName}');
                    }
                  } catch (_) {
                    if (context.mounted) {
                      context.showError('No se pudo aceptar la invitación');
                    }
                  }
                },
                child: const Text('Aceptar'),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tarjeta del mes financiero: día de corte del ciclo de presupuesto.
class _BudgetCycleCard extends ConsumerWidget {
  const _BudgetCycleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cutoff = ref.watch(budgetCutoffProvider);
    final controller = ref.read(budgetCutoffProvider.notifier);
    final isCalendar = cutoff <= 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Día de inicio del mes'),
                Text(
                  isCalendar ? 'Mes calendario' : 'Día $cutoff',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            Slider(
              value: cutoff.toDouble(),
              min: 1,
              max: 28,
              divisions: 27,
              label: isCalendar ? 'Calendario' : 'Día $cutoff',
              onChanged: (v) => controller.set(v.round()),
            ),
            Text(
              isCalendar
                  ? 'El mes va del día 1 al último día (comportamiento normal).'
                  : 'El mes va del día $cutoff del mes anterior hasta el día '
                      '${cutoff - 1} de este mes. Un ingreso/gasto del día '
                      '$cutoff en adelante cuenta para el mes siguiente.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de apariencia: modo de tema (sistema/claro/oscuro) + paletas.
class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modo'),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {settings.mode},
              onSelectionChanged: (s) => controller.setMode(s.first),
            ),
            const SizedBox(height: 20),
            const Text('Paleta'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final preset in kThemePresets)
                  _PresetSwatch(
                    preset: preset,
                    selected: preset.id == settings.preset.id,
                    onTap: () => controller.setPreset(preset),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetSwatch extends StatelessWidget {
  const _PresetSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Paleta ${preset.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: preset.seed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? onSurface : Colors.transparent,
                  width: 3,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(preset.label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
