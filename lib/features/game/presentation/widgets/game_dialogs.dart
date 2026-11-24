import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common.dart';
import '../../../progress/data/progress_repository.dart';
import 'game_hud.dart';

class LevelCompleteDialog extends StatefulWidget {
  final int level;
  final LevelReward reward;
  final int elapsedMs;
  final String difficultyLabel;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const LevelCompleteDialog({
    super.key,
    required this.level,
    required this.reward,
    required this.elapsedMs,
    required this.difficultyLabel,
    required this.onNext,
    required this.onReplay,
    required this.onHome,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reward;
    final l = context.l10n;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final isFinal = widget.level >= GameConstants.totalLevels;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isFinal ? '🏆' : '🎉', style: const TextStyle(fontSize: 46)),
            const SizedBox(height: 4),
            Text(
              isFinal
                  ? l.allLevelsCleared(GameConstants.totalLevels)
                  : l.boardCleared,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(
              l.levelDifficulty(
                widget.level,
                l.difficulty(widget.difficultyLabel),
              ),
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Transform.scale(
                      scale: Curves.elasticOut.transform(
                        ((_c.value * 3 - i * 0.5).clamp(0.0, 1.0)),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: i == 1 ? 64 : 50,
                        color: i < r.stars ? AppColors.gold : Colors.black12,
                      ),
                    ),
                ],
              ),
            ),
            if (r.stars < 3)
              Text(
                l.threeStarTip,
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              )
            else if (r.newBest)
              Text(
                l.newBest,
                style: const TextStyle(
                  color: AppColors.goldDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 10),
            Pill(child: Text('⏱ ${formatClock(widget.elapsedMs)}')),
            if (r.achievements.isNotEmpty) ...[
              const SizedBox(height: 14),
              for (final a in r.achievements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(a.badge, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.achievementUnlocked(l.achievementTitle(a)),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                l.achievementDescription(a),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onNext,
                icon: Icon(
                  isFinal
                      ? Icons.emoji_events_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  isFinal ? l.finishJourney : l.levelLabel(widget.level + 1),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: widget.onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(l.replay),
                ),
                TextButton.icon(
                  onPressed: widget.onHome,
                  icon: const Icon(Icons.home_rounded),
                  label: Text(l.home),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when no matching pair is currently selectable.
class NoMovesDialog extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onShuffle;
  final VoidCallback onUndo;

  const NoMovesDialog({
    super.key,
    required this.canUndo,
    required this.onShuffle,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Text('🤔', style: TextStyle(fontSize: 40)),
    title: Text(context.l10n.noMatchesTitle),
    content: Text(context.l10n.noMatchesBody, textAlign: TextAlign.center),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      if (canUndo)
        TextButton.icon(
          onPressed: onUndo,
          icon: const Icon(Icons.undo_rounded),
          label: Text(context.l10n.undo),
        ),
      FilledButton.icon(
        onPressed: onShuffle,
        icon: const Icon(Icons.shuffle_rounded),
        label: Text(context.l10n.freeShuffle),
      ),
    ],
  );
}

enum PauseAction { resume, restart, home }

class PauseSheet extends StatelessWidget {
  final Widget settings;
  const PauseSheet({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.paused,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            settings,
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, PauseAction.resume),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.resume),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, PauseAction.restart),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l.restart),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, PauseAction.home),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(l.home),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Light confetti rain drawn behind the completion dialog.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(painter: _ConfettiPainter(_c), size: Size.infinite),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> t;
  static const _colors = [
    Color(0xFFFFB627),
    Color(0xFFFF6B8B),
    Color(0xFF2EC4B6),
    Color(0xFF7A5CFA),
    Color(0xFF3CB371),
  ];
  _ConfettiPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(7);
    final p = Paint();
    final fade = t.value > 0.8 ? (1 - t.value) / 0.2 : 1.0;
    for (var i = 0; i < 70; i++) {
      final x0 = r.nextDouble() * size.width;
      final speed = 0.6 + r.nextDouble() * 0.8;
      final y =
          -20 + (size.height + 40) * (t.value * speed + r.nextDouble() * 0.15);
      final x = x0 + math.sin(t.value * 8 + i) * 18;
      p.color = _colors[i % _colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t.value * 10 + i);
      canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
