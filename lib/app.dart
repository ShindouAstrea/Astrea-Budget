import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
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
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Astrea Budget',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
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
