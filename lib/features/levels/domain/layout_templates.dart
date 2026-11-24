import 'dart:math' as math;

import '../../../core/utils/seeded_random.dart';
import '../../game/domain/entities/tile_position.dart';
import 'shape_library.dart';

/// How each layer is derived from the layer beneath it.
enum StackMode {
  /// Aligned with the layer below, shrunk by one tile on every side.
  inset,

  /// Shifted half a tile right and down; each upper tile rests on a 2x2 block.
  halfOffset,

  /// Shifted half a tile horizontally; each upper tile rests on two tiles.
  halfOffsetH,

  /// Exactly on top of the tile below (restricted by the template's mask).
  same,

  /// Alternates [halfOffset] and [inset].
  alternate,

  /// Dense pile: each layer sits a quarter tile off the one below
  /// (alternating up-left / down-right), so many partly hidden tiles peek
  /// out around the upper ones. Used for tougher levels.
  quarterOffset,
}

/// Configurable knobs every template understands.
class LayoutParams {
  final int cols;
  final int rows;
  final int layers;

  /// Horizontally offset odd rows by half a tile (staggered layout).
  final bool staggerRows;

  /// How upper layers are positioned; `null` uses the template default.
  final StackMode? stackMode;

  /// Board-space size of one tile.
  final double tileWidth;
  final double tileHeight;

  /// Fraction of a tile that an offset upper tile overlaps the tile below
  /// (0.5 = classic half offset). Clamped to [0.25, 0.75].
  final double overlap;

  /// Upper bound on tile count; the builder trims the top layers to respect it.
  final int maxTiles;

  /// Picture silhouette used by [LayoutTemplate.shape].
  final ShapeArt? art;

  const LayoutParams({
    required this.cols,
    required this.rows,
    required this.layers,
    this.staggerRows = false,
    this.stackMode,
    this.tileWidth = 1,
    this.tileHeight = 1,
    this.overlap = 0.5,
    this.maxTiles = 160,
    this.art,
  });

  LayoutParams copyWith({int? cols, int? rows, int? layers, int? maxTiles}) =>
      LayoutParams(
        cols: cols ?? this.cols,
        rows: rows ?? this.rows,
        layers: layers ?? this.layers,
        staggerRows: staggerRows,
        stackMode: stackMode,
        tileWidth: tileWidth,
        tileHeight: tileHeight,
        overlap: overlap,
        maxTiles: maxTiles ?? this.maxTiles,
        art: art,
      );
}

/// Library of reusable board silhouettes.
enum LayoutTemplate {
  smallRectangle('Little Box', StackMode.inset),
  largeRectangle('Grand Hall', StackMode.inset),
  pyramid('Pyramid', StackMode.halfOffset),
  doublePyramid('Twin Peaks', StackMode.halfOffset),
  diamond('Diamond', StackMode.halfOffset),
  cross('Cross', StackMode.halfOffset),
  butterfly('Butterfly', StackMode.halfOffset),
  flower('Flower', StackMode.halfOffset),
  circle('Ring', StackMode.halfOffset),
  staircase('Staircase', StackMode.same),
  zigzag('Zigzag', StackMode.halfOffsetH),
  layeredSquare('Layer Cake', StackMode.alternate),
  asymmetricTower('Lighthouse', StackMode.same),
  clusters('Islands', StackMode.halfOffset),
  complex('Fortress', StackMode.halfOffset),
  procedural('Wilds', StackMode.halfOffset),
  pile('Treasure Pile', StackMode.quarterOffset),

  /// Letters, numbers, animals and objects from [ShapeLibrary]
  /// (the silhouette comes from [LayoutParams.art]).
  shape('Picture', StackMode.halfOffset);

  final String displayName;
  final StackMode defaultStack;

  const LayoutTemplate(this.displayName, this.defaultStack);

  List<TilePosition> build(LayoutParams p, SeededRandom rng) =>
      _LayoutBuilder(this, p, rng).build();
}

