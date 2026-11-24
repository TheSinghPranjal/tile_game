import '../entities/board_state.dart';

enum MatchResultType {
  /// Both tiles were removed.
  matched,

  /// Both tiles are selectable but their symbols differ.
  mismatch,

  /// The move is illegal (same tile, removed or blocked tile).
  invalid,
}

class MatchResult {
  final MatchResultType type;
  final BoardState state;

  const MatchResult(this.type, this.state);

  bool get isMatch => type == MatchResultType.matched;
}

/// Pure rules of the two-tile matching game. Holds no mutable state.
class GameEngine {
  const GameEngine._();

  /// Whether [i] may currently be picked by the player.
  static bool canSelect(BoardState s, int i) =>
      i >= 0 && i < s.length && s.isSelectable(i);

  /// Attempts to match tiles [a] and [b].
  static MatchResult tryMatch(BoardState s, int a, int b) {
    if (a == b || !canSelect(s, a) || !canSelect(s, b)) {
      return MatchResult(MatchResultType.invalid, s);
    }
    if (s.symbols[a] != s.symbols[b]) {
      return MatchResult(MatchResultType.mismatch, s);
    }
    return MatchResult(MatchResultType.matched, s.withRemoved([a, b]));
  }

  /// All pairs of currently selectable tiles that share a symbol.
  static List<TilePair> matchingPairs(BoardState s) =>
      matchingPairsAmong(s, s.selectableTiles);

  static List<TilePair> matchingPairsAmong(BoardState s, List<int> free) {
    final bySymbol = <int, List<int>>{};
    for (final i in free) {
      (bySymbol[s.symbols[i]] ??= []).add(i);
    }
    final pairs = <TilePair>[];
    for (final group in bySymbol.values) {
      for (var x = 0; x < group.length; x++) {
        for (var y = x + 1; y < group.length; y++) {
          pairs.add(TilePair(group[x], group[y]));
        }
      }
    }
    return pairs;
  }

  /// Number of remaining tiles that become (newly) selectable if [pair] is
  /// removed. Used by hints and solver ordering.
  static int exposureGain(BoardState s, TilePair pair) {
    final after = s.removed.withBits(pair.both);
    var gain = 0;
    final seen = <int>{};
    for (final r in pair.both) {
      for (final d in s.geometry.dependents[r]) {
        if (!seen.add(d) || after[d]) continue;
        if (!s.isSelectable(d) &&
            BoardState(geometry: s.geometry, symbols: s.symbols, removed: after)
                .isSelectable(d)) {
          gain++;
        }
      }
    }
    return gain;
  }

  /// Number of remaining tiles that list either tile of [pair] as a
  /// coverer – a proxy for how much hidden structure the pair unlocks.
  static int coverWeight(BoardState s, TilePair pair) {
    var w = 0;
    for (final r in pair.both) {
      for (final d in s.geometry.dependents[r]) {
        if (!s.removed[d] && s.geometry.coveredBy[d].contains(r)) w += 2;
        if (!s.removed[d]) w += 1;
      }
    }
    return w;
  }
}
