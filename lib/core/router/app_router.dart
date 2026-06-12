import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
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
  _RouterRefresh(Ref ref) {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
    ref.listen(appLockProvider, (_, _) => notifyListeners());
    ref.listen(onboardingSeenProvider, (_, _) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _authSub;

  @override
  void dispose() {
    _authSub.cancel();
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

      // 1. Sin sesión: sólo se permiten las páginas de auth.
      if (!loggedIn) return onAuthPage ? null : AppRoute.login.path;

      // 2. Con sesión pero bloqueada: forzar pantalla de bloqueo.
      if (locked) return onLockPage ? null : AppRoute.lock.path;

      // 3. Primera vez en el dispositivo: mostrar el tutorial de bienvenida.
      if (!ref.read(onboardingSeenProvider)) {
        return loc == AppRoute.onboarding.path
            ? null
            : AppRoute.onboarding.path;
      }

      // 4. Invitado: puede entrar a registro para convertir su cuenta.
      if (isGuest && loc == AppRoute.register.path) return null;

      // 5. Autenticado y desbloqueado: salir de auth/lock hacia el inicio.
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
