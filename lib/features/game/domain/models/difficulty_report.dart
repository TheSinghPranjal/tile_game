import 'dart:math' as math;

import '../../../../core/utils/seeded_random.dart';
import '../entities/board_state.dart';
import '../services/game_engine.dart';

/// Measured difficulty features of a level.
class DifficultyReport {
  final int totalTiles;
  final int layers;
  final int initialSelectable;
  final int initialMatchingPairs;
  final int dependencyDepth;

  /// Steps along the certificate where exactly one matching pair existed.
  final int forcedMoves;

  /// Mean number of legal matching pairs along the certificate.
  final double avgAlternatives;

  /// Fraction of random-play playouts that cleared the board. Low values
  /// mean many choices lead into dead ends.
  final double playoutSuccessRate;

  final int solverNodes;

  /// 0 (trivial) – 100 (very hard).
  final double score;

  const DifficultyReport({
    required this.totalTiles,
    required this.layers,
    required this.initialSelectable,
    required this.initialMatchingPairs,
    required this.dependencyDepth,
    required this.forcedMoves,
    required this.avgAlternatives,
    required this.playoutSuccessRate,
    required this.solverNodes,
    required this.score,
  });

  String get label {
    if (score < 25) return 'Easy';
    if (score < 45) return 'Medium';
    if (score < 65) return 'Hard';
    return 'Expert';
  }

  Map<String, dynamic> toJson() => {
        'tiles': totalTiles,
        'layers': layers,
        'initialSelectable': initialSelectable,
        'initialPairs': initialMatchingPairs,
        'depth': dependencyDepth,
        'forced': forcedMoves,
        'avgAlt': avgAlternatives,
        'playoutSuccess': playoutSuccessRate,
        'solverNodes': solverNodes,
        'score': score,
      };

  factory DifficultyReport.fromJson(Map<String, dynamic> j) => DifficultyReport(
        totalTiles: j['tiles'] as int,
        layers: j['layers'] as int,
        initialSelectable: j['initialSelectable'] as int,
        initialMatchingPairs: j['initialPairs'] as int,
        dependencyDepth: j['depth'] as int,
        forcedMoves: j['forced'] as int,
        avgAlternatives: (j['avgAlt'] as num).toDouble(),
        playoutSuccessRate: (j['playoutSuccess'] as num).toDouble(),
        solverNodes: j['solverNodes'] as int,
        score: (j['score'] as num).toDouble(),
      );
}

/// Computes a [DifficultyReport] from a solved level.
class DifficultyAnalyzer {
  const DifficultyAnalyzer._();

  static DifficultyReport analyze(
    BoardState initial,
    List<TilePair> certificate, {
    required int solverNodes,
    required SeededRandom rng,
    int playouts = 24,
  }) {
    final g = initial.geometry;
    final initialFree = initial.selectableTiles;
    final initialPairs = GameEngine.matchingPairsAmong(initial, initialFree);

    // Walk the certificate measuring choice density.
    var forced = 0;
    var altSum = 0;
    var state = initial;
    for (final p in certificate) {
      final n = GameEngine.matchingPairs(state).length;
      altSum += n;
      if (n == 1) forced++;
      state = state.withRemoved(p.both);
    }
    final avgAlt = certificate.isEmpty ? 0.0 : altSum / certificate.length;

    final success = playoutSuccessRate(initial, rng, playouts);
    final depth = g.dependencyDepth;

    final score = _score(
      tiles: g.length,
      layers: g.layerCount,
      depth: depth,
      initialPairs: initialPairs.length,
      forcedRatio: certificate.isEmpty ? 0 : forced / certificate.length,
      success: success,
      nodes: solverNodes,
    );

    return DifficultyReport(
      totalTiles: g.length,
      layers: g.layerCount,
      initialSelectable: initialFree.length,
      initialMatchingPairs: initialPairs.length,
      dependencyDepth: depth,
      forcedMoves: forced,
      avgAlternatives: avgAlt,
      playoutSuccessRate: success,
      solverNodes: solverNodes,
      score: score,
    );
  }

  /// Plays [count] games choosing uniformly random legal matching pairs and
  /// returns the fraction that cleared the board.
  static double playoutSuccessRate(
    BoardState initial,
    SeededRandom rng,
    int count,
  ) {
    if (count <= 0) return 1;
    var wins = 0;
    for (var k = 0; k < count; k++) {
      var s = initial;
      while (!s.isCleared) {
        final pairs = GameEngine.matchingPairs(s);
        if (pairs.isEmpty) break;
        final p = rng.pick(pairs);
        s = s.withRemoved(p.both);
      }
      if (s.isCleared) wins++;
    }
    return wins / count;
  }

  static double _score({
    required int tiles,
    required int layers,
    required int depth,
    required int initialPairs,
    required double forcedRatio,
    required double success,
    required int nodes,
  }) {
    final tilesTerm = math.min(tiles / 144, 1) * 25;
    final layersTerm = math.min(layers / 6, 1) * 15;
    final depthTerm = math.min(depth / 7, 1) * 15;
    final pairsTerm = (1 - math.min(initialPairs, 12) / 12) * 10;
    final forcedTerm = forcedRatio * 10;
    final riskTerm = (1 - success) * 20;
    final searchTerm =
        math.min(math.log(nodes + 1) / math.ln10 / 4, 1).toDouble() * 5;
    return double.parse((tilesTerm +
            layersTerm +
            depthTerm +
            pairsTerm +
            forcedTerm +
            riskTerm +
            searchTerm)
        .toStringAsFixed(1));
  }
}
