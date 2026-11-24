import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/decor.dart';
import '../../../boosters/domain/booster.dart';
import '../controllers/game_controller.dart';
import '../controllers/game_view_state.dart';

String formatClock(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class GameTopBar extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onMenu;
  const GameTopBar({super.key, required this.onBack, required this.onMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(
      gameControllerProvider.select((s) => s.levelNumber),
    );
    final progress = ref.watch(
      gameControllerProvider.select((s) => s.progress),
    );
    final elapsed = ref.watch(
      gameControllerProvider.select((s) => s.elapsedMs),
    );
    final template = ref.watch(
      gameControllerProvider.select((s) => s.level?.templateName),
    );
    final remaining = ref.watch(
      gameControllerProvider.select((s) => s.remainingTiles),
    );

    final l = context.l10n;
    final palette = context.palette;
    final plum = palette.onPanel;
    final muted = palette.onPanelMuted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            tooltip: l.back,
            color: plum,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 9, 16, 11),
              decoration: BoxDecoration(
                color: palette.panel,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Left side yields space first: the layout name
                      // truncates, then "Level N" scales down if needed.
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) => Row(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: box.maxWidth * 0.6,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l.levelLabel(level),
                                    style: fredoka(19, 700, plum),
                                  ),
                                ),
                              ),
                              if (template != null) ...[
                                Container(
                                  width: 1.5,
                                  height: 16,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  color: palette.divider,
                                ),
                                Flexible(
                                  child: Text(
                                    l.layoutName(template),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: fredoka(13.5, 500, muted),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$remaining',
                        semanticsLabel: l.tilesLeft(remaining),
                        style: fredoka(12.5, 600, muted)
                            .copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.grid_view_rounded, size: 12, color: muted),
                      const SizedBox(width: 10),
                      Icon(Icons.timer_outlined, size: 17, color: plum),
                      const SizedBox(width: 3),
                      Text(
                        formatClock(elapsed),
                        style: fredoka(16, 700, plum).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  _ProgressTrack(progress: progress),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          RoundIconButton(
            icon: Icons.pause_rounded,
            onPressed: onMenu,
            tooltip: l.pauseAndSettings,
            color: plum,
          ),
        ],
      ),
    );
  }
}

/// Thick glossy green progress bar on a cream track.
class _ProgressTrack extends StatelessWidget {
  final double progress;
  const _ProgressTrack({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    height: 13,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: const Color(0xFFEFE9DF),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: const Color(0xFFE2DACD)),
    ),
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: progress),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, v, _) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v.clamp(0.0, 1.0),
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7BE36A), Color(0xFF2FB344)],
              ),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.white.withValues(alpha: 0.45),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Wooden booster tray (image-4 style).
class BoosterBar extends ConsumerWidget {
  final Future<void> Function(BoosterType) onBooster;
  const BoosterBar({super.key, required this.onBooster});

  static const icons = {
    BoosterType.hint: (
      Icons.lightbulb_rounded,
      [Color(0xFFFFE066), Color(0xFFFFA000)],
    ),
    BoosterType.undo: (
      Icons.undo_rounded,
      [Color(0xFFFFC266), Color(0xFFF57C00)],
    ),
    BoosterType.shuffle: (
      Icons.shuffle_rounded,
      [Color(0xFF4FC3F7), Color(0xFF1E5FE8)],
    ),
    BoosterType.magic: (
      Icons.auto_fix_high_rounded,
      [Color(0xFFC18CFF), Color(0xFF7232E0)],
    ),
  };

