import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/prefs_provider.dart';

/// Mini-tutorial de una vista: carrusel en un bottom sheet que se muestra
/// automáticamente la primera vez (vía [FeatureTourButton]) y puede reabrirse
/// con el botón de ayuda del AppBar.
class FeatureTour {
  const FeatureTour({required this.id, required this.slides});

  /// Identificador estable: forma la clave de persistencia `tour_seen_<id>`.
  final String id;
  final List<TourSlide> slides;
}

class TourSlide {
  const TourSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Si el tour [arg] ya se mostró en este dispositivo.
class TourSeenController extends FamilyNotifier<bool, String> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build(String arg) => _prefs.getBool('tour_seen_$arg') ?? false;

  Future<void> markSeen() async {
    state = true;
    await _prefs.setBool('tour_seen_$arg', true);
  }
}

final tourSeenProvider = NotifierProvider.family<TourSeenController, bool,
    String>(TourSeenController.new);

/// Abre el carrusel del tour. Lo marca como visto de inmediato, así descartar
/// el sheet (deslizar/tocar afuera) también cuenta como visto.
Future<void> showFeatureTour(
  BuildContext context,
  WidgetRef ref,
  FeatureTour tour,
) {
  ref.read(tourSeenProvider(tour.id).notifier).markSeen();
  return showModalBottomSheet<void>(
    context: context,
    // En el navigator raíz: si no, el sheet queda dentro de la pestaña del
    // shell y el FAB "+" y la barra inferior se dibujan encima del carrusel.
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FeatureTourSheet(tour: tour),
  );
}

/// Botón de ayuda para el AppBar de una vista. Además, la primera vez que la
/// vista se muestra, abre el tour automáticamente.
class FeatureTourButton extends ConsumerStatefulWidget {
  const FeatureTourButton({super.key, required this.tour});
  final FeatureTour tour;

  @override
  ConsumerState<FeatureTourButton> createState() => _FeatureTourButtonState();
}

class _FeatureTourButtonState extends ConsumerState<FeatureTourButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(tourSeenProvider(widget.tour.id))) {
        showFeatureTour(context, ref, widget.tour);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showFeatureTour(context, ref, widget.tour),
      icon: const Icon(Icons.help_outline),
      tooltip: 'Cómo funciona',
    );
  }
}

class _FeatureTourSheet extends StatefulWidget {
  const _FeatureTourSheet({required this.tour});
  final FeatureTour tour;

  @override
  State<_FeatureTourSheet> createState() => _FeatureTourSheetState();
}

class _FeatureTourSheetState extends State<_FeatureTourSheet> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == widget.tour.slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      Navigator.pop(context);
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
    final slides = widget.tour.slides;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _TourSlideView(slide: slides[i]),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 20 : 8,
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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(_isLast ? 'Entendido' : 'Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourSlideView extends StatelessWidget {
  const _TourSlideView({required this.slide});
  final TourSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(slide.icon, size: 42, color: scheme.primary),
        ),
        const SizedBox(height: 20),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
        ),
      ],
    );
  }
}
