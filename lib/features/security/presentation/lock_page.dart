import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/security_repository.dart';
import 'security_controller.dart';

/// Pantalla de bloqueo: solicita PIN o biometría para desbloquear la app.
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final repo = ref.read(securityRepositoryProvider);
    if (!await repo.isBiometricEnabled) return;
    if (!await repo.canUseBiometrics) return;
    final ok = await repo.authenticateBiometric();
    if (ok && mounted) ref.read(appLockProvider.notifier).unlock();
  }

  Future<void> _onDigit(String digit) async {
    if (_pin.length >= 6 || _checking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length >= 4) await _verify();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final ok = await ref.read(securityRepositoryProvider).verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      ref.read(appLockProvider.notifier).unlock();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'PIN incorrecto';
        _pin = '';
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 48, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                'Ingresa tu PIN',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              // Indicadores del PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? scheme.primary : Colors.transparent,
                      border: Border.all(color: scheme.primary, width: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 24,
                child: _error != null
                    ? Text(
                        _error!,
                        style: TextStyle(color: scheme.error),
                      )
                    : null,
              ),
              const Spacer(),
              _Keypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onBiometric: _tryBiometric,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onBiometric,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onBiometric;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return SizedBox(
        width: 76,
        height: 76,
        child: TextButton(
          onPressed: onTap ?? () => onDigit(label),
          style: TextButton.styleFrom(shape: const CircleBorder()),
          child: child ??
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
        ),
      );
    }

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) key(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            key('', onTap: onBiometric, child: const Icon(Icons.fingerprint)),
            key('0'),
            key('', onTap: onBackspace, child: const Icon(Icons.backspace_outlined)),
          ],
        ),
      ],
    );
  }
}
