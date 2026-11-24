import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tile_game/core/audio/game_audio.dart';
import 'package:tile_game/core/storage.dart';
import 'package:tile_game/features/levels/data/level_repository.dart';
import 'package:tile_game/l10n/app_localizations.dart';
import 'package:tile_game/main.dart';

void main() {
  // Every screen size in light/English, plus dark mode with the languages
  // whose text runs longest.
  final cases = <(Size, String, String)>[
    for (final size in const [
      Size(320, 568), // iPhone SE (1st gen)
      Size(375, 667), // iPhone 8 / SE
      Size(402, 874), // iPhone 17 Pro
      Size(440, 956), // Pro Max
      Size(820, 1180), // iPad Air portrait
      Size(1180, 820), // iPad Air landscape
    ])
      (size, 'light', 'en'),
    for (final lang in const ['hi', 'de', 'fr', 'es', 'pt'])
      (const Size(375, 667), 'dark', lang),
  ];

  for (final (size, theme, lang) in cases) {
    testWidgets('home screen lays out at $size ($theme, $lang)', (tester) async {
      SharedPreferences.setMockInitialValues({
        'settings.themeMode': theme,
        'settings.language': lang,
      });
      final sp = await SharedPreferences.getInstance();
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          gameAudioProvider.overrideWithValue(const SilentAudio()),
          levelRepositoryProvider.overrideWithValue(LevelRepository(inline: true)),
        ],
        child: const TileGroveApp(),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      final l = lookupAppLocalizations(Locale(lang));
      expect(find.text(l.playLevel(1)), findsOneWidget);
      // The whole control block stays on screen.
      final info = find.text(l.homeInfo);
      expect(tester.getBottomLeft(info).dy, lessThanOrEqualTo(size.height));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
