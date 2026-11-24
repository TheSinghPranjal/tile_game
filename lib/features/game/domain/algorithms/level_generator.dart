import 'dart:math' as math;

import '../../../../core/utils/seeded_random.dart';
import '../../../levels/domain/layout_templates.dart';
import '../../../levels/domain/level_config.dart';
import '../entities/board_geometry.dart';
import '../entities/board_state.dart';
import '../entities/tile_position.dart';
import '../entities/tile_symbol.dart';
import '../models/difficulty_report.dart';
import '../models/level_certificate.dart';
import '../solvers/level_solver.dart';
import '../validators/geometry_validator.dart';
import '../validators/level_validator.dart';
import 'removal_sequence_generator.dart';
import 'symbol_assigner.dart';

class LevelGenerationException implements Exception {
  final String message;
  LevelGenerationException(this.message);
  @override
  String toString() => 'LevelGenerationException: $message';
}

/// Builds guaranteed-solvable levels:
///
/// 1. geometry from a template            4. symbols assigned per pair
/// 2. geometry validation                 5. independent solver verification
/// 3. legal removal sequence (positions)  6. certificate replay + difficulty
class LevelGenerator {
  /// Bump whenever generation output changes, so saved games are invalidated.
  static const int version = 4;

  final LevelSolver solver;
  final RemovalSequenceGenerator sequencer;
  final int maxAttempts;
  final int playouts;

  const LevelGenerator({
    this.solver = const LevelSolver(nodeBudget: 200000),
    this.sequencer = const RemovalSequenceGenerator(),
    this.maxAttempts = 10,
    this.playouts = 24,
  });

  GeneratedLevel generateLevel(int levelNumber) =>
      generate(LevelConfig.forLevel(levelNumber));

  GeneratedLevel generate(LevelConfig config, {int salt = 0}) {
    GeneratedLevel? best;
    var params = config.params;
    var sequenceFailures = 0;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final seed = SeededRandom.seedFrom(
          [config.levelNumber, attempt, version, salt, config.template.index]);
      final rng = SeededRandom(seed);

      // STEP 1: geometry.
      final tiles = buildTiles(config, params, rng);
      if (tiles == null) {
        params = _shrink(params);
        continue;
      }
      final geometry = BoardGeometry(tiles);

      // STEP 2: geometry validation.
      if (GeometryValidator.validate(geometry).isNotEmpty) {
        params = _shrink(params);
        continue;
      }

      // STEP 3: legal removal sequence over positions.
      final sequence = sequencer.generate(
        geometry,
        rng,
        preference: config.preference,
      );
      if (sequence == null) {
        if (++sequenceFailures % 2 == 0) params = _shrink(params);
        continue;
      }

      // STEP 4-5: symbols.
      final pool = _symbolPool(config, sequence.length, rng);
      final symbols = SymbolAssigner.assign(
        tileCount: geometry.length,
        sequence: sequence,
        pool: pool,
        rng: rng,
      );

      // STEP 6: independent verification.
      final state = BoardState(geometry: geometry, symbols: symbols);
      final result = solver.solve(state);
      if (!result.isSolved) continue;
      final replay = LevelValidator.validate(geometry, symbols, sequence);
      if (!replay.isValid) {
        throw LevelGenerationException(
            'Certificate replay failed for level ${config.levelNumber}: $replay');
      }

      final difficulty = DifficultyAnalyzer.analyze(
        state,
        sequence,
        solverNodes: result.nodes,
        rng: SeededRandom(seed ^ 0x5A5A5A5A),
        playouts: playouts,
      );

      // STEP 7: certificate.
      final level = GeneratedLevel(
        levelNumber: config.levelNumber,
        geometry: geometry,
        symbols: symbols,
        templateName: config.template.displayName,
        themeIndex: config.theme.index,
        certificate: LevelCertificate(
          levelId: config.levelNumber,
          geometry: geometry.toJson(),
          symbols: symbols,
          solution: sequence,
          difficulty: difficulty,
          layers: geometry.layerCount,
          totalTiles: geometry.length,
          solverStatus: result.status.name,
          solverNodes: result.nodes,
          generatorVersion: version,
          seed: seed,
          attempt: attempt,
          template: config.template.name,
        ),
      );

      if (difficulty.playoutSuccessRate >= config.minPlayoutSuccess &&
          difficulty.initialMatchingPairs >= config.minInitialPairs) {
        return level;
      }
      if (best == null || _quality(level, config) > _quality(best, config)) {
        best = level;
      }
    }

    if (best != null) return best;

