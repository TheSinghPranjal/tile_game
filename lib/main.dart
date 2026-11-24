import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/audio/game_audio.dart';
import 'core/l10n/l10n.dart';
import 'core/storage.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/help/presentation/how_to_play_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/settings/domain/game_settings.dart';
import 'features/settings/presentation/settings_screen.dart';

/// Debug aid: `--dart-define=START_LEVEL=42` opens that level directly.
const _startLevel = int.fromEnvironment('START_LEVEL');

/// Debug aid: `--dart-define=START_SCREEN=settings` (or `howto`).
const _startScreen = String.fromEnvironment('START_SCREEN');

/// Debug aids for screenshots: `--dart-define=THEME=dark`, `LANG=hi`.
const _debugTheme = String.fromEnvironment('THEME');
const _debugLang = String.fromEnvironment('LANG');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  if (kDebugMode) {
    if (_debugTheme.isNotEmpty) {
      await prefs.setString('settings.themeMode', _debugTheme);
    }
    if (_debugLang.isNotEmpty) {
      await prefs.setString('settings.language', _debugLang);
    }
    if (_startScreen.isNotEmpty || _startLevel > 0) {
      await prefs.setBool('settings.seenTutorial', true);
    }
  }
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TileGroveApp(),
    ),
  );
}

class TileGroveApp extends ConsumerStatefulWidget {
  const TileGroveApp({super.key});

  @override
  ConsumerState<TileGroveApp> createState() => _TileGroveAppState();
}

class _TileGroveAppState extends ConsumerState<TileGroveApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Music stops while the app is in the background.
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(gameAudioProvider).onAppPaused(),
      onShow: () => ref.read(gameAudioProvider).onAppResumed(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    // Creating the audio service starts the background music.
    ref.watch(gameAudioProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      // English unless the player picks another language in Settings.
      locale: settings.language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
          child: child!,
        );
      },
      home: !kDebugMode
          ? const HomeScreen()
          : _startLevel > 0
          ? GameScreen(level: _startLevel)
          : switch (_startScreen) {
              'settings' => const SettingsScreen(),
              'howto' => const HowToPlayScreen(),
              _ => const HomeScreen(),
            },
    );
  }
}
