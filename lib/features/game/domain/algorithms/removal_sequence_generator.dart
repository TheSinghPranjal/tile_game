import '../../../../core/utils/bitset.dart';
import '../../../../core/utils/seeded_random.dart';
import '../entities/board_geometry.dart';
import '../entities/board_state.dart';
import '../services/tile_availability_service.dart';

/// Finds an order in which the board's POSITIONS can be cleared two at a
/// time, using the real availability rules and ignoring symbols.
///
/// Assigning one symbol per generated pair afterwards yields a board that is
/// solvable by construction (availability depends only on geometry and
/// removal state, never on symbols).
class RemovalSequenceGenerator {
  final int nodeBudget;

  /// How many random candidate pairs are tried at each search node before
  /// backtracking further up.
  final int branchLimit;

  const RemovalSequenceGenerator({
    this.nodeBudget = 20000,
    this.branchLimit = 6,
  });

  /// Returns a pair sequence clearing every tile not already in
  /// [initiallyRemoved], or `null` when none was found within budget.
  List<TilePair>? generate(
    BoardGeometry g,
    SeededRandom rng, {
    BitSet? initiallyRemoved,
    PairPreference preference = PairPreference.random,
  }) {
    final run = _Run(g, rng, nodeBudget, branchLimit, preference);
    var removed = initiallyRemoved ?? BitSet.empty(g.length);
    if ((g.length - removed.count).isOdd) return null;
    return run.dfs(removed) ? run.path : null;
  }
}

/// Influences which legal position pairs the generator prefers, which in
/// turn shapes difficulty.
enum PairPreference {
  /// Uniformly random legal pairs.
  random,

  /// Pairs physically close to each other (easier to spot).
  near,

  /// Pairs that are far apart and on different layers (harder to spot,
  /// longer dependency chains).
  far,
}

class _Run {
  final BoardGeometry g;
  final SeededRandom rng;
  final int budget;
  final int branchLimit;
  final PairPreference preference;
  final List<TilePair> path = [];
  final Set<BitSet> failed = {};
  int nodes = 0;

  _Run(this.g, this.rng, this.budget, this.branchLimit, this.preference);

  bool dfs(BitSet removed) {
    if (removed.isFull) return true;
    if (failed.contains(removed)) return false;
    if (++nodes > budget) return false;

    final free = TileAvailabilityService.selectableTiles(g, removed);
    if (free.length < 2) {
      failed.add(removed);
      return false;
    }

    for (final pair in _candidates(free, removed)) {
      path.add(pair);
      if (dfs(removed.withBits(pair.both))) return true;
      path.removeLast();
      if (nodes > budget) return false;
    }
    failed.add(removed);
    return false;
  }

  /// Tiles that hold up many others are preferred, so stacks are dismantled
  /// top-down evenly instead of leaving a lone tower (the usual dead end:
  /// one tile stacked on another with nothing else left).
  int _weight(int i, BitSet removed) {
    var w = 1;
    for (final d in g.dependents[i]) {
      if (removed[d]) continue;
      w += g.coveredBy[d].contains(i) ? 4 : 1;
    }
    return w;
  }

  int _weightedPick(List<int> free, List<int> weights, int total) {
    var r = rng.nextInt(total);
    for (var k = 0; k < free.length; k++) {
      r -= weights[k];
      if (r < 0) return free[k];
    }
    return free.last;
  }

  List<TilePair> _candidates(List<int> free, BitSet removed) {
    final result = <TilePair>[];
    final seen = <TilePair>{};
    final attempts = branchLimit * 4;
    final weights = [for (final i in free) _weight(i, removed)];
    final total = weights.fold<int>(0, (a, b) => a + b);
    for (var k = 0; k < attempts && result.length < branchLimit; k++) {
      final a = _weightedPick(free, weights, total);
      final b = _partnerFor(a, free);
      if (b == null) continue;
      final p = TilePair(a, b);
      if (seen.add(p)) result.add(p);
    }
    // Guarantee completeness for tiny free sets.
    if (result.isEmpty) {
      for (var x = 0; x < free.length; x++) {
        for (var y = x + 1; y < free.length; y++) {
          result.add(TilePair(free[x], free[y]));
        }
      }
      rng.shuffle(result);
    }
    return result;
  }

  int? _partnerFor(int a, List<int> free) {
    if (free.length < 2) return null;
    switch (preference) {
      case PairPreference.random:
        int b;
        do {
          b = rng.pick(free);
        } while (b == a);
        return b;
      case PairPreference.near:
      case PairPreference.far:
        // Tournament selection over a few random candidates.
        final ta = g.tiles[a];
        int? best;
        var bestScore = 0.0;
        for (var k = 0; k < 4; k++) {
          final b = rng.pick(free);
          if (b == a) continue;
          final tb = g.tiles[b];
          final d = (ta.x - tb.x).abs() +
              (ta.y - tb.y).abs() +
              (ta.layer - tb.layer).abs() * 1.5;
          final s = preference == PairPreference.near ? -d : d;
          if (best == null || s > bestScore) {
            best = b;
            bestScore = s;
          }
        }
        return best;
    }
  }
}
