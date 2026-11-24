import 'dart:math' as math;

import '../../../core/utils/seeded_random.dart';
import '../../game/domain/algorithms/removal_sequence_generator.dart';
import '../../game/domain/entities/tile_symbol.dart';
import 'layout_templates.dart';

enum DifficultyTier {
  beginner(1, 'Beginner'),
  apprentice(11, 'Apprentice'),
  adept(26, 'Adept'),
  expert(51, 'Expert'),
  master(101, 'Master'),
  legend(201, 'Legend');

  final int firstLevel;
  final String displayName;
  const DifficultyTier(this.firstLevel, this.displayName);

  static DifficultyTier forLevel(int level) {
    var t = DifficultyTier.beginner;
    for (final v in values) {
      if (level >= v.firstLevel) t = v;
    }
    return t;
  }
}

/// Everything the generator needs to build one level deterministically.
class LevelConfig {
  final int levelNumber;
  final DifficultyTier tier;
  final LayoutTemplate template;
  final LayoutParams params;
  final int minTiles;
  final int maxTiles;

  /// Number of distinct symbols available. When `symbolPoolSize >= pairs`
  /// every symbol appears exactly twice, which makes dead ends impossible.
  final int symbolPoolSize;
  final TileTheme theme;
  final PairPreference preference;

  /// Minimum fraction of random playouts that must clear the board for the
  /// level to be accepted (controls how forgiving the level is).
  final double minPlayoutSuccess;

  /// Minimum number of matching pairs visible at the start.
  final int minInitialPairs;

  const LevelConfig({
    required this.levelNumber,
    required this.tier,
    required this.template,
    required this.params,
    required this.minTiles,
    required this.maxTiles,
    required this.symbolPoolSize,
    required this.theme,
    required this.preference,
    required this.minPlayoutSuccess,
    this.minInitialPairs = 1,
  });

  LevelConfig copyWith({LayoutTemplate? template, int? levelNumber}) =>
      LevelConfig(
        levelNumber: levelNumber ?? this.levelNumber,
        tier: tier,
        template: template ?? this.template,
        params: params,
        minTiles: minTiles,
        maxTiles: maxTiles,
        symbolPoolSize: symbolPoolSize,
        theme: theme,
        preference: preference,
        minPlayoutSuccess: minPlayoutSuccess,
        minInitialPairs: minInitialPairs,
      );

