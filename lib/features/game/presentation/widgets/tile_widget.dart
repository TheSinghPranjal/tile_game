import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tile_symbol.dart';
import 'tile_painter.dart';

/// Visual state of one tile. Pure presentation: no game logic lives here.
class TileWidget extends StatefulWidget {
  final TileSymbol symbol;
  final int layer;
  final bool removed;
  final bool selectable;
  final bool selected;
  final bool hinted;
  final bool dimBlocked;
  final bool inspected;
  final bool isBlocker;

  /// Changes to this value trigger a shake; [strongShake] picks amplitude.
  final int shakeNonce;
  final bool strongShake;

  /// Changes trigger a "reveal" shimmer (shuffle / undo).
  final int revealNonce;
  final bool reduceMotion;
  final double thickness;

  const TileWidget({
    super.key,
    required this.symbol,
    required this.layer,
    required this.removed,
    required this.selectable,
    required this.selected,
    required this.hinted,
    required this.dimBlocked,
    required this.inspected,
    required this.isBlocker,
    required this.shakeNonce,
    required this.strongShake,
    required this.revealNonce,
    required this.reduceMotion,
    required this.thickness,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> with TickerProviderStateMixin {
  late final AnimationController _select = AnimationController(
    vsync: this,
    duration: GameConstants.selectDuration,
    value: widget.selected ? 1 : 0,
  );
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: GameConstants.shakeDuration);
  late final AnimationController _flash =
      AnimationController(vsync: this, duration: GameConstants.revealDuration);
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.hinted) _startPulse();
  }

  @override
  void didUpdateWidget(TileWidget old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      widget.selected ? _select.forward() : _select.reverse();
    }
    if (widget.shakeNonce != old.shakeNonce && !widget.reduceMotion) {
      _shake.forward(from: 0);
    }
    final newlyFree = !old.selectable && widget.selectable && !widget.removed &&
        !old.removed;
    if ((newlyFree || widget.revealNonce != old.revealNonce) &&
        !widget.reduceMotion) {
      _flash.forward(from: 0);
    }
    if (widget.hinted && !old.hinted) _startPulse();
    if (!widget.hinted && old.hinted) {
      _pulse?.dispose();
      _pulse = null;
    }
  }

  void _startPulse() {
    _pulse?.dispose();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _select.dispose();
    _shake.dispose();
    _flash.dispose();
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final animations = Listenable.merge([
      _select,
      _shake,
      _flash,
      ?_pulse,
    ]);

    final body = AnimatedBuilder(
      animation: animations,
      builder: (context, _) {
        final sel = Curves.easeOut.transform(_select.value);
        final pulse = _pulse == null ? 0.0 : 0.45 + 0.55 * _pulse!.value;
        final highlight = math.max(sel, pulse);
        final highlightColor = sel >= pulse ? AppColors.gold : AppColors.hint;
        final shakeT = _shake.value;
        final amp = w.strongShake ? 5.0 : 2.5;
        final dx = shakeT == 0 ? 0.0 : math.sin(shakeT * math.pi * 6) * amp * (1 - shakeT);
        final flash = _flash.isAnimating ? math.sin(_flash.value * math.pi) : 0.0;

        Color? outline;
        if (w.inspected) outline = const Color(0xFF4C6FFF);
        if (w.isBlocker) outline = AppColors.danger;

        return Transform.translate(
          offset: Offset(dx, -sel * w.thickness * 0.7),
          child: Transform.scale(
            scale: 1 + 0.06 * sel,
            child: CustomPaint(
              painter: TileBodyPainter(
                glyph: w.symbol.glyph,
                accent: Color(w.symbol.accent),
                thickness: w.thickness,
                layerShadow: w.layer.toDouble() + sel * 2,
                dimmed: w.dimBlocked && !w.selectable && !w.isBlocker,
                highlight: highlight,
                highlightColor: highlightColor,
                flash: flash,
                outline: outline,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );

    final dur = w.reduceMotion ? Duration.zero : GameConstants.removeDuration;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: w.removed ? 0 : 1,
        duration: dur,
        curve: Curves.easeIn,
        child: AnimatedScale(
          scale: w.removed ? 0.55 : 1,
          duration: dur,
          curve: Curves.easeInBack,
          child: RepaintBoundary(child: body),
        ),
      ),
    );
  }
}
