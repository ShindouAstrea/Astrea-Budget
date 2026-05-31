import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/prefs_provider.dart';

/// Una paleta predefinida: solo cambia el color de marca (seed). La semántica
/// de ingresos/gastos (verde/rojo) se mantiene fija para no perder claridad.
class ThemePreset {
  const ThemePreset(this.id, this.label, this.seed);

  final String id;
  final String label;
  final Color seed;
}

/// Paletas disponibles en Ajustes.
const List<ThemePreset> kThemePresets = [
  ThemePreset('oceano', 'Océano', Color(0xFF2563EB)),
  ThemePreset('bosque', 'Bosque', Color(0xFF16A34A)),
  ThemePreset('lavanda', 'Lavanda', Color(0xFF8B5CF6)),
  ThemePreset('atardecer', 'Atardecer', Color(0xFFF97316)),
  ThemePreset('magenta', 'Magenta', Color(0xFFEC4899)),
  ThemePreset('grafito', 'Grafito', Color(0xFF475569)),
];

ThemePreset _presetById(String? id) =>
    kThemePresets.firstWhere((p) => p.id == id, orElse: () => kThemePresets.first);

/// Estado de apariencia: modo (sistema/claro/oscuro) + paleta elegida.
class ThemeSettings {
  const ThemeSettings({required this.mode, required this.preset});

  final ThemeMode mode;
  final ThemePreset preset;

  ThemeSettings copyWith({ThemeMode? mode, ThemePreset? preset}) =>
      ThemeSettings(mode: mode ?? this.mode, preset: preset ?? this.preset);
}

/// Administra el modo de tema y la paleta, persistiéndolos en SharedPreferences.
class ThemeController extends Notifier<ThemeSettings> {
  static const _kMode = 'theme_mode';
  static const _kPreset = 'theme_preset';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  ThemeSettings build() {
    final modeIndex = _prefs.getInt(_kMode) ?? ThemeMode.system.index;
    return ThemeSettings(
      mode: ThemeMode.values[modeIndex],
      preset: _presetById(_prefs.getString(_kPreset)),
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs.setInt(_kMode, mode.index);
  }

  Future<void> setPreset(ThemePreset preset) async {
    state = state.copyWith(preset: preset);
    await _prefs.setString(_kPreset, preset.id);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeSettings>(ThemeController.new);
