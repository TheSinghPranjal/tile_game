import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/decor.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../game/presentation/screens/game_screen.dart';
import '../../levels/data/level_repository.dart';
import '../../levels/domain/level_config.dart';
import '../../levels/presentation/level_select_screen.dart';
import '../../progress/data/progress_repository.dart';
import '../../settings/presentation/settings_panel.dart';

/// Garden artwork with the logo and hero tiles baked in. It was extended to a
/// phone aspect (0.46) by lengthening a plain sky band below the logo.
const _bgAsset = 'assets/images/home_bg.jpg';
const _bgSize = Size(992, 2157);

/// Bottom edge of the painted logo (wooden plank + leaves), in image pixels.
const _logoBottom = 662.0;

/// Top edge of the leftmost painted tile (the apple), in image pixels. The
/// star badge must fit above it.
const _firstTileTop = 250.0;

/// Palette sampled from the reference design.
class _C {
  static const plum = Color(0xFF3D1466);
  static const plumSoft = Color(0xFF55307F);
  static const ribbonText = Color(0xFF5B2333);
}

const _fredoka = fredoka;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Warm up the next level in the background.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = ref.read(progressProvider);
      ref
          .read(levelRepositoryProvider)
          .prefetch(p.savedGame?.levelNumber ?? p.highestUnlocked);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_bgAsset), context);
  }

  void _play(int level) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen(level: level)),
      );

  void _openSettings() => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        backgroundColor: AppColors.cream,
        builder: (_) => const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SettingsPanel(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(progressProvider);
    final current = p.savedGame?.levelNumber ?? p.highestUnlocked;
    final tier = DifficultyTier.forLevel(current);
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      body: LayoutBuilder(builder: (context, c) {
        // Same maths as BoxFit.cover + Alignment.topCenter, so overlays can be
        // placed relative to the logo painted inside the artwork.
        final scale = math.max(
          c.maxWidth / _bgSize.width,
          c.maxHeight / _bgSize.height,
        );
        final contentWidth = math.min(c.maxWidth - 36, 440.0);
        final contentTop = math.max(_logoBottom * scale - 2, padding.top + 56);

        return Stack(
          children: [
            const Positioned.fill(
              child: Image(
                image: AssetImage(_bgAsset),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Positioned(
              top: padding.top + 4,
              left: 16,
              child: _StarBadge(
                stars: p.totalStars,
                // Fit the gap between the status bar and the painted tiles.
                height: (_firstTileTop * scale - padding.top - 10)
                    .clamp(30.0, 44.0)
                    .toDouble(),
              ),
            ),
            Positioned(
              top: contentTop,
              left: 0,
              right: 0,
              bottom: padding.bottom + 10,
              child: Align(
                alignment: Alignment.topCenter,
                // Shrinks the whole block uniformly on short screens.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TaglineRibbon(width: contentWidth * 0.9),
                        const SizedBox(height: 22),
                        _PlayButton(
                          label: p.savedGame != null
                              ? 'Continue Level $current'
                              : p.allLevelsCleared
                                  ? 'Replay Level $current'
                                  : 'Play Level $current',
                          sublabel: p.allLevelsCleared && p.savedGame == null
                              ? 'All ${GameConstants.totalLevels} levels cleared!'
                              : 'Level $current of ${GameConstants.totalLevels} • ${tier.displayName}',
                          onTap: () => _play(current),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                            child: _MenuCard(
                              label: 'Levels',
                              style: _MenuStyle.levels,
                              icon: const _GradientIcon(
                                Icons.auto_stories_rounded,
                                [Color(0xFFB86BFF), Color(0xFF7B2FE0)],
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LevelSelectScreen(onPlay: _play),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuCard(
                              label: 'Awards',
                              style: _MenuStyle.awards,
                              icon: const Text('🏆', style: TextStyle(fontSize: 38)),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AchievementsScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MenuCard(
                              label: 'Settings',
                              style: _MenuStyle.settings,
                              icon: const _GradientIcon(
                                Icons.settings_rounded,
                                [Color(0xFF5B9BFF), Color(0xFF2F5FE0)],
                              ),
                              onTap: _openSettings,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 36),
                        const _InfoCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// --------------------------------------------------------------- pieces --

/// Scales down while pressed, for a tactile "button" feel.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.95 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

class _StarBadge extends StatelessWidget {
  final int stars;
  final double height;
  const _StarBadge({required this.stars, required this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: EdgeInsets.fromLTRB(height * 0.18, 0, height * 0.42, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFF3DA)],
          ),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: const Color(0xFFF6D88E), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _GradientIcon(
            Icons.star_rounded,
            const [Color(0xFFFFD84D), Color(0xFFFF9F1C)],
            size: height * 0.72,
          ),
          SizedBox(width: height * 0.15),
          Text('$stars', style: _fredoka(height * 0.48, 700, _C.plum)),
        ]),
      );
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final double size;
  const _GradientIcon(this.icon, this.colors, {this.size = 42});

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(r),
        child: Icon(icon, size: size, color: Colors.white),
      );
}

/// Cream banner with folded tails, like a garden-party ribbon.
class _TaglineRibbon extends StatelessWidget {
  final double width;
  const _TaglineRibbon({required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: 52,
        child: CustomPaint(
          painter: _RibbonPainter(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    'Find the pairs. Clear the grove.',
                    style: _fredoka(19, 600, _C.ribbonText),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const tail = 26.0, drop = 9.0, bend = 5.0, bandTop = 2.0;
    final bandBottom = h - drop - 2;
    final mid = (bandTop + bandBottom) / 2 + drop;

    // Tails (behind the band), each with a V-notch.
    final tailPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF1D3A4), Color(0xFFD9AE74)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(
      Path()
        ..moveTo(tail + 6, bandTop + drop)
        ..lineTo(0, bandTop + drop)
        ..lineTo(tail * 0.55, mid)
        ..lineTo(0, bandBottom + drop)
        ..lineTo(tail + 6, bandBottom + drop)
        ..close(),
      tailPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - tail - 6, bandTop + drop)
        ..lineTo(w, bandTop + drop)
        ..lineTo(w - tail * 0.55, mid)
        ..lineTo(w, bandBottom + drop)
        ..lineTo(w - tail - 6, bandBottom + drop)
        ..close(),
      tailPaint,
    );

    // Fold shadows where the band wraps behind.
    final fold = Paint()..color = const Color(0xFFB98A52);
    canvas.drawPath(
      Path()
        ..moveTo(tail, bandBottom)
        ..lineTo(tail + 6, bandBottom + drop)
        ..lineTo(tail + 6, bandBottom)
        ..close(),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - tail, bandBottom)
        ..lineTo(w - tail - 6, bandBottom + drop)
        ..lineTo(w - tail - 6, bandBottom)
        ..close(),
      fold,
    );

    // Main band, gently bowed.
    final band = Path()
      ..moveTo(tail, bandTop + bend)
      ..quadraticBezierTo(w / 2, bandTop - bend, w - tail, bandTop + bend)
      ..lineTo(w - tail, bandBottom)
      ..quadraticBezierTo(w / 2, bandBottom - bend * 2, tail, bandBottom)
      ..close();
    canvas.drawShadow(band, const Color(0x66000000), 3, false);
    canvas.drawPath(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFAF0), Color(0xFFF7E3C0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      band,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFE2B97F),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glossy golden pill with a white play disc.
class _PlayButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  const _PlayButton(
      {required this.label, required this.sublabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(60));
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1A8), Color(0xFFFFB300)],
          ),
          boxShadow: [
            BoxShadow(color: Color(0xFFE08A00), offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x66FF9800), blurRadius: 22, offset: Offset(0, 10)),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE15A), Color(0xFFFFC21F), Color(0xFFFFA800)],
              stops: [0, 0.55, 1],
            ),
          ),
          child: Stack(
            children: [
              // Top gloss.
              Positioned(
                left: 24,
                right: 24,
                top: 5,
                height: 30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 24, 0),
                child: Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x40B26A00),
                            blurRadius: 8,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: const Center(
                      child: _GradientIcon(
                        Icons.play_arrow_rounded,
                        [Color(0xFFFFB020), Color(0xFFFF7A00)],
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(label, style: _fredoka(31, 700, _C.plum)),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(sublabel,
                              style: _fredoka(17, 600, _C.plumSoft)),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MenuStyle {
  levels(
    [Color(0xFFF6EDFF), Color(0xFFD7BCFF)],
    Color(0xFFB896F5),
    Color(0xFF9A6FE6),
    _C.plum,
  ),
  awards(
    [Color(0xFFFFF8EE), Color(0xFFFFDDB8)],
    Color(0xFFF2C38E),
    Color(0xFFE0A462),
    _C.plum,
  ),
  settings(
    [Color(0xFFEFF5FF), Color(0xFFC5D9FF)],
    Color(0xFF94B6F7),
    Color(0xFF6C93E6),
    Color(0xFF1F2C7A),
  );

  final List<Color> fill;
  final Color border;
  final Color depth;
  final Color text;
  const _MenuStyle(this.fill, this.border, this.depth, this.text);
}

/// Candy-coloured raised card with an icon and label.
class _MenuCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final _MenuStyle style;
  final VoidCallback onTap;

  const _MenuCard({
    required this.label,
    required this.icon,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    return _Pressable(
      onTap: onTap,
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: style.fill,
          ),
          border: Border.all(color: style.border, width: 2.5),
          boxShadow: [
            BoxShadow(color: style.depth, offset: const Offset(0, 5)),
            const BoxShadow(
                color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 9)),
          ],
        ),
        child: Stack(children: [
          Positioned(
            left: 10,
            right: 10,
            top: 5,
            height: 26,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 46, child: Center(child: icon)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: _fredoka(21, 700, style.text)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// How-to-play card with an "i" badge and a leaf flourish.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBF4), Color(0xFFFCEBDD)],
            ),
            border: Border.all(color: const Color(0xFFE4B2EC), width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Text(
            'Tap two identical FREE tiles to clear them. A tile is free when '
            'nothing sits on top of it and its left or right side is open. '
            'Long-press any tile to see what is blocking it.',
            textAlign: TextAlign.center,
            style: _fredoka(16, 500, _C.plum, height: 1.4),
          ),
        ),
        // Inner hairline for the double-border look.
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9), width: 1.5),
              ),
            ),
          ),
        ),
        Positioned(
          top: -18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFC06BFF), Color(0xFF7A2BD6)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Center(
                child:
                    Text('i', style: _fredoka(19, 700, Colors.white, height: 1)),
              ),
            ),
          ),
        ),
        const Positioned(
          top: -16,
          right: -8,
          child: SizedBox(
            width: 48,
            height: 40,
            child: CustomPaint(painter: LeavesPainter()),
          ),
        ),
      ],
    );
  }
}
