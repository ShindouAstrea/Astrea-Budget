import 'package:flutter/material.dart';

/// Vista de estado vacío reutilizable (sin datos todavía).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    this.message,
    this.action,
  }) : assert(icon != null || illustration != null,
            'Provee un icon o una illustration');

  /// Icono de Material (fallback). Ignorado si se entrega [illustration].
  final IconData? icon;

  /// Ilustración de marca (p. ej. [BrandEmptyArt]). Tiene prioridad sobre [icon].
  final Widget? illustration;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: scheme.primary),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Vista de error con acción de reintento.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helpers para feedback consistente (SnackBars).
extension FeedbackX on BuildContext {
  void showSuccess(String message) => _snack(message, isError: false);
  void showError(String message) => _snack(message, isError: true);

  void _snack(String message, {required bool isError}) {
    final scheme = Theme.of(this).colorScheme;
    // Fondo y texto con contraste garantizado en claro y oscuro.
    final background = isError ? scheme.errorContainer : scheme.inverseSurface;
    final foreground =
        isError ? scheme.onErrorContainer : scheme.onInverseSurface;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: foreground,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
        ),
      );
  }
}
