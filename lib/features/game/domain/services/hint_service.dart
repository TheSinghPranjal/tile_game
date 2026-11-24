import '../entities/board_state.dart';
import '../solvers/level_solver.dart';
import 'game_engine.dart';

enum HintStatus {
  /// [HintResult.pair] is legal and keeps the board solvable.
  safe,

  /// [HintResult.pair] is legal; solvability after it could not be proven
  /// within budget (very large boards only).
  legal,

  /// Legal pairs exist, but none of them keeps the board clearable – the
  /// player should undo or shuffle.
  deadEnd,

  /// No legal matching pair exists.
  noMoves,
}

class HintResult {
  final HintStatus status;
  final TilePair? pair;
  const HintResult(this.status, [this.pair]);
}

/// Solver-backed hints. Only ever proposes two currently selectable tiles
/// with identical symbols.
class HintService {
  final LevelSolver solver;
  final int maxCandidates;

  const HintService({
    this.solver = const LevelSolver(nodeBudget: 20000, initialRunBudget: 2000),
    this.maxCandidates = 10,
  });

  HintResult findHint(BoardState state) {
    final pairs = GameEngine.matchingPairs(state);
    if (pairs.isEmpty) return const HintResult(HintStatus.noMoves);

    // Strategic ordering: prefer pairs that expose hidden tiles and unblock
    // the most structure.
    final ranked = [
      for (final p in pairs)
        (p, GameEngine.exposureGain(state, p) * 4 + GameEngine.coverWeight(state, p)),
    ]..sort((x, y) => y.$2.compareTo(x.$2));

    TilePair? unknown;
    for (final (p, _) in ranked.take(maxCandidates)) {
      final r = solver.solve(state.withRemoved(p.both));
      if (r.isSolved) return HintResult(HintStatus.safe, p);
      if (r.status == SolveStatus.unknown) unknown ??= p;
    }
    if (unknown != null) return HintResult(HintStatus.legal, unknown);
    if (ranked.length > maxCandidates) {
      // Not every pair was checked; still report a legal one.
      return HintResult(HintStatus.legal, ranked.first.$1);
    }
    return HintResult(HintStatus.deadEnd, ranked.first.$1);
  }

  /// For the Magic Match booster: the best selectable partner for [tile].
  int? partnerFor(BoardState state, int tile) {
    if (!state.isSelectable(tile)) return null;
    final candidates = [
      for (final i in state.selectableTiles)
        if (i != tile && state.symbols[i] == state.symbols[tile]) i,
    ];
    if (candidates.isEmpty) return null;
    for (final c in candidates) {
      if (solver.solve(state.withRemoved([tile, c])).isSolved) return c;
    }
    return candidates.first;
  }
}
