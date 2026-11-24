import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/domain/game_settings.dart';
import '../../domain/entities/board_geometry.dart';
import '../../domain/entities/tile_symbol.dart';
import '../animations/particle_burst.dart';
import '../controllers/game_controller.dart';
import '../controllers/game_view_state.dart';
import 'board_layout.dart';
import 'tile_widget.dart';

/// Renders every tile as an independent object in deterministic paint order
/// and routes taps through [BoardLayout.hitTest] (topmost tile wins).
class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key});

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BurstData {
  final int id;
  final Offset center;
  final Color color;
  final double size;
  const _BurstData(this.id, this.center, this.color, this.size);
}

class _BoardViewState extends ConsumerState<BoardView>
    with SingleTickerProviderStateMixin {
  final _shakeNonce = <int, int>{};
  final _strongShake = <int, bool>{};
  final _revealNonce = <int, int>{};
  final _bursts = <_BurstData>[];
  final _transform = TransformationController();

  /// Drives the deal-in animation when a new board appears.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: 1,
  );
  int _burstId = 0;
  BoardLayout? _layout;
  (BoardGeometry, Size)? _layoutKey;

  @override
  void dispose() {
    _transform.dispose();
    _intro.dispose();
    super.dispose();
  }

  BoardLayout _layoutFor(BoardGeometry g, Size size) {
    if (_layoutKey == null ||
        !identical(_layoutKey!.$1, g) ||
        _layoutKey!.$2 != size) {
      final newBoard = _layoutKey == null || !identical(_layoutKey!.$1, g);
      if (newBoard && !ref.read(settingsProvider).reduceMotion) {
        _intro.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _intro.forward(from: 0);
        });
      }
      _layout = BoardLayout.fit(g, size);
      _layoutKey = (g, size);
      // Reset zoom for the new board after this frame (not during build).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _transform.value = Matrix4.identity();
      });
    }
    return _layout!;
  }

  void _onEvent(FeedbackEvent? e, GameViewState s) {
    if (e == null || !mounted) return;
    setState(() {
      switch (e.kind) {
        case FeedbackKind.mismatch:
        case FeedbackKind.blocked:
          for (final t in e.tiles) {
            _shakeNonce[t] = (_shakeNonce[t] ?? 0) + 1;
            _strongShake[t] = e.kind == FeedbackKind.mismatch;
          }
        case FeedbackKind.match:
        case FeedbackKind.magic:
          final layout = _layout;
          if (layout == null || ref.read(settingsProvider).reduceMotion) break;
          for (final t in e.tiles) {
            final r = layout.tileRect(t);
            final sym = TileCatalog.byId(s.board!.symbols[t]);
            _bursts.add(
              _BurstData(
                _burstId++,
                r.center,
                e.kind == FeedbackKind.magic
                    ? AppColors.gold
                    : Color(sym.accent),
                r.width,
              ),
            );
          }
        case FeedbackKind.shuffle:
        case FeedbackKind.undo:
          for (final t in e.tiles) {
            _revealNonce[t] = (_revealNonce[t] ?? 0) + 1;
          }
        case FeedbackKind.select:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FeedbackEvent?>(
      gameControllerProvider.select((s) => s.event),
      (_, e) => _onEvent(e, ref.read(gameControllerProvider)),
    );
    final s = ref.watch(gameControllerProvider);
    final settings = ref.watch(settingsProvider);
    final board = s.board;
    if (board == null) return const SizedBox.shrink();
    final g = board.geometry;
    final controller = ref.read(gameControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layoutFor(g, constraints.biggest);
        final selectable = board.selectableTiles.toSet();
        final gap = GameConstants.tileGap * layout.unitW;
        final thick = GameConstants.tileThickness * layout.unitW;
        final blockers = s.blockers.toSet();
        final hint = s.hint;

        final children = <Widget>[];
        final rows = (g.maxY - g.minY).abs() + 1;
        for (final i in g.zOrder) {
          final face = layout.tileRect(i).deflate(gap);
          final symbol = TileCatalog.byId(board.symbols[i]);
          final t = g.tiles[i];
          // Lower layers land first, then each layer sweeps top to bottom.
          final delay = (t.layer * 0.1 + (t.y - g.minY) / rows * 0.3)
              .clamp(0.0, 0.6)
              .toDouble();
          children.add(
            Positioned(
              key: ValueKey('tile-$i'),
              left: face.left,
              top: face.top,
              width: face.width + thick * GameConstants.tileSideRatio,
              height: face.height + thick,
              child: _DealIn(
                animation: _intro,
                delay: delay,
                lift: layout.unitW * 0.6,
                child: TileWidget(
                  symbol: symbol,
                  layer: g.tiles[i].layer,
                  removed: board.isRemoved(i),
                  selectable: selectable.contains(i),
                  selected: s.selected == i,
                  hinted: hint != null && hint.contains(i),
                  dimBlocked: settings.dimBlockedTiles,
                  inspected: s.inspected == i,
                  isBlocker: blockers.contains(i),
                  shakeNonce: _shakeNonce[i] ?? 0,
                  strongShake: _strongShake[i] ?? false,
                  revealNonce: _revealNonce[i] ?? 0,
                  reduceMotion: settings.reduceMotion,
                  thickness: thick,
                ),
              ),
            ),
          );
        }
        for (final b in _bursts) {
          children.add(
            ParticleBurst(
              key: ValueKey('burst-${b.id}'),
              center: b.center,
              color: b.color,
              size: b.size,
              seed: b.id,
              onDone: () {
                if (mounted) {
                  setState(() => _bursts.removeWhere((x) => x.id == b.id));
                }
              },
            ),
          );
        }

        final content = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final i = layout.hitTest(d.localPosition, board.removed);
            if (i != null) controller.tapTile(i);
          },
          onLongPressStart: (d) {
            final i = layout.hitTest(d.localPosition, board.removed);
            if (i != null) controller.inspect(i);
          },
          child: SizedBox(
            width: layout.contentSize.width,
            height: layout.contentSize.height,
            child: Stack(clipBehavior: Clip.none, children: children),
          ),
        );

        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          minScale: layout.overflows
              ? (constraints.maxWidth / layout.contentSize.width)
                    .clamp(0.4, 1.0)
                    .toDouble()
              : 1,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(40),
          child: content,
        );
      },
    );
  }
}

/// Fades a tile in while it drops onto the board.
class _DealIn extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final double lift;
  final Widget child;

  const _DealIn({
    required this.animation,
    required this.delay,
    required this.lift,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final v = ((animation.value - delay) / 0.4).clamp(0.0, 1.0);
      if (v >= 1) return child!;
      final e = Curves.easeOutBack.transform(v);
      return Opacity(
        opacity: Curves.easeOut.transform(v),
        child: Transform.translate(
          offset: Offset(0, -lift * (1 - e)),
          child: child,
        ),
      );
    },
  );
}
