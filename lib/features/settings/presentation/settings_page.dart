import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../security/presentation/security_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final security = ref.watch(securityControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // -------- Perfil --------
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(user?.email ?? 'Usuario'),
              subtitle: const Text('Sesión iniciada'),
            ),
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
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Categorías'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed(AppRoute.categories.name),
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

  /// Diálogo para definir un PIN (con confirmación).
  Future<void> _setPinDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Definir PIN'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'PIN (4 a 6 dígitos)'),
                validator: Validators.pin,
              ),
              TextFormField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Confirmar PIN'),
                validator: (v) =>
                    v == controller.text ? null : 'Los PIN no coinciden',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    controller.dispose();
    confirmController.dispose();

    if (pin != null) {
      await ref.read(securityControllerProvider.notifier).setPin(pin);
      if (context.mounted) context.showSuccess('PIN activado');
    }
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
