import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../boosters/domain/booster.dart';
import '../../game/presentation/widgets/game_hud.dart';
import '../../game/presentation/widgets/tile_painter.dart';

/// A short, swipeable guide to the rules, boosters and stars.
///
/// [onDone] runs when the player finishes or skips (defaults to closing).
class HowToPlayScreen extends StatefulWidget {
  final VoidCallback? onDone;
  const HowToPlayScreen({super.key, this.onDone});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  final _pages = PageController();
  int _index = 0;
  static const _count = 5;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() {
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _go(int i) => _pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final last = _index == _count - 1;

    final pages = [
      _Page(
        art: const _PairArt(),
        title: l.htpTitle1,
        body: l.htpBody1,
      ),
      _Page(
        art: _FreeBlockedArt(free: l.htpFree, blocked: l.htpBlocked),
        title: l.htpTitle2,
        body: l.htpBody2,
      ),
      _Page(
        art: const _InspectArt(),
        title: l.htpTitle3,
        body: l.htpBody3,
      ),
      _Page(
        art: const _BoosterArt(),
        title: l.htpTitle4,
        body: l.htpBody4,
        extra: const _BoosterList(),
      ),
      _Page(
        art: const _StarsArt(),
        title: l.htpTitle5,
        body: l.htpBody5(GameConstants.totalLevels),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.howToPlay),
        actions: [
          if (!last)
            TextButton(onPressed: _finish, child: Text(l.htpSkip)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Semantics(
              label: l.htpStep(_index + 1, _count),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(children: [
                if (_index > 0)
                  TextButton(
                    onPressed: () => _go(_index - 1),
                    child: Text(l.htpBack),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: last ? _finish : () => _go(_index + 1),
                  icon: Icon(last
                      ? Icons.play_arrow_rounded
                      : Icons.arrow_forward_rounded),
                  label: Text(last ? l.htpDone : l.htpNext),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final Widget art;
  final String title;
  final String body;
  final Widget? extra;
  const _Page({
    required this.art,
    required this.title,
    required this.body,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight - 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(child: art),
              ),
              const SizedBox(height: 28),
              Text(title,
                  textAlign: TextAlign.center,
                  style: fredoka(26, 700, theme.colorScheme.onSurface)),
              const SizedBox(height: 12),
              Text(body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.45, color: theme.colorScheme.onSurfaceVariant)),
              if (extra != null) ...[const SizedBox(height: 18), extra!],
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ illustrations --

/// One tile drawn exactly like the board's tiles.
class _Tile extends StatelessWidget {
  final String glyph;
  final double size;
  final Color? outline;
  final double highlight;
  const _Tile(this.glyph, {this.size = 64, this.outline, this.highlight = 0});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final thick = size * GameConstants.tileThickness;
    return SizedBox(
      width: size,
      height: size * GameConstants.tileAspect + thick,
      child: CustomPaint(
        painter: TileBodyPainter(
          glyph: glyph,
          accent: const Color(0xFFFF7A59),
          thickness: thick,
          layerShadow: 1,
          dimmed: false,
          highlight: highlight,
          highlightColor: AppColors.gold,
          flash: 0,
          outline: outline,
          faceTop: p.tileFaceTop,
          faceBottom: p.tileFaceBottom,
        ),
      ),
    );
  }
}

class _PairArt extends StatelessWidget {
  const _PairArt();
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Tile('🍓', highlight: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.add_rounded,
                size: 30, color: Theme.of(context).colorScheme.primary),
          ),
          const _Tile('🍓', highlight: 1),
          const SizedBox(width: 14),
          const Text('✨', style: TextStyle(fontSize: 34)),
        ],
      );
}

class _FreeBlockedArt extends StatelessWidget {
  final String free;
  final String blocked;
  const _FreeBlockedArt({required this.free, required this.blocked});

  @override
  Widget build(BuildContext context) {
    Widget label(String text, IconData icon, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(text, style: fredoka(15, 700, color)),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          const _Tile('🍋', size: 58),
          const SizedBox(height: 10),
          label(free, Icons.check_circle_rounded, AppColors.success),
        ]),
        Column(mainAxisSize: MainAxisSize.min, children: [
          // A tile partly covered by one on the layer above.
          SizedBox(
            width: 90,
            height: 96,
            child: Stack(children: const [
              Positioned(left: 0, top: 18, child: _Tile('🍇', size: 58)),
              Positioned(left: 29, top: 0, child: _Tile('🥝', size: 58)),
            ]),
          ),
          const SizedBox(height: 10),
          label(blocked, Icons.lock_rounded, AppColors.danger),
        ]),
      ],
    );
  }
}

class _InspectArt extends StatelessWidget {
  const _InspectArt();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        height: 130,
        child: Stack(children: [
          const Positioned(left: 20, top: 30, child: _Tile('🍑', size: 60)),
          const Positioned(
            left: 70,
            top: 8,
            child: _Tile('🍒', size: 60, outline: AppColors.danger),
          ),
          Positioned(
            left: 34,
            top: 70,
            child: Icon(Icons.touch_app_rounded,
                size: 46, color: Theme.of(context).colorScheme.primary),
          ),
        ]),
      );
}

class _BoosterArt extends StatelessWidget {
  const _BoosterArt();
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in BoosterType.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _BoosterIcon(t, size: 58),
            ),
        ],
      );
}

class _BoosterIcon extends StatelessWidget {
  final BoosterType type;
  final double size;
  const _BoosterIcon(this.type, {this.size = 40});

  @override
  Widget build(BuildContext context) {
    final (icon, colors) = BoosterBar.icons[type]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    );
  }
}

class _BoosterList extends StatelessWidget {
  const _BoosterList();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final t in BoosterType.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _BoosterIcon(t),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.booster(t),
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(l.boosterDescription(t),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StarsArt extends StatelessWidget {
  const _StarsArt();
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final s in const [54.0, 72.0, 54.0])
            Padding(
              padding: EdgeInsets.only(bottom: s == 72 ? 18 : 0),
              child: Icon(Icons.star_rounded, size: s, color: AppColors.gold),
            ),
        ],
      );
}