    // Last resort: a flat rectangle is always clearable row by row.
    if (config.template != LayoutTemplate.smallRectangle ||
        config.params.layers > 1) {
      return generate(
        LevelConfig(
          levelNumber: config.levelNumber,
          tier: config.tier,
          template: LayoutTemplate.smallRectangle,
          params: const LayoutParams(cols: 6, rows: 4, layers: 1),
          minTiles: 12,
          maxTiles: 36,
          symbolPoolSize: config.symbolPoolSize,
          theme: config.theme,
          preference: PairPreference.random,
          minPlayoutSuccess: 0,
          minInitialPairs: 1,
        ),
        salt: salt + 1,
      );
    }
    throw LevelGenerationException(
        'Could not generate level ${config.levelNumber}');
  }

  /// Builds template tiles that respect the config's tile-count window and
  /// have an even count. Returns null if the template cannot fit.
  static List<TilePosition>? buildTiles(
    LevelConfig config,
    LayoutParams params,
    SeededRandom rng,
  ) {
    var p = LayoutParams(
      cols: params.cols,
      rows: params.rows,
      layers: params.layers,
      staggerRows: params.staggerRows,
      stackMode: params.stackMode,
      tileWidth: params.tileWidth,
      tileHeight: params.tileHeight,
      overlap: params.overlap,
      maxTiles: config.maxTiles,
    );
    List<TilePosition> tiles = const [];
    // Adjust the footprint (not the layer count) to land inside the
    // [minTiles, maxTiles] window, so the configured depth is preserved.
    final full = LayoutParams(
      cols: p.cols,
      rows: p.rows,
      layers: p.layers,
      staggerRows: p.staggerRows,
      stackMode: p.stackMode,
      tileWidth: p.tileWidth,
      tileHeight: p.tileHeight,
      overlap: p.overlap,
      maxTiles: 1 << 20,
    );
    p = full;
    for (var i = 0; i < 12; i++) {
      tiles = config.template.build(p, rng);
      if (tiles.length > config.maxTiles && (p.cols > 3 || p.rows > 3)) {
        p = p.cols >= p.rows && p.cols > 3
            ? p.copyWith(cols: p.cols - 1)
            : p.copyWith(rows: p.rows - 1);
        continue;
      }
      if (tiles.length < config.minTiles && p.cols < 10 && p.rows < 11) {
        p = i.isEven ? p.copyWith(cols: p.cols + 1) : p.copyWith(rows: p.rows + 1);
        continue;
      }
      break;
    }
    if (tiles.length > config.maxTiles) {
      // Final safety net: let the template trim its top layers.
      tiles = config.template.build(
        LayoutParams(
          cols: p.cols,
          rows: p.rows,
          layers: p.layers,
          staggerRows: p.staggerRows,
          stackMode: p.stackMode,
          tileWidth: p.tileWidth,
          tileHeight: p.tileHeight,
          overlap: p.overlap,
          maxTiles: config.maxTiles,
        ),
        rng,
      );
    }
    if (tiles.length < 4) return null;
    if (tiles.length.isOdd) tiles = _dropOne(tiles);
    return tiles;
  }

  /// Removes the uncovered top-layer tile nearest the board centre.
  static List<TilePosition> _dropOne(List<TilePosition> tiles) {
    final topLayer = tiles.map((t) => t.layer).reduce(math.max);
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final t in tiles) {
      minX = math.min(minX, t.x);
      maxX = math.max(maxX, t.x);
      minY = math.min(minY, t.y);
      maxY = math.max(maxY, t.y);
    }
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    TilePosition? victim;
    var bestD = double.infinity;
    for (final t in tiles.where((t) => t.layer == topLayer)) {
      final d = (t.x - cx).abs() + (t.y - cy).abs();
      if (d < bestD) {
        bestD = d;
        victim = t;
      }
    }
    final out = [
      for (final t in tiles)
        if (!identical(t, victim)) t,
    ];
    return [for (var i = 0; i < out.length; i++) out[i].copyWith(id: i)];
  }

  /// Ranks fallback candidates when no attempt met every acceptance rule.
  static double _quality(GeneratedLevel l, LevelConfig c) =>
      l.difficulty.playoutSuccessRate +
      math.min(l.difficulty.initialMatchingPairs, c.minInitialPairs) * 0.1;

  static LayoutParams _shrink(LayoutParams p) => p.copyWith(
        cols: math.max(3, p.cols - (p.cols >= p.rows ? 1 : 0)),
        rows: math.max(3, p.rows - (p.rows > p.cols ? 1 : 0)),
      );

  /// Never more than [maxCopiesPerSymbol] tiles share a symbol.
  static const int maxCopiesPerSymbol = 4;

  static List<int> _symbolPool(LevelConfig config, int pairs, SeededRandom rng) {
    final size = math.max(
      config.symbolPoolSize,
      (pairs * 2 / maxCopiesPerSymbol).ceil(),
    );
    final primary = TileCatalog.ofTheme(config.theme).map((s) => s.id).toList();
    rng.shuffle(primary);
    final rest = TileCatalog.pool(config.theme, TileCatalog.all.length)
        .where((id) => !primary.contains(id))
        .toList();
    rng.shuffle(rest);
    return [...primary, ...rest].take(size).toList();
  }
}
