import '../entities/board_geometry.dart';
import '../entities/board_state.dart';
import '../services/game_engine.dart';
import '../services/tile_availability_service.dart';

class LevelValidationReport {
  final List<String> issues;
  const LevelValidationReport(this.issues);
  bool get isValid => issues.isEmpty;

  @override
  String toString() => isValid ? 'valid' : issues.join('\n');
}

/// Verifies a level against its solution certificate by replaying every pair
/// through the real [GameEngine], plus the covered-tile guarantees.
class LevelValidator {
  const LevelValidator._();

  static LevelValidationReport validate(
    BoardGeometry g,
    List<int> symbols,
    List<TilePair> sequence,
  ) {
    final issues = <String>[];
    if (symbols.length != g.length) {
      issues.add('Symbol count ${symbols.length} != tile count ${g.length}.');
      return LevelValidationReport(issues);
    }

    // Every symbol must appear an even number of times.
    final counts = <int, int>{};
    for (final s in symbols) {
      counts[s] = (counts[s] ?? 0) + 1;
    }
    counts.forEach((s, c) {
      if (c.isOdd) issues.add('Symbol $s appears an odd number of times ($c).');
    });

    // Every tile must appear exactly once in the certificate.
    final seen = <int>{};
    for (final p in sequence) {
      for (final t in p.both) {
        if (!seen.add(t)) issues.add('Tile $t appears twice in certificate.');
      }
    }
    if (seen.length != g.length) {
      issues.add('Certificate covers ${seen.length} of ${g.length} tiles.');
    }

    // Replay with the actual engine.
    var state = BoardState(geometry: g, symbols: symbols);
    final removedAtStep = List<int>.filled(g.length, -1);
    for (var step = 0; step < sequence.length; step++) {
      final p = sequence[step];
      // Covered-tile guarantees: every blocker of each tile in the pair must
      // already be gone, and the pair partner must be selectable now.
      for (final t in p.both) {
        for (final c in g.coveredBy[t]) {
          if (!state.isRemoved(c)) {
            issues.add('Step $step: tile $t still covered by $c.');
          }
        }
      }
      final r = GameEngine.tryMatch(state, p.a, p.b);
      if (!r.isMatch) {
        issues.add('Step $step: pair $p is ${r.type.name} '
            '(selectable: ${state.isSelectable(p.a)}/${state.isSelectable(p.b)}, '
            'symbols ${symbols[p.a]}/${symbols[p.b]}).');
        return LevelValidationReport(issues);
      }
      removedAtStep[p.a] = step;
      removedAtStep[p.b] = step;
      state = r.state;
    }
    if (!state.isCleared) {
      issues.add('Replay finished with ${state.remainingCount} tiles left.');
    }

    // Every covered tile's blockers are removed strictly before it.
    for (var i = 0; i < g.length; i++) {
      for (final c in g.coveredBy[i]) {
        if (removedAtStep[c] >= removedAtStep[i]) {
          issues.add('Tile $i removed before/with its cover $c.');
        }
      }
    }
    return LevelValidationReport(issues);
  }

  /// True when every tile could become selectable if all others were gone –
  /// i.e. there is no permanently trapped tile in the geometry.
  static bool noStructurallyTrappedTiles(BoardGeometry g) {
    for (var i = 0; i < g.length; i++) {
      final others = [for (var j = 0; j < g.length; j++) if (j != i) j];
      final removed = BoardState(
        geometry: g,
        symbols: List.filled(g.length, 0),
      ).removed.withBits(others);
      if (!TileAvailabilityService.isSelectable(g, removed, i)) return false;
    }
    return true;
  }
}
