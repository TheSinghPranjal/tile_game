import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';

/// A short, lightweight sparkle burst drawn with a single CustomPainter.
class ParticleBurst extends StatefulWidget {
  final Offset center;
  final Color color;
  final double size;
  final int seed;
  final VoidCallback onDone;

  const ParticleBurst({
    super.key,
    required this.center,
    required this.color,
    required this.size,
    required this.seed,
    required this.onDone,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: GameConstants.burstDuration,
  )
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();

  late final List<_Particle> _particles = () {
    final r = math.Random(widget.seed);
    return List.generate(14, (i) {
      final angle = (i / 14) * math.pi * 2 + r.nextDouble() * 0.4;
      return _Particle(
        angle,
        widget.size * (0.55 + r.nextDouble() * 0.6),
        2 + r.nextDouble() * 3.2,
        r.nextBool(),
      );
    });
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent = widget.size * 2.6;
    return Positioned(
      left: widget.center.dx - extent / 2,
      top: widget.center.dy - extent / 2,
      width: extent,
      height: extent,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _BurstPainter(_c, _particles, widget.color),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double radius;
  final bool star;
  const _Particle(this.angle, this.distance, this.radius, this.star);
}

class _BurstPainter extends CustomPainter {
  final Animation<double> t;
  final List<_Particle> particles;
  final Color color;

  _BurstPainter(this.t, this.particles, this.color) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final v = Curves.easeOutCubic.transform(t.value);
    final fade = 1 - Curves.easeIn.transform(t.value);
    final c = size.center(Offset.zero);

    // Expanding ring.
    canvas.drawCircle(
      c,
      size.width * 0.18 + v * size.width * 0.22,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * fade
        ..color = Colors.white.withValues(alpha: 0.8 * fade),
    );

    final paint = Paint();
    for (final p in particles) {
      final pos = c + Offset(math.cos(p.angle), math.sin(p.angle)) * p.distance * v;
      paint.color = (p.star ? Colors.white : color).withValues(alpha: fade);
      if (p.star) {
        _drawSparkle(canvas, pos, p.radius * 1.6 * (0.6 + 0.4 * fade), paint);
      } else {
        canvas.drawCircle(pos, p.radius * fade, paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}
