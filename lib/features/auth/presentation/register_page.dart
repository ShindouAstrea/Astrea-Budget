import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/presentation/profile_controller.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    final isGuest = ref.read(isGuestProvider);
    final name = _name.text.trim();

    // Invitado: en vez de crear un usuario nuevo, se le asocia correo y
    // contraseña al usuario anónimo actual (conserva todos sus datos).
    final ok = isGuest
        ? await controller.linkAccount(_email.text, _password.text, name)
        : await controller.signUp(_email.text, _password.text, name);
    if (!mounted) return;
    if (ok) {
      if (isGuest) {
        // El perfil se creó con el nombre 'Invitado' (la sesión anónima no
        // tenía correo): se reemplaza por el nombre elegido. Si falla, el
        // trigger on_auth_user_converted lo corrige en el servidor.
        try {
          await ref.read(profileActionsProvider).updateDisplayName(name);
        } catch (_) {}
        if (!mounted) return;
        final user = Supabase.instance.client.auth.currentUser;
        if (user?.emailConfirmedAt != null) {
          // Confirmación de correo desactivada en Supabase: la conversión
          // fue inmediata, no hay nada que esperar.
          context.showSuccess('¡Cuenta creada! Tus datos se conservan.');
          context.go(AppRoute.dashboard.path);
        } else {
          context.showSuccess(
            'Revisa tu correo para confirmar y completar el registro. '
            'Tus datos se conservan.',
          );
          context.pop();
        }
      } else if (Supabase.instance.client.auth.currentSession != null) {
        // Si Supabase devolvió sesión (confirmación de correo desactivada), el
        // guard del router redirige solo al dashboard.
        context.showSuccess('¡Bienvenido a Astrea Budget!');
      } else {
        // Sin sesión: hay que confirmar el correo / iniciar sesión.
        context.showSuccess(
          'Cuenta creada. Revisa tu correo para confirmarla e inicia sesión.',
        );
        context.pop();
      }
    } else {
      final error = ref.read(authControllerProvider).error;
      context.showError(error?.toString() ?? 'No se pudo crear la cuenta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final isGuest = ref.watch(isGuestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isGuest) ...[
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.5),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Estás usando la app como invitado. Al crear tu '
                            'cuenta conservarás todos los datos que ya '
                            'registraste.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Nombre o apodo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          Validators.required(v, field: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        helperText: 'Mínimo 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
