import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tile_game/core/constants/game_constants.dart';
import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/game/domain/solvers/level_solver.dart';
import 'package:tile_game/features/game/domain/validators/level_validator.dart';
import 'package:tile_game/features/levels/domain/layout_templates.dart';
import 'package:tile_game/features/levels/domain/level_config.dart';
import 'package:tile_game/features/levels/domain/shape_library.dart';

/// Levels 1001-2000. Set SEASON_TWO_STEP=1 to generate every level.
void main() {
  final step =
      int.tryParse(Platform.environment['SEASON_TWO_STEP'] ?? '') ?? 37;

  test('the campaign has 2000 levels', () {
    expect(GameConstants.totalLevels, 2000);
    expect(LevelConfig.seasonOneLevels, 1000);
  });

  test('season two has new pictures in every size class', () {
    for (final size in ShapeSize.values) {
      expect(ShapeLibrary.ofSize(size, seasonTwoOnly: true), isNotEmpty,
          reason: size.name);
    }
    final names = {for (final a in ShapeLibrary.all) a.title};
    expect(names.length, ShapeLibrary.all.length, reason: 'unique titles');
  });

  test('season two rotates board sizes and mixes pictures with layouts', () {
    final sizes = <ShapeSize>{};
    var pictures = 0, layouts = 0, newPictures = 0;
    for (var l = 1001; l <= 1100; l++) {
      final c = LevelConfig.forLevel(l);
      if (c.template == LayoutTemplate.shape) {
        pictures++;
        sizes.add(ShapeLibrary.sizeOf(c.params.art!));
        if (ShapeLibrary.seasonTwo.contains(c.params.art)) newPictures++;
      } else {
        layouts++;
      }
    }
    expect(sizes, ShapeSize.values.toSet());
    expect(pictures, greaterThan(60));
    expect(layouts, greaterThan(15));
    expect(newPictures, greaterThan(pictures ~/ 2));
  });

  test('sampled season-two levels generate, verify and replay', () {
    const generator = LevelGenerator();
    const verifier = LevelSolver(nodeBudget: 1000000);
    for (var l = 1001; l <= GameConstants.totalLevels; l += step) {
      final level = generator.generateLevel(l);
      expect(level.geometry.length.isEven, isTrue, reason: 'level $l');
      expect(level.geometry.length, greaterThanOrEqualTo(12),
          reason: 'level $l');
      expect(verifier.solve(level.initialState).isSolved, isTrue,
          reason: 'level $l');
      expect(
        LevelValidator.validate(
          level.geometry,
          level.symbols,
          level.certificate.solution,
        ).isValid,
        isTrue,
        reason: 'level $l',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 30)));
}
