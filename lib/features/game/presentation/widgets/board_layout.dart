import 'dart:math' as math;
import 'dart:ui';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/utils/bitset.dart';
import '../../domain/entities/board_geometry.dart';

/// Converts between board space (tile units) and screen space (logical px).
///
/// Rendering AND hit-testing both go through this class, so what the player
/// sees is exactly what they can tap. Each layer is drawn shifted up-left by
/// a small depth offset to reveal the tiles beneath; hit-testing applies the
/// same shift.
class BoardLayout {
  final BoardGeometry geometry;

  /// Screen width / height of one board unit.
  final double unitW;
  final double unitH;

  /// Per-layer depth shift in px.
  final double shiftX;
  final double shiftY;

  /// Screen position of board-space (minX, minY) on layer 0.
  final Offset origin;

  /// Total content size (may exceed the viewport for huge boards).
  final Size contentSize;

  const BoardLayout._(
    this.geometry,
    this.unitW,
    this.unitH,
    this.shiftX,
    this.shiftY,
    this.origin,
    this.contentSize,
  );

  /// Fits [g] into [viewport], honouring a minimum readable tile size.
  factory BoardLayout.fit(BoardGeometry g, Size viewport, {double padding = 10}) {
    const aspect = GameConstants.tileAspect;
    final depth = math.max(0, g.layerCount - 1);
    final extraW = depth * GameConstants.layerShiftX.abs() +
        GameConstants.tileThickness;
    final extraH = depth * GameConstants.layerShiftY.abs() +
        GameConstants.tileThickness;

    final availW = math.max(1.0, viewport.width - padding * 2);
    final availH = math.max(1.0, viewport.height - padding * 2);
    final byWidth = availW / (g.width + extraW);
    final byHeight = availH / (g.height * aspect + extraH);
    final unitW = math
        .min(byWidth, byHeight)
        .clamp(GameConstants.minTileWidth, GameConstants.maxTileWidth)
        .toDouble();
    final unitH = unitW * aspect;

    final shiftX = GameConstants.layerShiftX * unitW;
    final shiftY = GameConstants.layerShiftY * unitW;
    final boardW = g.width * unitW + extraW * unitW;
    final boardH = g.height * unitH + extraH * unitW;
    final content = Size(
      math.max(viewport.width, boardW + padding * 2),
      math.max(viewport.height, boardH + padding * 2),
    );
    final origin = Offset(
      (content.width - boardW) / 2 + depth * shiftX.abs(),
      // Slightly above centre (image-6 placement); never off-screen.
      (content.height - boardH) * 0.38 + depth * shiftY.abs(),
    );
    return BoardLayout._(g, unitW, unitH, shiftX, shiftY, origin, content);
  }

  bool get overflows => unitW <= GameConstants.minTileWidth + 0.01;

  /// Screen rect of tile [i]'s top face (including its depth shift).
  Rect tileRect(int i) {
    final t = geometry.tiles[i];
    return Rect.fromLTWH(
      origin.dx + (t.x - geometry.minX) * unitW + t.layer * shiftX,
      origin.dy + (t.y - geometry.minY) * unitH + t.layer * shiftY,
      t.width * unitW,
      t.height * unitH,
    );
  }

  Offset boardToScreen(double x, double y, int layer) => Offset(
        origin.dx + (x - geometry.minX) * unitW + layer * shiftX,
        origin.dy + (y - geometry.minY) * unitH + layer * shiftY,
      );

  /// Topmost remaining tile under [p], or null.
  int? hitTest(Offset p, BitSet removed) {
    final z = geometry.zOrder;
    for (var k = z.length - 1; k >= 0; k--) {
      final i = z[k];
      if (removed[i]) continue;
      if (tileRect(i).contains(p)) return i;
    }
    return null;
  }
}