/// Builds tile positions on an integer quarter-unit grid (a tile spans 4x4
/// quarter-units), which keeps half- and quarter-offset layers exact before
/// conversion to doubles.
class _LayoutBuilder {
  final LayoutTemplate t;
  final LayoutParams p;
  final SeededRandom rng;

  _LayoutBuilder(this.t, this.p, this.rng);

  ShapeArt? get art => t == LayoutTemplate.shape ? p.art : null;
  int get cols => art?.width ?? p.cols;
  int get rows => art?.height ?? p.rows;
  double get cx => (cols - 1) / 2;
  double get cy => (rows - 1) / 2;

  List<TilePosition> build() {
    final base = _baseMask();
    final layers = <Set<(int, int)>>[_toUnits(base)];
    final mode = p.stackMode ?? t.defaultStack;
    for (var k = 1; k < p.layers; k++) {
      final m = mode == StackMode.alternate
          ? (k.isOdd ? StackMode.halfOffset : StackMode.inset)
          : mode;
      final next = _nextLayer(layers.last, m, k)
        ..removeWhere((pos) => !_upperAllowed(k, pos));
      if (art != null) _dropLoneTiles(next);
      if (next.isEmpty) break;
      layers.add(next);
    }
    // Trim from the top to respect maxTiles.
    var total = layers.fold<int>(0, (s, l) => s + l.length);
    while (total > p.maxTiles && layers.length > 1) {
      total -= layers.removeLast().length;
    }
    return _toTiles(layers);
  }

  // ---------------------------------------------------------------- masks --

