import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/accounts/presentation/accounts_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/households/presentation/household_controller.dart';
import 'features/profile/presentation/profile_controller.dart';
import 'features/security/presentation/security_controller.dart';

class AstreaBudgetApp extends ConsumerStatefulWidget {
  const AstreaBudgetApp({super.key});

  @override
  ConsumerState<AstreaBudgetApp> createState() => _AstreaBudgetAppState();
}

class _AstreaBudgetAppState extends ConsumerState<AstreaBudgetApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Evalúa el bloqueo al arrancar (bloquea si hay PIN configurado).
    Future.microtask(
      () => ref.read(appLockProvider.notifier).evaluateOnStartup(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-bloquea al volver del segundo plano (si hay PIN configurado).
    if (state == AppLifecycleState.paused) {
      final settings = ref.read(securityControllerProvider).valueOrNull;
      if (settings?.pinEnabled ?? false) {
        ref.read(appLockProvider.notifier).lock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Al cambiar de sesión (login/logout) limpia el estado por-usuario en
    // caché: households, perfil, invitaciones y selección de presupuesto/cuenta.
    // Sin esto, un nuevo usuario vería los datos cacheados del anterior.
    ref.listen(authStateChangesProvider, (_, next) {
      final event = next.valueOrNull?.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedOut) {
        // Re-lee la selección con la clave del nuevo usuario y refresca los
        // datos por-usuario (cascada para el resto vía activeHouseholdId).
        ref.invalidate(currentHouseholdIdProvider);
        ref.invalidate(currentAccountIdProvider);
        ref.invalidate(householdsProvider);
        ref.invalidate(currentProfileProvider);
        ref.invalidate(receivedInvitationsProvider);
      }
    });

    final router = ref.watch(goRouterProvider);
    final theme = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Astrea Budget',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(seed: theme.preset.seed),
      darkTheme: AppTheme.dark(seed: theme.preset.seed),
      themeMode: theme.mode,
      // Localización es_CL (formato de moneda y fechas).
      locale: const Locale('es', 'CL'),
      supportedLocales: const [Locale('es', 'CL'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
