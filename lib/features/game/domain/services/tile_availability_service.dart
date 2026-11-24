import '../../../../core/utils/bitset.dart';
import '../entities/board_geometry.dart';
import '../entities/tile_position.dart';

/// Tunable thresholds for the geometric availability rules.
class AvailabilityConfig {
  /// Minimum intersection (in tile units, on BOTH axes) for a higher-layer
  /// tile to count as covering a lower one. Prevents slivers / shadows from
  /// blocking selection.
  final double coverThreshold;

  /// Maximum gap between two same-layer tiles for them to count as touching
  /// horizontally (side blocking).
  final double sideContactTolerance;

  /// Minimum vertical overlap for a same-layer neighbour to block a side.
  final double sideOverlapThreshold;

  /// Maximum overlap area tolerated between two tiles on the same layer
  /// before the geometry is considered colliding/invalid.
  final double collisionTolerance;

  /// Classic Mahjong side rule: a tile also needs a free left or right side.
  /// Off by default – any tile with nothing on top of it can be tapped.
  final bool sideBlocking;

  const AvailabilityConfig({
    this.sideBlocking = false,
    this.coverThreshold = 0.1,
    this.sideContactTolerance = 0.05,
    this.sideOverlapThreshold = 0.1,
    this.collisionTolerance = 0.02,
  });

  static const standard = AvailabilityConfig();

  /// Classic rules with side blocking (kept for tests / alternative modes).
  static const classic = AvailabilityConfig(sideBlocking: true);
}

/// Static geometric relationships derived purely from tile rectangles.
class TileRelations {
  final List<List<int>> coveredBy;
  final List<List<int>> leftBlockers;
  final List<List<int>> rightBlockers;

  const TileRelations(this.coveredBy, this.leftBlockers, this.rightBlockers);
}

/// Derives tile availability from board geometry + current removal state.
///
/// A tile is selectable iff:
///   * it has not been removed, AND
///   * no remaining higher-layer tile overlaps it (by more than
///     [AvailabilityConfig.coverThreshold] on both axes), AND
///   * only with [AvailabilityConfig.sideBlocking]: its left side OR its
///     right side is free of remaining same-layer neighbours.
///
/// Nothing in the game stores a mutable "selectable" flag – availability is
/// always recomputed from the removal state.
class TileAvailabilityService {
  const TileAvailabilityService._();

  /// Computes cover / side relationships with rectangle geometry.
  /// O(n²) – executed once per geometry and cached in [BoardGeometry].
  static TileRelations computeRelations(
    List<TilePosition> tiles,
    AvailabilityConfig config,
  ) {
    final n = tiles.length;
    final coveredBy = List.generate(n, (_) => <int>[]);
    final left = List.generate(n, (_) => <int>[]);
    final right = List.generate(n, (_) => <int>[]);
    final rects = [for (final t in tiles) t.rect];

    for (var i = 0; i < n; i++) {
      final a = tiles[i];
      final ra = rects[i];
      for (var j = 0; j < n; j++) {
        if (i == j) continue;
        final b = tiles[j];
        final rb = rects[j];
        if (b.layer > a.layer) {
          if (ra.overlapX(rb) > config.coverThreshold &&
              ra.overlapY(rb) > config.coverThreshold) {
            coveredBy[i].add(j);
          }
        } else if (config.sideBlocking && b.layer == a.layer) {
          if (ra.overlapY(rb) <= config.sideOverlapThreshold) continue;
          // b touches a's left edge.
          if ((rb.right - ra.left).abs() <= config.sideContactTolerance &&
              rb.centerX < ra.centerX) {
            left[i].add(j);
          }
          // b touches a's right edge.
          if ((rb.left - ra.right).abs() <= config.sideContactTolerance &&
              rb.centerX > ra.centerX) {
            right[i].add(j);
          }
        }
      }
    }
    return TileRelations(coveredBy, left, right);
  }

  static bool isCovered(BoardGeometry g, BitSet removed, int i) {
    for (final c in g.coveredBy[i]) {
      if (!removed[c]) return true;
    }
    return false;
  }

  static bool isLeftOpen(BoardGeometry g, BitSet removed, int i) {
    for (final b in g.leftBlockers[i]) {
      if (!removed[b]) return false;
    }
    return true;
  }

  static bool isRightOpen(BoardGeometry g, BitSet removed, int i) {
    for (final b in g.rightBlockers[i]) {
      if (!removed[b]) return false;
    }
    return true;
  }

  static bool isSelectable(BoardGeometry g, BitSet removed, int i) =>
      !removed[i] &&
      !isCovered(g, removed, i) &&
      (isLeftOpen(g, removed, i) || isRightOpen(g, removed, i));

  /// All currently selectable tile indices, ascending.
  static List<int> selectableTiles(BoardGeometry g, BitSet removed) => [
        for (var i = 0; i < g.length; i++)
          if (isSelectable(g, removed, i)) i,
      ];

  /// Incrementally updates a selectable set after [justRemoved] were removed.
  /// Only tiles whose relations reference the removed tiles are re-evaluated.
  static Set<int> updateSelectable(
    BoardGeometry g,
    BitSet removed,
    Set<int> previous,
    Iterable<int> justRemoved,
  ) {
    final next = {...previous}..removeAll(justRemoved);
    for (final r in justRemoved) {
      for (final d in g.dependents[r]) {
        if (isSelectable(g, removed, d)) {
          next.add(d);
        } else {
          next.remove(d);
        }
      }
    }
    return next;
  }

  /// Remaining tiles currently preventing [i] from being selected:
  /// all covering tiles plus, when both sides are blocked, the side blockers.
  static List<int> blockersOf(BoardGeometry g, BitSet removed, int i) {
    final result = <int>[
      for (final c in g.coveredBy[i])
        if (!removed[c]) c,
    ];
    if (!isLeftOpen(g, removed, i) && !isRightOpen(g, removed, i)) {
      result
        ..addAll(g.leftBlockers[i].where((b) => !removed[b]))
        ..addAll(g.rightBlockers[i].where((b) => !removed[b]));
    }
    return result;
  }

  /// A tile is "visible" when at least part of it is not hidden by a
  /// remaining tile directly above it. Visible does NOT imply selectable.
  static bool isVisible(BoardGeometry g, BitSet removed, int i) {
    if (removed[i]) return false;
    final r = g.tiles[i].rect;
    var coveredArea = 0.0;
    for (final c in g.coveredBy[i]) {
      if (removed[c]) continue;
      final rc = g.tiles[c].rect;
      coveredArea += r.overlapX(rc) * r.overlapY(rc);
    }
    return coveredArea < r.width * r.height - 1e-6;
  }
}