  /// Deterministic progression curve.
  factory LevelConfig.forLevel(int level) {
    assert(level >= 1);
    final rng = SeededRandom(SeededRandom.seedFrom([level, 0xC0FFEE]));
    final tier = DifficultyTier.forLevel(level);
    final theme = TileTheme.values[((level - 1) ~/ 5) % TileTheme.values.length];

    LayoutTemplate pickFrom(List<LayoutTemplate> list) =>
        list[(level + rng.nextInt(list.length)) % list.length];

    int between(int lo, int hi) => lo + rng.nextInt(hi - lo + 1);

    switch (tier) {
      case DifficultyTier.beginner:
        // Levels 1-10: tiny, flat, very forgiving boards.
        // Always two layers so blocked tiles read as physically covered.
        const layers = 2;
        final template = level <= 2
            ? LayoutTemplate.pyramid
            : pickFrom(const [
                LayoutTemplate.smallRectangle,
                LayoutTemplate.pyramid,
                LayoutTemplate.diamond,
                LayoutTemplate.cross,
              ]);
        final cols = math.min(4 + level ~/ 3, 7);
        final rows = math.min(3 + level ~/ 3, 6);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(cols: cols, rows: rows, layers: layers),
          minTiles: 12,
          maxTiles: 36,
          symbolPoolSize: 40,
          theme: theme,
          preference: PairPreference.near,
          minPlayoutSuccess: 1,
          minInitialPairs: 3,
        );
      case DifficultyTier.apprentice:
        // 11-25: two or three layers, basic overlapping.
        final template = pickFrom(const [
          LayoutTemplate.pyramid,
          LayoutTemplate.diamond,
          LayoutTemplate.butterfly,
          LayoutTemplate.circle,
          LayoutTemplate.doublePyramid,
          LayoutTemplate.layeredSquare,
          LayoutTemplate.cross,
        ]);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(
            cols: between(6, 8),
            rows: between(5, 7),
            layers: level < 18 ? 2 : 3,
            staggerRows: rng.nextBool(0.2),
          ),
          minTiles: 24,
          maxTiles: 60,
          symbolPoolSize: 30,
          theme: theme,
          preference: PairPreference.random,
          minPlayoutSuccess: 0.9,
          minInitialPairs: 3,
        );
      case DifficultyTier.adept:
        // 26-50: three or four layers, more decisions.
        final template = pickFrom(const [
          LayoutTemplate.flower,
          LayoutTemplate.zigzag,
          LayoutTemplate.staircase,
          LayoutTemplate.butterfly,
          LayoutTemplate.diamond,
          LayoutTemplate.largeRectangle,
          LayoutTemplate.layeredSquare,
          LayoutTemplate.circle,
        ]);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(
            cols: between(7, 9),
            rows: between(6, 8),
            layers: between(3, 4),
            staggerRows: rng.nextBool(0.25),
          ),
          minTiles: 40,
          maxTiles: 84,
          symbolPoolSize: 24,
          theme: theme,
          preference: PairPreference.random,
          minPlayoutSuccess: 0.6,
          minInitialPairs: 2,
        );
      case DifficultyTier.expert:
        // 51-100: irregular arrangements, deep overlapping.
        final template = pickFrom(const [
          LayoutTemplate.butterfly,
          LayoutTemplate.flower,
          LayoutTemplate.circle,
          LayoutTemplate.zigzag,
          LayoutTemplate.staircase,
          LayoutTemplate.asymmetricTower,
          LayoutTemplate.complex,
          LayoutTemplate.clusters,
          LayoutTemplate.pile,
        ]);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(
            cols: between(8, 9),
            rows: between(7, 9),
            layers: 4,
            staggerRows: rng.nextBool(0.3),
            stackMode: _denseStack(template, rng, 0.3),
          ),
          minTiles: 48,
          maxTiles: 100,
          symbolPoolSize: 20,
          theme: theme,
          preference: rng.nextBool() ? PairPreference.far : PairPreference.random,
          minPlayoutSuccess: 0.4,
          minInitialPairs: 2,
        );
      case DifficultyTier.master:
        // 101-200: multiple sections, four+ layers, more planning.
        final template = pickFrom(const [
          LayoutTemplate.clusters,
          LayoutTemplate.complex,
          LayoutTemplate.doublePyramid,
          LayoutTemplate.largeRectangle,
          LayoutTemplate.layeredSquare,
          LayoutTemplate.asymmetricTower,
          LayoutTemplate.flower,
          LayoutTemplate.pile,
        ]);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(
            cols: between(8, 10),
            rows: between(8, 10),
            layers: between(4, 6),
            staggerRows: rng.nextBool(0.3),
            stackMode: _denseStack(template, rng, 0.5),
          ),
          minTiles: 60,
          maxTiles: 120,
          symbolPoolSize: 18,
          theme: theme,
          preference: PairPreference.far,
          minPlayoutSuccess: 0.25,
          minInitialPairs: 1,
        );
      case DifficultyTier.legend:
        // 201+: procedural layouts with advanced dependency patterns.
        final template = rng.nextBool(0.6)
            ? LayoutTemplate.procedural
            : pickFrom(LayoutTemplate.values);
        return LevelConfig(
          levelNumber: level,
          tier: tier,
          template: template,
          params: LayoutParams(
            cols: between(8, 10),
            rows: between(8, 11),
            layers: between(5, 7),
            staggerRows: rng.nextBool(0.3),
            stackMode: _denseStack(template, rng, 0.6),
            overlap: rng.pick(const [0.5, 0.5, 0.4, 0.6]),
          ),
          minTiles: 64,
          maxTiles: 136,
          symbolPoolSize: between(16, 20),
          theme: theme,
          preference: rng.nextBool() ? PairPreference.far : PairPreference.random,
          minPlayoutSuccess: 0.15,
          minInitialPairs: 1,
        );
    }
  }

  /// Image-5 style dense piles for tougher tiers. Templates whose silhouette
  /// depends on their own stacking rule (stairs, towers) keep it.
  static StackMode? _denseStack(
      LayoutTemplate t, SeededRandom rng, double probability) {
    if (t == LayoutTemplate.pile) return StackMode.quarterOffset;
    if (t == LayoutTemplate.staircase || t == LayoutTemplate.asymmetricTower) {
      return null;
    }
    return rng.nextBool(probability) ? StackMode.quarterOffset : null;
  }
}
