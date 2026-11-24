import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage.dart';

/// Languages the game is translated into. English is the default and is used
/// until the player picks another one (the device language is not applied
/// automatically).
enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'हिन्दी'),
  spanish('es', 'Español'),
  french('fr', 'Français'),
  german('de', 'Deutsch'),
  portuguese('pt', 'Português');

  final String code;

  /// Name written in the language itself, so anyone can find their own.
  final String nativeName;

  const AppLanguage(this.code, this.nativeName);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) => values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.english,
      );
}

@immutable
class GameSettings {
  final bool music;
  final bool sound;
  final bool haptics;
  final ThemeMode themeMode;
  final AppLanguage language;

  /// Dim tiles that are visible but blocked.
  final bool dimBlockedTiles;
  final bool reduceMotion;

  /// Whether the How to play guide has been shown once.
  final bool seenTutorial;

  const GameSettings({
    this.music = true,
    this.sound = true,
    this.haptics = true,
    this.themeMode = ThemeMode.light,
    this.language = AppLanguage.english,
    this.dimBlockedTiles = false,
    this.reduceMotion = false,
    this.seenTutorial = false,
  });

  GameSettings copyWith({
    bool? music,
    bool? sound,
    bool? haptics,
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? dimBlockedTiles,
    bool? reduceMotion,
    bool? seenTutorial,
  }) =>
      GameSettings(
        music: music ?? this.music,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        dimBlockedTiles: dimBlockedTiles ?? this.dimBlockedTiles,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        seenTutorial: seenTutorial ?? this.seenTutorial,
      );
}

/// Simple key/value settings live in SharedPreferences.
class SettingsNotifier extends Notifier<GameSettings> {
  static const _music = 'settings.music';
  static const _sound = 'settings.sound';
  static const _haptics = 'settings.haptics';
  static const _theme = 'settings.themeMode';
  static const _language = 'settings.language';
  static const _dim = 'settings.dimBlocked';
  static const _motion = 'settings.reduceMotion';
  static const _tutorial = 'settings.seenTutorial';

  @override
  GameSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    return GameSettings(
      music: p.getBool(_music) ?? true,
      sound: p.getBool(_sound) ?? true,
      haptics: p.getBool(_haptics) ?? true,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == p.getString(_theme),
        orElse: () => ThemeMode.light,
      ),
      language: AppLanguage.fromCode(p.getString(_language)),
      dimBlockedTiles: p.getBool(_dim) ?? false,
      reduceMotion: p.getBool(_motion) ?? false,
      seenTutorial: p.getBool(_tutorial) ?? false,
    );
  }

  void update(GameSettings s) {
    final p = ref.read(sharedPreferencesProvider);
    p.setBool(_music, s.music);
    p.setBool(_sound, s.sound);
    p.setBool(_haptics, s.haptics);
    p.setString(_theme, s.themeMode.name);
    p.setString(_language, s.language.code);
    p.setBool(_dim, s.dimBlockedTiles);
    p.setBool(_motion, s.reduceMotion);
    p.setBool(_tutorial, s.seenTutorial);
    state = s;
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);
