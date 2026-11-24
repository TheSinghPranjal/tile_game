import '../../../../core/utils/seeded_random.dart';
import '../algorithms/removal_sequence_generator.dart';
import '../entities/board_state.dart';
import '../solvers/level_solver.dart';

/// Re-deals the symbols of the remaining tiles.
///
/// Geometry, positions, layers and removed tiles are untouched and the exact
/// multiset of remaining symbols is preserved (so every symbol count stays
/// even). The new deal is built from a fresh legal removal sequence over the
/// remaining positions and then independently verified by the solver, so a
/// shuffle can never produce an unsolvable board.
class ShuffleService {
  final LevelSolver solver;
  final RemovalSequenceGenerator sequencer;
  final int attempts;

  const ShuffleService({
    this.solver = const LevelSolver(nodeBudget: 60000),
    this.sequencer = const RemovalSequenceGenerator(nodeBudget: 8000),
    this.attempts = 8,
  });

  /// Returns the shuffled state, or `null` if the remaining geometry cannot
  /// be cleared under any symbol assignment (e.g. two tiles stacked on top of
  /// each other are the only ones left).
  BoardState? shuffle(BoardState state, SeededRandom rng) {
    if (state.isCleared) return state;

    // Remaining symbols as a list of pairs (counts are even by invariant).
    final counts = state.remainingSymbolCounts();
    final symbolPairs = <int>[];
    counts.forEach((symbol, count) {
      assert(count.isEven, 'odd symbol count');
      for (var k = 0; k < count ~/ 2; k++) {
        symbolPairs.add(symbol);
      }
    });

    BoardState? fallback;
    for (var a = 0; a < attempts; a++) {
      final sequence = sequencer.generate(
        state.geometry,
        rng,
        initiallyRemoved: state.removed,
      );
      if (sequence == null) continue;

      final deal = [...symbolPairs];
      rng.shuffle(deal);
      final symbols = [...state.symbols];
      for (var i = 0; i < sequence.length; i++) {
        symbols[sequence[i].a] = deal[i];
        symbols[sequence[i].b] = deal[i];
      }
      final next = state.withSymbols(symbols);
      if (!solver.solve(next).isSolved) continue;

      // Prefer deals that visibly change the board.
      final changed = state.remainingTiles
          .where((i) => state.symbols[i] != symbols[i])
          .length;
      if (changed >= (state.remainingCount / 2).floor() ||
          state.remainingCount <= 4) {
        return next;
      }
      fallback ??= next;
    }
    return fallback;
  }
}
