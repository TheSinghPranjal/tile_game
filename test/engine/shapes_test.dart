import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tile_game/core/constants/game_constants.dart';
import 'package:tile_game/core/storage.dart';
import 'package:tile_game/features/achievements/domain/achievements.dart';
import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/levels/domain/layout_templates.dart';
import 'package:tile_game/features/levels/domain/level_config.dart';
import 'package:tile_game/features/levels/domain/shape_library.dart';
import 'package:tile_game/features/progress/data/progress_repository.dart';

void main() {
  test('every picture fits a phone and has at least two layers of room', () {
    for (final art in ShapeLibrary.all) {
      expect(art.width, lessThanOrEqualTo(9), reason: art.name);
      expect(art.height, lessThanOrEqualTo(11), reason: art.name);
      expect(art.cellCount, greaterThanOrEqualTo(16), reason: art.name);
    }
  });

  test('picture levels are common and use the picture as the board', () {
    var pictures = 0;
    for (var l = 1; l <= 120; l++) {
      final c = LevelConfig.forLevel(l);
      if (c.template != LayoutTemplate.shape) continue;
      pictures++;
      final level = const LevelGenerator().generate(c);
      expect(level.templateName, c.params.art!.title);
      // The bottom layer is exactly the picture.
      final bottom = level.geometry.tiles.where((t) => t.layer == 0).length;
      expect(bottom, inInclusiveRange(c.params.art!.cellCount - 1,
          c.params.art!.cellCount));
      expect(level.geometry.layerCount, greaterThanOrEqualTo(2));
    }
    expect(pictures, greaterThan(60));
  });

  test('clearing the final level does not unlock a level beyond the campaign',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    final n = c.read(progressProvider.notifier);
    const last = GameConstants.totalLevels;
    n.completeLevel(
      level: last,
      assistsUsed: 0,
      matches: 10,
      elapsed: const Duration(seconds: 30),
      facts: const CompletionFacts(2, Duration(seconds: 30), false),
    );
    final p = c.read(progressProvider);
    expect(p.highestUnlocked, last);
    expect(p.allLevelsCleared, isTrue);
  });
}
