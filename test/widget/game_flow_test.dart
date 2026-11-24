import 'package:tile_game/core/audio/game_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tile_game/core/storage.dart';
import 'package:tile_game/features/boosters/domain/booster.dart';
import 'package:tile_game/features/game/presentation/controllers/game_controller.dart';
import 'package:tile_game/features/game/presentation/controllers/game_view_state.dart';
import 'package:tile_game/features/game/presentation/widgets/board_layout.dart';
import 'package:tile_game/features/levels/data/level_repository.dart';
import 'package:tile_game/features/progress/data/progress_repository.dart';
import 'package:tile_game/main.dart';

Future<ProviderContainer> _launch(WidgetTester tester,
    {Map<String, Object> prefs = const {}}) async {
  // The How to play guide is covered by its own test.
  SharedPreferences.setMockInitialValues(
      {'settings.seenTutorial': true, ...prefs});
  final sp = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(400, 860));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      gameAudioProvider.overrideWithValue(const SilentAudio()),
      levelRepositoryProvider.overrideWithValue(LevelRepository(inline: true)),
      backgroundRunnerProvider.overrideWithValue(
          <Q, R>(ComputeCallback<Q, R> cb, Q msg) async => cb(msg)),
    ],
    child: const TileGroveApp(),
  ));
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(TileGroveApp)));
}

Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Taps tile [i] where it is actually drawn on screen.
Future<void> _tapTile(WidgetTester tester, ProviderContainer c, int i) async {
  final s = c.read(gameControllerProvider);
  final viewer = find.byType(InteractiveViewer);
  final layout =
      BoardLayout.fit(s.board!.geometry, tester.getSize(viewer));
  final pos = tester.getTopLeft(viewer) + layout.tileRect(i).center;
  await tester.tapAt(pos);
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  testWidgets('plays level 1 to completion with real taps', (tester) async {
    final c = await _launch(tester);
    expect(find.text('Play Level 1'), findsOneWidget);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);

    final s = c.read(gameControllerProvider);
    expect(s.board, isNotNull);
    final solution = s.level!.certificate.solution;

    final board = s.board!;
    final viewer = find.byType(InteractiveViewer);
    final layout = BoardLayout.fit(board.geometry, tester.getSize(viewer));
    final origin = tester.getTopLeft(viewer);

    // Level 1 is stacked: a covered tile is hidden under the tile on top, and
    // tapping there picks the top tile (topmost wins), never the covered one.
    final covered = [
      for (var i = 0; i < board.length; i++)
        if (board.geometry.coveredBy[i].isNotEmpty) i,
    ];
    expect(covered, isNotEmpty);
    final under = covered.first;
    final top = board.geometry.coveredBy[under].first;
    final overlap =
        layout.tileRect(under).intersect(layout.tileRect(top)).center;
    final hit = layout.hitTest(overlap, board.removed)!;
    expect(hit, isNot(under));
    expect(board.geometry.tiles[hit].layer,
        greaterThan(board.geometry.tiles[under].layer));

    // Tapping the visible sliver of a blocked tile does not select it.
    Offset? sliver;
    int? blockedTile;
    for (final i in covered) {
      final r = layout.tileRect(i);
      for (final f in const [
        Offset(0.08, 0.08), Offset(0.92, 0.08),
        Offset(0.08, 0.92), Offset(0.92, 0.92),
      ]) {
        final p = Offset(r.left + r.width * f.dx, r.top + r.height * f.dy);
        if (layout.hitTest(p, board.removed) == i) {
          sliver = p;
          blockedTile = i;
          break;
        }
      }
      if (sliver != null) break;
    }
    if (sliver != null) {
      expect(board.isSelectable(blockedTile!), isFalse);
      await tester.tapAt(origin + sliver);
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.read(gameControllerProvider).selected, isNull);
    }

    for (final p in solution) {
      await _tapTile(tester, c, p.a);
      expect(c.read(gameControllerProvider).selected, p.a);
      await _tapTile(tester, c, p.b);
      expect(c.read(gameControllerProvider).board!.isRemoved(p.a), isTrue);
      await _pumpFor(tester, 350);
    }

    await _pumpFor(tester, 1500);
    expect(c.read(gameControllerProvider).phase, GamePhase.completed);
    expect(find.text('Board Cleared!'), findsOneWidget);
    expect(c.read(progressProvider).highestUnlocked, 2);
    // No assist boosters used: full rating.
    expect(c.read(progressProvider).stars[1], 3);

    // Tear down to stop timers.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('mismatch keeps tiles; undo restores a pair; progress persists',
      (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    final s = c.read(gameControllerProvider);
    final board = s.board!;
    final free = board.selectableTiles;
    // Find two free tiles with different symbols.
    int? a, b;
    outer:
    for (final x in free) {
      for (final y in free) {
        if (board.symbols[x] != board.symbols[y]) {
          a = x;
          b = y;
          break outer;
        }
      }
    }
    if (a != null && b != null) {
      await _tapTile(tester, c, a);
      await _tapTile(tester, c, b);
      final after = c.read(gameControllerProvider);
      expect(after.board!.remainingCount, board.length);
      expect(after.selected, b); // selection moves to the new tile
      await _tapTile(tester, c, b); // deselect
    }

    final p = s.level!.certificate.solution.first;
    await _tapTile(tester, c, p.a);
    await _tapTile(tester, c, p.b);
    await _pumpFor(tester, 400);
    expect(c.read(gameControllerProvider).board!.remainingCount, board.length - 2);

    // Unfinished board is saved.
    final saved = c.read(progressProvider).savedGame!;
    expect(saved.removed.toSet(), {p.a, p.b});

    await tester.tap(find.text('Undo'));
    await _pumpFor(tester, 400);
    final undone = c.read(gameControllerProvider).board!;
    expect(undone.remainingCount, board.length);
    expect(undone.selectableTiles, board.selectableTiles);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('debug Auto button visibly solves the level', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    // Tests run in debug mode, so the debug-only button is present.
    expect(kDebugMode, isTrue);
    final auto = find.byKey(const ValueKey('debug-autoplay'));
    expect(auto, findsOneWidget);
    final pairs = c.read(gameControllerProvider).board!.length ~/ 2;

    await tester.tap(auto);
    await tester.pump();
    expect(c.read(gameControllerProvider).autoPlaying, isTrue);
    expect(find.text('Stop'), findsOneWidget);

    // It selects tiles one at a time, like a player would.
    var sawSelection = false;
    for (var t = 0; t < pairs * 1200 + 2000; t += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      if (c.read(gameControllerProvider).selected != null) sawSelection = true;
      if (c.read(gameControllerProvider).phase == GamePhase.completed) break;
    }
    expect(sawSelection, isTrue);
    expect(c.read(gameControllerProvider).phase, GamePhase.completed);
    expect(c.read(gameControllerProvider).autoPlaying, isFalse);

    await _pumpFor(tester, 1500); // let the auto-play loop wind down
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hint highlights a legal pair', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    await c.read(gameControllerProvider.notifier).useHint();
    await tester.pump();
    final s = c.read(gameControllerProvider);
    expect(s.hint, isNotNull);
    expect(s.board!.isSelectable(s.hint!.a), isTrue);
    expect(s.board!.isSelectable(s.hint!.b), isTrue);
    expect(s.board!.symbols[s.hint!.a], s.board!.symbols[s.hint!.b]);
    await _pumpFor(tester, 3000);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('magic match removes a tile with its free twin', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    final ctrl = c.read(gameControllerProvider.notifier);
    final before = c.read(gameControllerProvider).board!;
    final p = c.read(gameControllerProvider).level!.certificate.solution.first;
    ctrl.armMagic();
    expect(c.read(gameControllerProvider).magicArmed, isTrue);
    await _tapTile(tester, c, p.a);
    await _pumpFor(tester, 400);
    final after = c.read(gameControllerProvider).board!;
    expect(after.remainingCount, before.remainingCount - 2);
    expect(after.isRemoved(p.a), isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shuffle re-deals symbols but keeps geometry', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    final before = c.read(gameControllerProvider).board!;
    await c.read(gameControllerProvider.notifier).shuffle();
    await _pumpFor(tester, 800);
    final after = c.read(gameControllerProvider).board!;
    expect(identical(after.geometry, before.geometry), isTrue);
    expect(after.remainingSymbolCounts(), before.remainingSymbolCounts());
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('boosters are enabled once the board is playable', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    final s = c.read(gameControllerProvider);
    expect(s.isInteractive, isTrue);
    final hint = tester.widget<AnimatedOpacity>(find.ancestor(
        of: find.text('Hint'), matching: find.byType(AnimatedOpacity)).first);
    expect(hint.opacity, 1.0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('backgrounding auto-pauses and returning resumes', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(c.read(gameControllerProvider).phase, GamePhase.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(c.read(gameControllerProvider).isInteractive, isTrue);

    // A pause chosen by the player is not undone by app resume.
    c.read(gameControllerProvider.notifier).pause();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(c.read(gameControllerProvider).phase, GamePhase.paused);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('boosters are a per-level allowance that refills', (tester) async {
    final c = await _launch(tester);
    await tester.tap(find.text('Play Level 1'));
    await _pumpFor(tester, 900);
    final ctrl = c.read(gameControllerProvider.notifier);
    for (var k = 0; k < BoosterType.hint.perLevel; k++) {
      expect(await ctrl.useHint(), BoosterOutcome.used);
      await _pumpFor(tester, 3000); // let the hint expire
    }
    expect(c.read(gameControllerProvider).remaining(BoosterType.hint), 0);
    expect(await ctrl.useHint(), BoosterOutcome.exhausted);

    // A free shuffle (offered when no moves remain) never uses the allowance.
    await ctrl.shuffle(free: true);
    await _pumpFor(tester, 800);
    expect(c.read(gameControllerProvider).remaining(BoosterType.shuffle),
        BoosterType.shuffle.perLevel);

    await ctrl.start(2);
    await _pumpFor(tester, 900);
    expect(c.read(gameControllerProvider).remaining(BoosterType.hint),
        BoosterType.hint.perLevel);
    await tester.pumpWidget(const SizedBox());
  });
}
