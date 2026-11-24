import '../../../../core/utils/seeded_random.dart';
import '../entities/board_state.dart';

/// Assigns one symbol per pair of a removal sequence.
///
/// Because both tiles of every sequence pair receive the same symbol, the
/// sequence itself becomes a valid clearing solution.
class SymbolAssigner {
  const SymbolAssigner._();

  /// [pool] lists the distinct symbol IDs available. When there are at least
  /// as many symbols as pairs, every symbol is used at most once (each symbol
  /// appears exactly twice). Otherwise symbols are distributed as evenly as
  /// possible and the same symbol is kept off neighbouring sequence steps to
  /// avoid repetitive clumps.
  static List<int> assign({
    required int tileCount,
    required List<TilePair> sequence,
    required List<int> pool,
    required SeededRandom rng,
  }) {
    assert(pool.isNotEmpty);
    final k = sequence.length;
    // The pool is ordered by preference (primary theme first), so take the
    // leading symbols and only then randomise their placement.
    final shuffledPool = pool.take(k).toList();
    rng.shuffle(shuffledPool);

    final perPair = <int>[];
    if (pool.length >= k) {
      perPair.addAll(shuffledPool);
    } else {
      while (perPair.length < k) {
        final round = [...shuffledPool];
        rng.shuffle(round);
        perPair.addAll(round.take(k - perPair.length));
      }
      _spreadOut(perPair, rng);
    }

    final symbols = List<int>.filled(tileCount, -1);
    for (var i = 0; i < k; i++) {
      symbols[sequence[i].a] = perPair[i];
      symbols[sequence[i].b] = perPair[i];
    }
    return symbols;
  }

  /// Minimises identical symbols on adjacent sequence positions.
  static void _spreadOut(List<int> list, SeededRandom rng) {
    for (var pass = 0; pass < 3; pass++) {
      var changed = false;
      for (var i = 1; i < list.length; i++) {
        if (list[i] != list[i - 1]) continue;
        // Find a swap partner that does not create a new clash.
        for (var tries = 0; tries < 12; tries++) {
          final j = rng.nextInt(list.length);
          if (list[j] == list[i]) continue;
          bool clash(int idx, int value) =>
              (idx > 0 && list[idx - 1] == value && idx - 1 != i && idx - 1 != j) ||
              (idx + 1 < list.length &&
                  list[idx + 1] == value &&
                  idx + 1 != i &&
                  idx + 1 != j);
          if (clash(j, list[i]) || clash(i, list[j])) continue;
          final t = list[i];
          list[i] = list[j];
          list[j] = t;
          changed = true;
          break;
        }
      }
      if (!changed) break;
    }
  }
}