  Set<(int, int)> _baseMask() {
    final a = art;
    if (a != null) return a.cells;
    if (t == LayoutTemplate.shape) {
      // No art supplied: fall back to a plain block.
      return {for (var r = 0; r < rows; r++) for (var c = 0; c < cols; c++) (c, r)};
    }
    final cells = <(int, int)>{};
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (_inBase(c, r)) cells.add((c, r));
      }
    }
    if (t == LayoutTemplate.procedural) return _proceduralBlob();
    return cells;
  }

  bool _inBase(int c, int r) {
    final dx = (c - cx).abs();
    final dy = (r - cy).abs();
    final nx = cx == 0 ? 0.0 : dx / (cx + 0.5);
    final ny = cy == 0 ? 0.0 : dy / (cy + 0.5);
    switch (t) {
      case LayoutTemplate.smallRectangle:
      case LayoutTemplate.largeRectangle:
      case LayoutTemplate.pyramid:
      case LayoutTemplate.layeredSquare:
      case LayoutTemplate.procedural:
      case LayoutTemplate.shape:
        return true;
      case LayoutTemplate.doublePyramid:
        final mid = cols ~/ 2;
        return cols.isOdd ? c != mid : true;
      case LayoutTemplate.diamond:
        return nx + ny <= 1.05;
      case LayoutTemplate.cross:
        final bandX = math.max(1, cols ~/ 3);
        final bandY = math.max(1, rows ~/ 3);
        return dx < bandX / 2 + 0.6 || dy < bandY / 2 + 0.6;
      case LayoutTemplate.butterfly:
        if (dx < 0.6) return dy < cy * 0.8; // body
        return ny <= nx * 1.1 + 0.25 && nx > 0.1;
      case LayoutTemplate.flower:
        final rr = math.min(cx, cy);
        double d(double ox, double oy) =>
            math.sqrt(math.pow(c - ox, 2) + math.pow(r - oy, 2));
        final petal = rr * 0.42 + 0.3;
        return d(cx, cy) <= rr * 0.45 + 0.4 ||
            d(cx, cy - rr * 0.62) <= petal ||
            d(cx, cy + rr * 0.62) <= petal ||
            d(cx - rr * 0.62, cy) <= petal ||
            d(cx + rr * 0.62, cy) <= petal;
      case LayoutTemplate.circle:
        final dist = math.sqrt(nx * nx + ny * ny);
        return dist <= 1.05 && dist >= 0.42;
      case LayoutTemplate.staircase:
        // Lower-left heavy staircase silhouette.
        final step = (c * rows / cols).floor();
        return r >= step - 1;
      case LayoutTemplate.zigzag:
        final period = math.max(2, rows - 2);
        final phase = c % (2 * period);
        final centre = phase < period ? phase : 2 * period - phase;
        return (r - centre - 0.5).abs() <= 1.6;
      case LayoutTemplate.asymmetricTower:
        final towerCols = math.max(2, cols ~/ 3);
        return c < towerCols || r >= rows - math.max(2, rows ~/ 3);
      case LayoutTemplate.clusters:
        // Four rounded islands separated by empty channels.
        final hx = cols ~/ 2, hy = rows ~/ 2;
        if (c == hx && cols.isOdd) return false;
        if (r == hy && rows.isOdd) return false;
        final qc = c < hx ? c : c - (cols - hx);
        final qr = r < hy ? r : r - (rows - hy);
        final qw = hx, qh = hy;
        final corner = (qc == 0 || qc == qw - 1) && (qr == 0 || qr == qh - 1);
        return !(corner && qw > 2 && qh > 2);
      case LayoutTemplate.pile:
        // Rounded heap: a squircle footprint.
        return nx * nx * nx * nx + ny * ny * ny * ny <= 1.15;
      case LayoutTemplate.complex:
        // Rectangle with symmetric window holes.
        final hole = (c % 5 == 1) && (r % 5 == 1) && dx > 1.6 && dy > 1.6;
        return !hole;
    }
  }

  Set<(int, int)> _proceduralBlob() {
    final target = (cols * rows * (0.55 + rng.nextDouble() * 0.25)).round();
    final cells = <(int, int)>{(cols ~/ 2, rows ~/ 2)};
    final mirror = rng.nextBool(0.7);
    var guard = 0;
    while (cells.length < target && guard++ < 5000) {
      final from = cells.elementAt(rng.nextInt(cells.length));
      final dir = rng.nextInt(4);
      final nc = from.$1 + (dir == 0 ? 1 : dir == 1 ? -1 : 0);
      final nr = from.$2 + (dir == 2 ? 1 : dir == 3 ? -1 : 0);
      if (nc < 0 || nr < 0 || nc >= cols || nr >= rows) continue;
      cells.add((nc, nr));
      if (mirror) cells.add((cols - 1 - nc, nr));
    }
    return cells;
  }

  /// Extra per-template restriction for upper layers (half-unit coords).
  bool _upperAllowed(int k, (int, int) pos) {
    final c = pos.$1 / 4, r = pos.$2 / 4;
    switch (t) {
      case LayoutTemplate.staircase:
        // Each successive layer starts further right: rising steps.
        return c >= k * cols / (p.layers + 0.5);
      case LayoutTemplate.asymmetricTower:
        final towerCols = math.max(2, cols ~/ 3);
        return c < towerCols && r >= k * 0.5;
      case LayoutTemplate.procedural:
        // Occasional notches make upper layers irregular without
        // undermining support for the layers above.
        return k < 2 || rng.nextBool(0.96);
      case LayoutTemplate.complex:
        if (k >= 3) {
          return (c - cx).abs() < 1.6 || (r - cy).abs() < 1.6;
        }
        return true;
      default:
        return true;
    }
  }

  // --------------------------------------------------------------- layers --

  /// Cell (c, r) -> quarter units; staggered rows shift by half a tile.
  Set<(int, int)> _toUnits(Set<(int, int)> cells) => {
        for (final (c, r) in cells)
          (4 * c + (p.staggerRows && art == null && r.isOdd ? 2 : 0), 4 * r),
      };

  /// Quarter-unit cells occupied by a layer (each tile fills 4x4 cells).
  static Set<(int, int)> _cells(Set<(int, int)> layer) => {
        for (final (x, y) in layer)
          for (var dy = 0; dy < 4; dy++)
            for (var dx = 0; dx < 4; dx++) (x + dx, y + dy),
      };

  /// True when every cell of the rectangle [x0..x1]x[y0..y1] is occupied.
  static bool _filled(Set<(int, int)> cells, int x0, int y0, int x1, int y1) {
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        if (!cells.contains((x, y))) return false;
      }
    }
    return true;
  }

  /// Upper tiles are only placed where the layer below fully supports them,
  /// which works identically for aligned, staggered and offset grids.
  Set<(int, int)> _nextLayer(Set<(int, int)> below, StackMode mode, int k) {
    final cells = _cells(below);
    bool supported(int x, int y) => _filled(cells, x, y, x + 3, y + 3);
    switch (mode) {
      case StackMode.inset:
        // Keep tiles whose whole one-tile neighbourhood is present.
        return {
          for (final (x, y) in below)
            if (_filled(cells, x - 4, y - 4, x + 7, y + 7)) (x, y),
        };
      case StackMode.halfOffset:
        return {
          for (final (x, y) in below)
            if (supported(x + 2, y + 2)) (x + 2, y + 2),
        };
      case StackMode.halfOffsetH:
        return {
          for (final (x, y) in below)
            if (supported(x + 2, y) && _rowInteriorish(below, x, y)) (x + 2, y),
        };
      case StackMode.quarterOffset:
        // Alternate the lean so the pile stays centred.
        final d = k.isOdd ? -1 : 1;
        return {
          for (final (x, y) in below)
            if (supported(x + d, y + d)) (x + d, y + d),
        };
      case StackMode.same:
        return {...below};
      case StackMode.alternate:
        return _nextLayer(
          below,
          k.isOdd ? StackMode.halfOffset : StackMode.inset,
          k,
        );
    }
  }

  /// Pictures read cleaner when upper layers form clusters: a tile with no
  /// side-by-side or stacked neighbour on its own layer is removed.
  static void _dropLoneTiles(Set<(int, int)> layer) {
    bool near((int, int) a) {
      for (final b in layer) {
        if (b == a) continue;
        final dx = (b.$1 - a.$1).abs(), dy = (b.$2 - a.$2).abs();
        if (dx <= 4 && dy <= 4) return true;
      }
      return false;
    }

    layer.removeWhere((t) => !near(t));
  }

  /// Keeps horizontal half-offset layers from covering entire thin rows,
  /// so some lower tiles in every row stay visible.
  bool _rowInteriorish(Set<(int, int)> below, int x, int y) =>
      below.contains((x - 4, y)) || below.contains((x + 8, y));

  // --------------------------------------------------------------- output --

  List<TilePosition> _toTiles(List<Set<(int, int)>> layers) {
    // Half offsets honour the configurable overlap; quarter offsets are exact.
    final half = 1 - p.overlap.clamp(0.25, 0.75);
    double conv(int q) {
      final r = q % 4; // q >= 0 after normalisation
      return (q ~/ 4) + (r == 2 ? half : r * 0.25);
    }

    var minX = 1 << 30, minY = 1 << 30;
    for (final l in layers) {
      for (final (x, y) in l) {
        minX = math.min(minX, x);
        minY = math.min(minY, y);
      }
    }
    // Normalise to a whole-tile origin so offsets (q % 4) are preserved.
    minX -= minX % 4;
    minY -= minY % 4;

    final out = <TilePosition>[];
    for (var k = 0; k < layers.length; k++) {
      final sorted = layers[k].toList()
        ..sort((a, b) => a.$2 != b.$2 ? a.$2 - b.$2 : a.$1 - b.$1);
      for (final (x, y) in sorted) {
        out.add(TilePosition(
          id: out.length,
          layer: k,
          x: conv(x - minX) * p.tileWidth,
          y: conv(y - minY) * p.tileHeight,
          width: p.tileWidth,
          height: p.tileHeight,
        ));
      }
    }
    return out;
  }
}
