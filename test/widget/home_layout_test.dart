import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tile_game/core/storage.dart';
import 'package:tile_game/features/levels/data/level_repository.dart';
import 'package:tile_game/main.dart';

void main() {
  for (final size in const [
    Size(320, 568), // iPhone SE (1st gen)
    Size(375, 667), // iPhone 8 / SE
    Size(402, 874), // iPhone 17 Pro
    Size(440, 956), // Pro Max
    Size(820, 1180), // iPad Air portrait
    Size(1180, 820), // iPad Air landscape
  ]) {
    testWidgets('home screen lays out without overflow at $size', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          levelRepositoryProvider.overrideWithValue(LevelRepository(inline: true)),
        ],
        child: const TileGroveApp(),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      final play = find.text('Play Level 1');
      expect(play, findsOneWidget);
      // The whole control block stays on screen.
      final info = find.textContaining('Long-press any tile');
      expect(tester.getBottomLeft(info).dy, lessThanOrEqualTo(size.height));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