  /// Button fill (top, bottom) and base/depth colour per booster.
  static const _fills = {
    BoosterType.hint: (
      [Color(0xFFFFEDB0), Color(0xFFF8C24E)],
      Color(0xFFD99528),
    ),
    BoosterType.undo: (
      [Color(0xFFFFE3C2), Color(0xFFF5B670)],
      Color(0xFFD38A3E),
    ),
    BoosterType.shuffle: (
      [Color(0xFFDDEEFF), Color(0xFF86BDF6)],
      Color(0xFF4C86D6),
    ),
    BoosterType.magic: (
      [Color(0xFFF0E2FF), Color(0xFFC2A0F6)],
      Color(0xFF8E63D6),
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameControllerProvider);

    Widget button(BoosterType t, {bool active = false, bool enabled = true}) {
      final (icon, colors) = icons[t]!;
      final (fill, depth) = _fills[t]!;
      return Expanded(
        child: _BoosterButton(
          label: context.l10n.booster(t),
          icon: icon,
          colors: colors,
          fill: fill,
          depth: depth,
          count: s.remaining(t),
          active: active,
          enabled: enabled && s.isInteractive && s.remaining(t) > 0,
          onTap: () => onBooster(t),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD9A262),
                  Color(0xFFB0703A),
                  Color(0xFF94592A),
                ],
              ),
              border: Border.all(color: const Color(0xFF6E3B17), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: const Color(0x55FFE2B0), width: 1.5),
            ),
            child: CustomPaint(
              painter: const _WoodGrainPainter(),
              child: Row(
                children: [
                  button(
                    BoosterType.hint,
                    active: s.phase == GamePhase.hintActive,
                  ),
                  button(
                    BoosterType.undo,
                    enabled: s.session?.canUndo ?? false,
                  ),
                  // Debug builds only. `kDebugMode` is a compile-time
                  // constant, so this button is stripped from release
                  // (prod .aab / .apk / .ipa) builds entirely.
                  if (kDebugMode)
                    Expanded(
                      child: _BoosterButton(
                        key: const ValueKey('debug-autoplay'),
                        label: s.autoPlaying ? 'Stop' : 'Auto',
                        icon: s.autoPlaying
                            ? Icons.stop_rounded
                            : Icons.smart_toy_rounded,
                        colors: const [Color(0xFF7BE495), Color(0xFF1E9E4A)],
                        fill: const [Color(0xFFE2FBE8), Color(0xFF9BE3AE)],
                        depth: const Color(0xFF3FA35E),
                        count: null,
                        active: s.autoPlaying,
                        enabled:
                            s.autoPlaying ||
                            (s.isInteractive && !(s.board?.isCleared ?? true)),
                        onTap: () => ref
                            .read(gameControllerProvider.notifier)
                            .toggleAutoPlay(),
                      ),
                    ),
                  button(BoosterType.shuffle),
                  button(BoosterType.magic, active: s.magicArmed),
                ],
              ),
            ),
          ),
          Positioned(
            left: -10,
            top: -14,
            child: SizedBox(
              width: 44,
              height: 36,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(-1, 1, 1),
                child: CustomPaint(painter: LeavesPainter()),
              ),
            ),
          ),
          const Positioned(
            right: -10,
            top: -14,
            child: SizedBox(
              width: 44,
              height: 36,
              child: CustomPaint(painter: LeavesPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint horizontal grain lines on the tray.
class _WoodGrainPainter extends CustomPainter {
  const _WoodGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final f in const [0.18, 0.5, 0.82]) {
      final y = size.height * f;
      canvas.drawPath(
        Path()
          ..moveTo(0, y)
          ..cubicTo(
            size.width * 0.3,
            y - 3,
            size.width * 0.6,
            y + 3,
            size.width,
            y - 1,
          ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoosterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final List<Color> fill;
  final Color depth;
  /// Badge value; null hides the badge.
  final int? count;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _BoosterButton({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    required this.fill,
    required this.depth,
    required this.count,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_BoosterButton> createState() => _BoosterButtonState();
}

class _BoosterButtonState extends State<_BoosterButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final radius = BorderRadius.circular(20);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: w.enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: w.enabled ? w.onTap : null,
        child: AnimatedOpacity(
          opacity: w.enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: AnimatedScale(
            scale: _down ? 0.93 : 1,
            duration: const Duration(milliseconds: 100),
            child: Stack(
              clipBehavior: Clip.none,
              // Pass the slot's full width through to the card.
              fit: StackFit.passthrough,
              children: [
                Container(
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: w.fill,
                    ),
                    border: Border.all(
                      color: w.active
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: 0.85),
                      width: w.active ? 3 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(color: w.depth, offset: const Offset(0, 4)),
                      if (w.active)
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.7),
                          blurRadius: 14,
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (r) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: w.colors,
                        ).createShader(r),
                        child: Icon(w.icon, size: 32, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          w.label,
                          style: fredoka(15, 700, const Color(0xFF3D1466)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (w.count != null)
                  Positioned(
                  top: -9,
                  right: -5,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: w.count! > 0
                            ? const [Color(0xFFE64BE8), Color(0xFFB01BB8)]
                            : const [Color(0xFFB0A8B8), Color(0xFF8A8294)],
                      ),
                      border: Border.all(color: Colors.white, width: 2.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${w.count}',
                      style: fredoka(13, 700, Colors.white, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
