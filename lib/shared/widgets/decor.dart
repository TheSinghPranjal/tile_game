import 'package:flutter/material.dart';

/// Two glossy leaves used as corner decorations.
class LeavesPainter extends CustomPainter {
  const LeavesPainter();

  void _leaf(Canvas canvas, Offset base, double length, double angle,
      List<Color> colors) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final w = length * 0.42;
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.45, -w, length, 0)
      ..quadraticBezierTo(length * 0.45, w, 0, 0)
      ..close();
    final bounds = Rect.fromLTWH(0, -w, length, w * 2);
    canvas.drawShadow(leaf, const Color(0x55000000), 2, false);
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(bounds),
    );
    // Midrib.
    canvas.drawLine(
      Offset(length * 0.08, 0),
      Offset(length * 0.85, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Offset(size.width * 0.22, size.height * 0.78);
    _leaf(canvas, stem, size.width * 0.78, -0.62,
        const [Color(0xFF9BE05A), Color(0xFF3E9B2F)]);
    _leaf(canvas, stem, size.width * 0.6, 0.18,
        const [Color(0xFF7ACF4A), Color(0xFF2F8226)]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
