import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_error_messages.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/accounts/presentation/accounts_page.dart';
import '../../features/budgets/presentation/budgets_page.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/households/presentation/sharing_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/recurring/presentation/recurring_incomes_page.dart';
import '../../features/savings/presentation/savings_page.dart';
import '../../features/security/presentation/lock_page.dart';
import '../../features/security/presentation/security_controller.dart';
import '../../features/services/domain/service.dart';
import '../../features/services/presentation/service_detail_page.dart';
import '../../features/services/presentation/service_form_page.dart';
import '../../features/services/presentation/services_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/trends/presentation/trends_page.dart';
import '../../features/transactions/domain/transaction.dart';
import '../../features/transactions/presentation/transaction_form_page.dart';
import '../../features/transactions/presentation/transactions_page.dart';
import '../widgets/app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Hace que go_router reevalúe el `redirect` cuando cambia la sesión o el
/// bloqueo. Escucha **directamente** el stream de auth de Supabase (más fiable
/// que pasar por un provider) y, vía `ref.listen`, el estado de bloqueo.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        // El enlace de "recuperar contraseña" abre la app por deep link: el SDK
        // canjea el código, deja una sesión y emite este evento. Sin la bandera,
        // el guard mandaría al inicio sin pedir la contraseña nueva.
        if (data.event == AuthChangeEvent.passwordRecovery) {
          _ref.read(passwordRecoveryProvider.notifier).start();
        }
        notifyListeners();
      },
      // Aquí es donde Supabase publica los fallos de los deep links (enlace
      // caducado, código ya usado, `code_verifier` de otro dispositivo). Sin
      // este handler se perdían: la app quedaba en el login sin decir nada.
      onError: (Object error, StackTrace _) {
        if (error is AuthException) _report(authErrorMessage(error));
      },
    );

    // El propio enlace puede traer el error en la URL
    // (`?error=access_denied&error_code=otp_expired`). En ese caso Supabase
    // lanza la excepción antes de cualquier llamada de red, así que puede
    // ocurrir antes de que exista esta suscripción: lo leemos también del
    // enlace para no depender de ese orden.
    _watchDeepLinks();

    _ref.listen(appLockProvider, (_, _) => notifyListeners());
    _ref.listen(onboardingSeenProvider, (_, _) => notifyListeners());
    _ref.listen(passwordRecoveryProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
  late final StreamSubscription<AuthState> _authSub;
  StreamSubscription<Uri>? _linkSub;

  /// Evita mostrar dos veces el mismo enlace: al arrancar en frío llega por
  /// `getInitialLink()` y también por el stream.
  String? _lastHandledLink;

  void _watchDeepLinks() {
    if (kIsWeb) return;
    final links = AppLinks();
    _linkSub = links.uriLinkStream.listen(
      _inspectLink,
      onError: (Object _, StackTrace _) {},
    );
    // El enlace que arrancó la app no se reemite en el stream si otro oyente
    // (el propio SDK de Supabase) se suscribió antes.
    unawaited(
      links.getInitialLink().then(
        (uri) => uri == null ? null : _inspectLink(uri),
        onError: (Object _, StackTrace _) {},
      ),
    );
  }

  void _inspectLink(Uri uri) {
    final key = uri.toString();
    if (key == _lastHandledLink) return;
    _lastHandledLink = key;

    final message = authLinkErrorMessage(uri);
    if (message != null) _report(message);
  }

  void _report(String message) =>
      _ref.read(authLinkErrorProvider.notifier).report(message);

  @override
  void dispose() {
    _authSub.cancel();
    _linkSub?.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.dashboard.path,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Lee la sesión en vivo desde Supabase (evita valores obsoletos).
      final user = Supabase.instance.client.auth.currentUser;
      final loggedIn = user != null;
      final isGuest = user?.isAnonymous ?? false;
      final locked = ref.read(appLockProvider);
      final loc = state.matchedLocation;

      final onAuthPage = loc == AppRoute.login.path ||
          loc == AppRoute.register.path ||
          loc == AppRoute.forgotPassword.path;
      final onLockPage = loc == AppRoute.lock.path;
      final onResetPage = loc == AppRoute.resetPassword.path;

      // 1. Sin sesión: sólo se permiten las páginas de auth.
      if (!loggedIn) return onAuthPage ? null : AppRoute.login.path;

      // 2. Con sesión pero bloqueada: forzar pantalla de bloqueo.
      if (locked) return onLockPage ? null : AppRoute.lock.path;

      // 3. Llegó por el enlace de recuperación: no se sale de esa pantalla
      //    hasta definir la contraseña nueva (o cancelar, que cierra sesión).
      if (ref.read(passwordRecoveryProvider)) {
        return onResetPage ? null : AppRoute.resetPassword.path;
      }
      if (onResetPage) return AppRoute.dashboard.path;

      // 4. Primera vez en el dispositivo: mostrar el tutorial de bienvenida.
      if (!ref.read(onboardingSeenProvider)) {
        return loc == AppRoute.onboarding.path
            ? null
            : AppRoute.onboarding.path;
      }

      // 5. Invitado: puede entrar a registro para convertir su cuenta.
      if (isGuest && loc == AppRoute.register.path) return null;

      // 6. Autenticado y desbloqueado: salir de auth/lock hacia el inicio.
      if (onAuthPage || onLockPage) return AppRoute.dashboard.path;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoute.resetPassword.path,
        name: AppRoute.resetPassword.name,
        builder: (_, _) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoute.lock.path,
        name: AppRoute.lock.name,
        builder: (_, _) => const LockPage(),
      ),

      // Pantallas full-screen (sobre el shell).
      GoRoute(
        path: AppRoute.transactionForm.path,
        name: AppRoute.transactionForm.name,
        builder: (_, state) =>
            TransactionFormPage(existing: state.extra as TransactionModel?),
      ),
      GoRoute(
        path: AppRoute.serviceForm.path,
        name: AppRoute.serviceForm.name,
        builder: (_, state) =>
            ServiceFormPage(existing: state.extra as Service?),
      ),
      GoRoute(
        path: AppRoute.serviceDetail.path,
        name: AppRoute.serviceDetail.name,
        builder: (_, state) =>
            ServiceDetailPage(service: state.extra as Service),
      ),
      GoRoute(
        path: AppRoute.categories.path,
        name: AppRoute.categories.name,
        builder: (_, _) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoute.accounts.path,
        name: AppRoute.accounts.name,
        builder: (_, _) => const AccountsPage(),
      ),
      GoRoute(
        path: AppRoute.sharing.path,
        name: AppRoute.sharing.name,
        builder: (_, _) => const SharingPage(),
      ),
      GoRoute(
        path: AppRoute.budgets.path,
        name: AppRoute.budgets.name,
        builder: (_, _) => const BudgetsPage(),
      ),
      GoRoute(
        path: AppRoute.trends.path,
        name: AppRoute.trends.name,
        builder: (_, _) => const TrendsPage(),
      ),
      GoRoute(
        path: AppRoute.recurringIncomes.path,
        name: AppRoute.recurringIncomes.name,
        builder: (_, _) => const RecurringIncomesPage(),
      ),
      GoRoute(
        path: AppRoute.savings.path,
        name: AppRoute.savings.name,
        builder: (_, _) => const SavingsPage(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (_, _) => const OnboardingPage(),
      ),

      // Shell con barra inferior (4 pestañas con estado preservado).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.dashboard.path,
                name: AppRoute.dashboard.name,
                builder: (_, _) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.transactions.path,
                name: AppRoute.transactions.name,
                builder: (_, _) => const TransactionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.services.path,
                name: AppRoute.services.name,
                builder: (_, _) => const ServicesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings.path,
                name: AppRoute.settings.name,
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
