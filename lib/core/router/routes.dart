/// Rutas declarativas de la app. El `name` se usa con `context.goNamed/pushNamed`
/// y `path` con go_router.
enum AppRoute {
  // Autenticación / bloqueo (fuera del shell).
  login('/login', 'login'),
  register('/register', 'register'),
  forgotPassword('/forgot-password', 'forgot-password'),
  lock('/lock', 'lock'),

  // Pestañas del shell.
  dashboard('/', 'dashboard'),
  transactions('/transactions', 'transactions'),
  services('/services', 'services'),
  settings('/settings', 'settings'),

  // Pantallas full-screen (se abren sobre el shell).
  transactionForm('/transaction-form', 'transaction-form'),
  serviceForm('/service-form', 'service-form'),
  serviceDetail('/service-detail', 'service-detail'),
  categories('/categories', 'categories'),
  accounts('/accounts', 'accounts'),
  sharing('/sharing', 'sharing'),
  budgets('/budgets', 'budgets'),
  trends('/trends', 'trends'),
  recurringIncomes('/recurring-incomes', 'recurring-incomes'),
  savings('/savings', 'savings'),
  onboarding('/onboarding', 'onboarding');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}
