import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/brand_illustration.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

/// Si el usuario ya vio el tutorial de bienvenida (persistido en el
/// dispositivo). Mientras sea `false`, el router redirige a /onboarding.
class OnboardingSeenController extends Notifier<bool> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() => _prefs.getBool(_kOnboardingSeenKey) ?? false;

  Future<void> markSeen() async {
    state = true;
    await _prefs.setBool(_kOnboardingSeenKey, true);
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenController, bool>(
        OnboardingSeenController.new);

/// Tutorial de bienvenida: carrusel con las funcionalidades principales.
/// Se muestra automáticamente la primera vez y puede reabrirse desde Ajustes.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: null, // usa el logo de la app
      title: 'Bienvenido a Astrea',
      description: 'Tu presupuesto, claro y simple. En unos pasos te '
          'mostramos lo que puedes hacer con la app.',
    ),
    _Slide(
      icon: Icons.swap_vert,
      title: 'Registra tus movimientos',
      description: 'Anota ingresos y gastos en segundos, organízalos por '
          'categoría y repártelos entre tus cuentas: efectivo, débito, '
          'crédito o ahorro. También puedes transferir entre cuentas.',
    ),
    _Slide(
      icon: Icons.receipt_long_outlined,
      title: 'Servicios y pagos del mes',
      description: 'Agrega tus cuentas fijas (arriendo, luz, suscripciones) '
          'y márcalas como pagadas cada mes. Activa recordatorios para que '
          'ningún vencimiento te tome por sorpresa.',
    ),
    _Slide(
      icon: Icons.donut_small_outlined,
      title: 'Presupuestos y metas',
      description: 'Define un tope mensual por categoría y sigue tu avance '
          'con barras de progreso. Crea metas de ahorro y aporta a ellas '
          'cuando quieras.',
    ),
    _Slide(
      icon: Icons.insights_outlined,
      title: 'Tendencias y proyección',
      description: 'Compara tus últimos meses, mira hacia dónde va tu gasto '
          'y revisa la proyección de cómo cerrarás el mes. Puedes ajustar el '
          'día en que parte tu mes financiero.',
    ),
    _Slide(
      icon: Icons.group_outlined,
      title: 'Comparte tu presupuesto',
      description: 'Invita a tu pareja o familia a un presupuesto compartido: '
          'todos ven los movimientos y cada quien registra los suyos.',
    ),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (!mounted) return;
    // Abierto desde Ajustes → volver; primera vez (redirect) → ir al inicio.
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.dashboard.name);
    }
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // -------- Saltar --------
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Saltar'),
                ),
              ),
            ),

            // -------- Carrusel --------
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),

            // -------- Indicador de páginas --------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? scheme.primary
                          : scheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),

            // -------- Siguiente / Empezar --------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(_isLast ? '¡Empezar!' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// Icono de la lámina; `null` muestra el logo de la app.
  final IconData? icon;
  final String title;
  final String description;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slide.icon == null)
            const BrandLogo(size: 140)
          else
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 64, color: scheme.primary),
            ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }
}
