import 'dart:math' as math;

import '../services/tile_availability_service.dart';
import 'tile_position.dart';

/// Immutable board geometry with cached static relationships.
///
/// Tile `i` is `tiles[i]` and `tiles[i].id == i`.
class BoardGeometry {
  final List<TilePosition> tiles;
  final AvailabilityConfig config;

  /// Remaining higher-layer tiles overlapping tile i.
  final List<List<int>> coveredBy;

  /// Same-layer tiles touching tile i's left / right edge.
  final List<List<int>> leftBlockers;
  final List<List<int>> rightBlockers;

  /// Inverse relation: tiles whose availability may change when i is removed.
  final List<List<int>> dependents;

  /// Tile indices in paint order (bottom first).
  final List<int> zOrder;

  final double minX, minY, maxX, maxY;
  final int layerCount;

  BoardGeometry._({
    required this.tiles,
    required this.config,
    required this.coveredBy,
    required this.leftBlockers,
    required this.rightBlockers,
    required this.dependents,
    required this.zOrder,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.layerCount,
  });

  factory BoardGeometry(
    List<TilePosition> input, {
    AvailabilityConfig config = AvailabilityConfig.standard,
  }) {
    final tiles = List<TilePosition>.unmodifiable([
      for (var i = 0; i < input.length; i++)
        input[i].id == i ? input[i] : input[i].copyWith(id: i),
    ]);
    final rel = TileAvailabilityService.computeRelations(tiles, config);
    final dependents = List.generate(tiles.length, (_) => <int>{});
    for (var i = 0; i < tiles.length; i++) {
      for (final c in rel.coveredBy[i]) {
        dependents[c].add(i);
      }
      for (final b in rel.leftBlockers[i]) {
        dependents[b].add(i);
      }
      for (final b in rel.rightBlockers[i]) {
        dependents[b].add(i);
      }
    }
    final z = List<int>.generate(tiles.length, (i) => i)
      ..sort((a, b) => tiles[a].compareZ(tiles[b]));

    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    var layers = 0;
    for (final t in tiles) {
      minX = math.min(minX, t.x);
      minY = math.min(minY, t.y);
      maxX = math.max(maxX, t.x + t.width);
      maxY = math.max(maxY, t.y + t.height);
      layers = math.max(layers, t.layer + 1);
    }
    if (tiles.isEmpty) {
      minX = minY = maxX = maxY = 0;
    }

    List<List<int>> freeze(List<Iterable<int>> l) =>
        List.unmodifiable([for (final e in l) List<int>.unmodifiable(e)]);

    return BoardGeometry._(
      tiles: tiles,
      config: config,
      coveredBy: freeze(rel.coveredBy),
      leftBlockers: freeze(rel.leftBlockers),
      rightBlockers: freeze(rel.rightBlockers),
      dependents: freeze(dependents),
      zOrder: List.unmodifiable(z),
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      layerCount: layers,
    );
  }

  int get length => tiles.length;
  double get width => maxX - minX;
  double get height => maxY - minY;

  /// Longest chain of "must remove X before Y" cover relations (+1).
  int get dependencyDepth {
    final memo = List<int>.filled(length, -1);
    int depth(int i) {
      if (memo[i] >= 0) return memo[i];
      var d = 1;
      for (final c in coveredBy[i]) {
        d = math.max(d, depth(c) + 1);
      }
      return memo[i] = d;
    }

    var best = 0;
    for (var i = 0; i < length; i++) {
      best = math.max(best, depth(i));
    }
    return best;
  }

  List<Map<String, dynamic>> toJson() => [for (final t in tiles) t.toJson()];

  factory BoardGeometry.fromJson(List<dynamic> j) => BoardGeometry([
        for (final e in j) TilePosition.fromJson(e as Map<String, dynamic>),
      ]);
}
