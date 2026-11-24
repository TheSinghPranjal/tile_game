import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tile_game/core/audio/game_audio.dart';
import 'package:tile_game/core/storage.dart';
import 'package:tile_game/features/game/presentation/controllers/game_controller.dart';
import 'package:tile_game/features/game/presentation/screens/game_screen.dart';
import 'package:tile_game/features/help/presentation/how_to_play_screen.dart';
import 'package:tile_game/features/levels/data/level_repository.dart';
import 'package:tile_game/features/settings/domain/game_settings.dart';
import 'package:tile_game/main.dart';

/// Records what the game asked the audio layer to do.
class _FakeAudio implements GameAudio {
  final played = <Sfx>[];
  GameSettings? last;
  @override
  void play(Sfx sfx) => played.add(sfx);
  @override
  void apply(GameSettings settings) => last = settings;
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
  @override
  void dispose() {}
}

Future<(ProviderContainer, SharedPreferences)> _launch(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  GameAudio audio = const SilentAudio(),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(400, 860));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      gameAudioProvider.overrideWithValue(audio),
      levelRepositoryProvider.overrideWithValue(LevelRepository(inline: true)),
      backgroundRunnerProvider.overrideWithValue(
          <Q, R>(ComputeCallback<Q, R> cb, Q msg) async => cb(msg)),
    ],
    child: const TileGroveApp(),
  ));
  await tester.pump();
  return (
    ProviderScope.containerOf(tester.element(find.byType(TileGroveApp))),
    sp,
  );
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('English is the default even when the device language differs',
      (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('hi');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await _launch(tester);
    expect(find.text('Play Level 1'), findsOneWidget);
  });

  testWidgets('music, sound and vibration toggles persist', (tester) async {
    final (c, sp) = await _launch(tester);
    await _openSettings(tester);

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sound effects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vibration'));
    await tester.pumpAndSettle();

    final s = c.read(settingsProvider);
    expect((s.music, s.sound, s.haptics), (false, false, false));
    expect(sp.getBool('settings.music'), isFalse);
    expect(sp.getBool('settings.sound'), isFalse);
    expect(sp.getBool('settings.haptics'), isFalse);
  });

  testWidgets('dark mode switches the whole app theme', (tester) async {
    final (c, sp) = await _launch(tester);
    await _openSettings(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(c.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(sp.getString('settings.themeMode'), 'dark');
    final ctx = tester.element(find.text('Settings').first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('choosing Hindi translates the app and is remembered',
      (tester) async {
    final (_, sp) = await _launch(tester);
    await _openSettings(tester);
    await tester.ensureVisible(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();

    expect(find.text('सेटिंग्स'), findsWidgets); // "Settings" in Hindi
    expect(sp.getString('settings.language'), 'hi');

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('लेवल 1 खेलें'), findsOneWidget); // "Play Level 1"
  });

  testWidgets('first play shows How to play, then starts the level',
      (tester) async {
    final (c, _) = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await tester.pumpAndSettle();
    expect(find.byType(HowToPlayScreen), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text("Let's play!"));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(GameScreen), findsOneWidget);
    expect(c.read(settingsProvider).seenTutorial, isTrue);
    expect(c.read(gameControllerProvider).board, isNotNull);
  });

  testWidgets('sound effects follow the setting', (tester) async {
    final audio = _FakeAudio();
    await _launch(tester,
        prefs: {'settings.seenTutorial': true}, audio: audio);
    await tester.tap(find.text('Play Level 1'));
    expect(audio.played, contains(Sfx.button));
  });
}
