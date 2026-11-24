import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Soft gradient backdrop with subtle decorative circles.
class GradientBackdrop extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  const GradientBackdrop({super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(size: 220, color: Colors.white.withValues(alpha: 0.22)),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Blob(size: 260, color: Colors.white.withValues(alpha: 0.16)),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

/// Rounded frosted pill used for HUD elements.
class Pill extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Pill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      );
}

class StarBadge extends StatelessWidget {
  final int stars;
  const StarBadge({super.key, required this.stars});

  @override
  Widget build(BuildContext context) => Pill(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 4),
          Text('$stars',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.ink)),
        ]),
      );
}

/// Circular icon button with soft elevation.
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final Color color;
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: color, size: size * 0.55),
            ),
          ),
        ),
      );
}

class StarRow extends StatelessWidget {
  final int stars;
  final double size;
  const StarRow({super.key, required this.stars, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              Icons.star_rounded,
              size: size,
              color: i < stars ? AppColors.gold : Colors.black12,
            ),
        ],
      );
}
