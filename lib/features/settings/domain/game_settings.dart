import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage.dart';

class GameSettings {
  final bool sound;
  final bool haptics;

  /// Dim tiles that are visible but blocked.
  final bool dimBlockedTiles;
  final bool reduceMotion;

  const GameSettings({
    this.sound = true,
    this.haptics = true,
    this.dimBlockedTiles = false,
    this.reduceMotion = false,
  });

  GameSettings copyWith({
    bool? sound,
    bool? haptics,
    bool? dimBlockedTiles,
    bool? reduceMotion,
  }) =>
      GameSettings(
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dimBlockedTiles: dimBlockedTiles ?? this.dimBlockedTiles,
        reduceMotion: reduceMotion ?? this.reduceMotion,
      );
}

/// Simple key/value settings live in SharedPreferences.
class SettingsNotifier extends Notifier<GameSettings> {
  static const _sound = 'settings.sound';
  static const _haptics = 'settings.haptics';
  static const _dim = 'settings.dimBlocked';
  static const _motion = 'settings.reduceMotion';

  @override
  GameSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return GameSettings(
      sound: p.getBool(_sound) ?? true,
      haptics: p.getBool(_haptics) ?? true,
      dimBlockedTiles: p.getBool(_dim) ?? false,
      reduceMotion: p.getBool(_motion) ?? false,
    );
  }

  void update(GameSettings s) {
    final p = ref.read(sharedPreferencesProvider);
    p.setBool(_sound, s.sound);
    p.setBool(_haptics, s.haptics);
    p.setBool(_dim, s.dimBlockedTiles);
    p.setBool(_motion, s.reduceMotion);
    state = s;
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);
