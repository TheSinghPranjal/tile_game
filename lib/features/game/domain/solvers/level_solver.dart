import '../../../../core/utils/bitset.dart';
import '../../../../core/utils/seeded_random.dart';
import '../entities/board_geometry.dart';
import '../entities/board_state.dart';

enum SolveStatus {
  /// A complete clearing sequence was found.
  solved,

  /// The search space was exhausted: no clearing sequence exists.
  unsolvable,

  /// The node budget ran out before a verdict was reached.
  unknown,
}

class SolveResult {
  final SolveStatus status;

  /// The clearing sequence (only when [status] is [SolveStatus.solved]).
  final List<TilePair> solution;

  /// Search nodes expanded – a measure of solver effort / level complexity.
  final int nodes;

  const SolveResult(this.status, this.solution, this.nodes);

  bool get isSolved => status == SolveStatus.solved;
}

/// Independent depth-first search solver with memoised failed states.
///
/// The solver knows nothing about how a level was generated: it only sees
/// geometry + symbols + removal state and applies the real availability rules.
///
/// Pruning rule ("safe moves"): availability is monotone – removing tiles can
/// only ever free other tiles. Therefore, when EVERY remaining copy of a
/// symbol is currently selectable, removing those copies cannot hurt any
/// solution, so they are removed without branching.
class LevelSolver {
  /// Total node budget across all restarts.
  final int nodeBudget;

  /// Budget of the first run; each restart doubles it. Search time for
  /// this kind of puzzle is heavy-tailed, so several short randomised runs
  /// are far more reliable than one long run with a fixed move ordering.
  final int initialRunBudget;

  const LevelSolver({this.nodeBudget = 250000, this.initialRunBudget = 3000});

  SolveResult solve(BoardState state) {
    final failed = <BitSet>{};
    var spent = 0;
    var runBudget = initialRunBudget;
    var run = 0;
    while (true) {
      final budget = (nodeBudget - spent).clamp(0, runBudget);
      final r = _SolverRun(
        state.geometry,
        state.symbols,
        budget,
        failed,
        perturbSeed: run == 0 ? null : run * 7919,
      );
      for (var i = 0; i < state.length; i++) {
        if (state.removed[i]) r.removed[i] = true;
      }
      final result = r.execute();
      spent += result.nodes;
      if (result.status != SolveStatus.unknown) {
        return SolveResult(result.status, result.solution, spent);
      }
      if (spent >= nodeBudget) {
        return SolveResult(SolveStatus.unknown, const [], spent);
      }
      runBudget *= 2;
      run++;
    }
  }

  bool isSolvable(BoardState state) => solve(state).isSolved;
}

class _SolverRun {
  final BoardGeometry g;
  final List<int> symbols;
  final int budget;
  final List<bool> removed;
  /// Failed states shared across restarts. Only states whose subtree was
  /// explored exhaustively are recorded, so sharing is sound.
  final Set<BitSet> failed;
  final List<TilePair> path = [];
  final SeededRandom? _noise;
  int nodes = 0;
  bool aborted = false;
  late final int symbolCount;

  _SolverRun(this.g, this.symbols, this.budget, this.failed, {int? perturbSeed})
      : removed = List<bool>.filled(g.length, false),
        _noise = perturbSeed == null ? null : SeededRandom(perturbSeed) {
    var maxSym = 0;
    for (final s in symbols) {
      if (s > maxSym) maxSym = s;
    }
    symbolCount = maxSym + 1;
  }

  SolveResult execute() {
    // Parity check: an odd number of any symbol can never be cleared.
    final counts = List<int>.filled(symbolCount, 0);
    for (var i = 0; i < g.length; i++) {
      if (!removed[i]) counts[symbols[i]]++;
    }
    if (counts.any((c) => c.isOdd)) {
      return const SolveResult(SolveStatus.unsolvable, [], 0);
    }
    final ok = _dfs();
    if (ok) return SolveResult(SolveStatus.solved, List.of(path), nodes);
    return SolveResult(
      aborted ? SolveStatus.unknown : SolveStatus.unsolvable,
      const [],
      nodes,
    );
  }

