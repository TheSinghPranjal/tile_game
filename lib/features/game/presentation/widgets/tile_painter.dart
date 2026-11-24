import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

/// Caches laid-out glyphs; text layout is the costliest part of a tile.
class _GlyphCache {
  static final _cache = <(String, int), TextPainter>{};

  static TextPainter get(String glyph, double size) {
    final key = (glyph, size.round());
    final hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length > 400) _cache.clear();
    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(fontSize: size.roundToDouble(), height: 1.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return _cache[key] = tp;
  }
}

/// Paints a complete raised tile: drop shadow, side thickness, face, glyph,
/// state overlays and rim – in one pass, without saveLayer.
class TileBodyPainter extends CustomPainter {
  final String glyph;
  final Color accent;
  final double thickness;
  final double layerShadow;
  final bool dimmed;
  final double highlight; // 0..1 selection glow
  final Color highlightColor;
  final double flash; // 0..1 newly-free shimmer
  final Color? outline;

  TileBodyPainter({
    required this.glyph,
    required this.accent,
    required this.thickness,
    required this.layerShadow,
    required this.dimmed,
    required this.highlight,
    required this.highlightColor,
    required this.flash,
    this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = thickness * GameConstants.tileSideRatio;
    final face = Rect.fromLTWH(0, 0, size.width - side, size.height - thickness);
    final body = face.shift(Offset(side, thickness));
    final radius = Radius.circular(face.width * 0.2);
    final faceRR = RRect.fromRectAndRadius(face, radius);
    final bodyRR = RRect.fromRectAndRadius(body, radius);

    // Soft drop shadow beneath the whole tile; higher layers cast more.
    canvas.drawRRect(
      bodyRR.shift(Offset(0, thickness * 0.55)),
      Paint()
        ..color = const Color(0xFF3B2A5C)
            .withValues(alpha: (0.18 + layerShadow * 0.03).clamp(0.0, 0.4))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.5 + layerShadow * 1.2),
    );

    // Bottom lip: cream fading into lavender, like a glazed ceramic edge.
    canvas.drawRRect(
      bodyRR,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4EADC), Color(0xFFDCCCEC), Color(0xFFB7A0E2)],
          stops: [0.55, 0.82, 1.0],
        ).createShader(body),
    );
    canvas.drawRRect(
      bodyRR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0xFFA48BD8).withValues(alpha: 0.85),
    );

    // Selection / hint glow.
    if (highlight > 0) {
      canvas.drawRRect(
        faceRR.inflate(3 * highlight),
        Paint()
          ..color = highlightColor.withValues(alpha: 0.6 * highlight)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * highlight),
      );
    }

    // Ivory face.
    canvas.drawRRect(
      faceRR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFEFA),
            Color.lerp(const Color(0xFFF7EFE2), accent, 0.025)!,
          ],
        ).createShader(face),
    );
    // Seam between face and lip.
    canvas.drawRRect(
      faceRR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFE4D6C2),
    );
    // Glossy inner highlight along the top.
    canvas.drawRRect(
      faceRR.deflate(1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white.withValues(alpha: 0)],
        ).createShader(face),
    );

    // Glyph, large and centred.
    final tp = _GlyphCache.get(glyph, face.width * 0.64);
    tp.paint(
      canvas,
      face.center - Offset(tp.width / 2, tp.height / 2 + face.height * 0.01),
    );

    if (flash > 0) {
      canvas.drawRRect(
        faceRR,
        Paint()..color = Colors.white.withValues(alpha: 0.55 * flash),
      );
    }

    if (dimmed) {
      canvas.drawRRect(
        faceRR,
        Paint()..color = const Color(0xFF3A3150).withValues(alpha: 0.26),
      );
    }

    // State rim (selected / inspected / blocker).
    if (outline != null || highlight > 0) {
      canvas.drawRRect(
        faceRR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = outline != null ? 2.6 : 2.4 * highlight
          ..color = outline ?? highlightColor,
      );
    }
  }

  @override
  bool shouldRepaint(TileBodyPainter old) =>
      old.glyph != glyph ||
      old.accent != accent ||
      old.thickness != thickness ||
      old.dimmed != dimmed ||
      old.highlight != highlight ||
      old.highlightColor != highlightColor ||
      old.flash != flash ||
      old.outline != outline ||
      old.layerShadow != layerShadow;
}
