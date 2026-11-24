import '../../../../core/utils/bitset.dart';
import '../entities/board_geometry.dart';
import '../services/tile_availability_service.dart';

/// Structural checks on board geometry before any symbols are assigned.
class GeometryValidator {
  const GeometryValidator._();

  /// Returns a list of human readable problems (empty when valid).
  static List<String> validate(BoardGeometry g) {
    final issues = <String>[];
    if (g.length == 0) issues.add('Board has no tiles.');
    if (g.length.isOdd) issues.add('Odd tile count (${g.length}).');

    final ids = <int>{};
    for (var i = 0; i < g.length; i++) {
      final t = g.tiles[i];
      if (t.id != i) issues.add('Tile at index $i has id ${t.id}.');
      if (!ids.add(t.id)) issues.add('Duplicate tile id ${t.id}.');
      if (!t.x.isFinite || !t.y.isFinite || t.x < 0 || t.y < 0) {
        issues.add('Tile ${t.id} has invalid coordinates (${t.x}, ${t.y}).');
      }
      if (t.width <= 0 || t.height <= 0) {
        issues.add('Tile ${t.id} has invalid size.');
      }
      if (t.layer < 0) issues.add('Tile ${t.id} has negative layer.');
    }

    // Unintended collisions: same-layer tiles must not overlap.
    final tol = g.config.collisionTolerance;
    for (var i = 0; i < g.length; i++) {
      final a = g.tiles[i];
      for (var j = i + 1; j < g.length; j++) {
        final b = g.tiles[j];
        if (a.layer != b.layer) continue;
        final area = a.rect.overlapX(b.rect) * a.rect.overlapY(b.rect);
        if (area > tol) {
          issues.add('Tiles ${a.id} and ${b.id} collide on layer ${a.layer}.');
        }
      }
    }

    // Cover relations must point strictly upward (guarantees no cycles).
    for (var i = 0; i < g.length; i++) {
      for (final c in g.coveredBy[i]) {
        if (g.tiles[c].layer <= g.tiles[i].layer) {
          issues.add('Invalid cover relation $c -> $i.');
        }
      }
    }

    if (g.length > 0) {
      final initial =
          TileAvailabilityService.selectableTiles(g, BitSet.empty(g.length));
      if (initial.length < 2) {
        issues.add('Fewer than two tiles are initially selectable.');
      }
    }
    return issues;
  }
}