  bool _isFree(int i) {
    if (removed[i]) return false;
    for (final c in g.coveredBy[i]) {
      if (!removed[c]) return false;
    }
    var leftOpen = true;
    for (final b in g.leftBlockers[i]) {
      if (!removed[b]) {
        leftOpen = false;
        break;
      }
    }
    if (leftOpen) return true;
    for (final b in g.rightBlockers[i]) {
      if (!removed[b]) return false;
    }
    return true;
  }

  BitSet _key() => BitSet.fromIndices(
        g.length,
        [for (var i = 0; i < g.length; i++) if (removed[i]) i],
      );

  void _remove(TilePair p) {
    removed[p.a] = true;
    removed[p.b] = true;
    path.add(p);
  }

  void _restore(TilePair p) {
    removed[p.a] = false;
    removed[p.b] = false;
    path.removeLast();
  }

  bool _dfs() {
    // 1. Apply safe moves without branching.
    final applied = <TilePair>[];
    List<int> free;
    var remaining = 0;
    while (true) {
      free = [];
      final remainingPerSymbol = List<int>.filled(symbolCount, 0);
      final freePerSymbol = List<List<int>>.generate(symbolCount, (_) => []);
      remaining = 0;
      for (var i = 0; i < g.length; i++) {
        if (removed[i]) continue;
        remaining++;
        remainingPerSymbol[symbols[i]]++;
        if (_isFree(i)) {
          free.add(i);
          freePerSymbol[symbols[i]].add(i);
        }
      }
      var progressed = false;
      for (var s = 0; s < symbolCount; s++) {
        final f = freePerSymbol[s];
        if (f.length >= 2 && f.length == remainingPerSymbol[s]) {
          for (var k = 0; k + 1 < f.length; k += 2) {
            final p = TilePair(f[k], f[k + 1]);
            _remove(p);
            applied.add(p);
          }
          progressed = true;
        }
      }
      if (!progressed) break;
    }

    void undoApplied() {
      for (var k = applied.length - 1; k >= 0; k--) {
        _restore(applied[k]);
      }
    }

    if (remaining == 0) return true;

    final key = _key();
    if (failed.contains(key)) {
      undoApplied();
      return false;
    }
    if (++nodes > budget) {
      aborted = true;
      undoApplied();
      return false;
    }

    // 2. Enumerate matching selectable pairs.
    final bySymbol = <int, List<int>>{};
    for (final i in free) {
      (bySymbol[symbols[i]] ??= []).add(i);
    }
    final pairs = <TilePair>[];
    for (final group in bySymbol.values) {
      for (var x = 0; x < group.length; x++) {
        for (var y = x + 1; y < group.length; y++) {
          pairs.add(TilePair(group[x], group[y]));
        }
      }
    }
    if (pairs.isEmpty) {
      failed.add(key);
      undoApplied();
      return false;
    }

    // 3. Strategic ordering: unlock the most structure first.
    int score(TilePair p) {
      var s = 0;
      for (final t in p.both) {
        for (final d in g.dependents[t]) {
          if (!removed[d]) s += g.coveredBy[d].contains(t) ? 3 : 1;
        }
        s += g.tiles[t].layer;
      }
      final noise = _noise;
      return noise == null ? s : s + noise.nextInt(6);
    }

    final scored = [for (final p in pairs) (p, score(p))]
      ..sort((x, y) => y.$2.compareTo(x.$2));

    for (final (p, _) in scored) {
      _remove(p);
      if (_dfs()) return true;
      _restore(p);
      if (aborted) break;
    }

    if (!aborted) failed.add(key);
    undoApplied();
    return false;
  }
}
