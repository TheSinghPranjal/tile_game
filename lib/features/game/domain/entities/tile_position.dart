import 'dart:math' as math;

/// Axis aligned rectangle in *board space* (tile units).
///
/// Board space is resolution independent: a standard tile is 1 x 1 unit.
/// Presentation code converts to screen space via `BoardLayout`.
class BoardRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const BoardRect(this.left, this.top, this.width, this.height);

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  /// Width of the horizontal intersection with [o] (0 when disjoint).
  double overlapX(BoardRect o) =>
      math.max(0, math.min(right, o.right) - math.max(left, o.left));

  /// Height of the vertical intersection with [o] (0 when disjoint).
  double overlapY(BoardRect o) =>
      math.max(0, math.min(bottom, o.bottom) - math.max(top, o.top));

  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;

  @override
  String toString() => 'BoardRect($left, $top, ${width}x$height)';
}

/// The static, geometric definition of one tile slot on a board.
///
/// Symbols and removal state are deliberately NOT stored here: geometry is
/// fixed for a level, while symbols can be shuffled and tiles removed.
class TilePosition {
  /// Stable index of the tile within its board (0..n-1). Doubles as tile ID.
  final int id;
  final int layer;
  final double x;
  final double y;
  final double width;
  final double height;

  /// Rotation in quarter turns. Reserved for future layouts; the availability
  /// engine treats rotated tiles by their (already rotated) bounding box.
  final int rotation;

  const TilePosition({
    required this.id,
    required this.layer,
    required this.x,
    required this.y,
    this.width = 1,
    this.height = 1,
    this.rotation = 0,
  });

  BoardRect get rect => BoardRect(x, y, width, height);

  /// Deterministic paint order: lower layers first, then top-to-bottom,
  /// then left-to-right.
  int compareZ(TilePosition o) {
    if (layer != o.layer) return layer.compareTo(o.layer);
    if (y != o.y) return y.compareTo(o.y);
    if (x != o.x) return x.compareTo(o.x);
    return id.compareTo(o.id);
  }

  TilePosition copyWith({int? id}) => TilePosition(
        id: id ?? this.id,
        layer: layer,
        x: x,
        y: y,
        width: width,
        height: height,
        rotation: rotation,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'l': layer,
        'x': x,
        'y': y,
        if (width != 1) 'w': width,
        if (height != 1) 'h': height,
        if (rotation != 0) 'r': rotation,
      };

  factory TilePosition.fromJson(Map<String, dynamic> j) => TilePosition(
        id: j['id'] as int,
        layer: j['l'] as int,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        width: (j['w'] as num?)?.toDouble() ?? 1,
        height: (j['h'] as num?)?.toDouble() ?? 1,
        rotation: (j['r'] as int?) ?? 0,
      );

  @override
  String toString() => 'Tile#$id(L$layer @ $x,$y)';
}
