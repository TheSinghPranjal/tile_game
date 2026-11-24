import 'package:flutter_test/flutter_test.dart';
import 'package:tile_game/core/utils/seeded_random.dart';
import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/game/domain/entities/board_state.dart';
import 'package:tile_game/features/game/domain/services/game_engine.dart';
import 'package:tile_game/features/game/domain/services/game_session.dart';
import 'package:tile_game/features/game/domain/services/hint_service.dart';
import 'package:tile_game/features/game/domain/services/shuffle_service.dart';
import 'package:tile_game/features/game/domain/services/tile_availability_service.dart';
import 'package:tile_game/features/game/domain/solvers/level_solver.dart';
import 'package:tile_game/features/game/domain/validators/geometry_validator.dart';
import 'package:tile_game/features/game/domain/validators/level_validator.dart';

import 'test_helpers.dart';

void main() {
  group('Tile availability', () {
    test('1. a top tile covering a lower tile prevents lower selection', () {
      final s = board([(0, 0, 0, 1), (1, 0, 0, 2)]);
      expect(s.isSelectable(0), isFalse);
      expect(s.isSelectable(1), isTrue);
    });

    test('1b. a half-offset top tile also covers the tiles beneath it', () {
      // Two lower tiles side by side, one upper tile straddling both.
      final s = board([(0, 0, 0, 1), (0, 1, 0, 1), (1, 0.5, 0, 2)]);
      expect(s.isSelectable(0), isFalse);
      expect(s.isSelectable(1), isFalse);
      expect(s.isSelectable(2), isTrue);
    });

    test('1c. a sliver overlap under the threshold does not cover', () {
      final s = board([(0, 0, 0, 1), (1, 0.95, 0, 2)]);
      expect(s.isSelectable(0), isTrue);
    });

    test('2. removing the top tile recalculates lower-tile availability', () {
      final s = board([(0, 0, 0, 1), (1, 0, 0, 2)]);
      final after = s.withRemoved([1]);
      expect(after.isSelectable(0), isTrue);

      // Incremental update agrees with full recomputation.
      final inc = TileAvailabilityService.updateSelectable(
        s.geometry,
        after.removed,
        s.selectableTiles.toSet(),
        [1],
      );
      expect(inc, after.selectableTiles.toSet());
    });

    test('3. default rules: an uncovered tile flanked on both sides is free',
        () {
      // Regression: a tile with nothing on top must be tappable even when
      // same-layer neighbours touch both of its sides.
      final s = board([(0, 0, 0, 1), (0, 1, 0, 2), (0, 2, 0, 1)]);
      expect(s.isSelectable(1), isTrue);
    });

    test('3a. default rules: lower tile free once its own cover is gone', () {
      // Upper tile 3 covers 0 only; tile 1 (between 0 and 2) is uncovered.
      final s = board([
        (0, 0, 0, 1),
        (0, 1, 0, 2),
        (0, 2, 0, 1),
        (1, -0.5, 0, 2),
      ]);
      expect(s.isSelectable(0), isFalse);
      expect(s.isSelectable(1), isTrue);
      expect(s.isSelectable(3), isTrue);
    });

    test('3c. classic rules: tile blocked on both sides cannot be selected',
        () {
      final s = board([(0, 0, 0, 1), (0, 1, 0, 2), (0, 2, 0, 1)],
          config: AvailabilityConfig.classic);
      expect(s.isSelectable(1), isFalse);
      expect(TileAvailabilityService.isLeftOpen(s.geometry, s.removed, 1),
          isFalse);
      expect(TileAvailabilityService.isRightOpen(s.geometry, s.removed, 1),
          isFalse);
    });

    test('3b. classic rules: staggered neighbours still block sides', () {
      // Middle tile at y=0.5 touches left tile at y=0 and right tile at y=1.
      final s = board([(0, 0, 0, 1), (0, 1, 0.5, 2), (0, 2, 1, 1)],
          config: AvailabilityConfig.classic);
      expect(s.isSelectable(1), isFalse);
    });

    test('4. a tile with one open side is selectable when not covered', () {
      final s = board([(0, 0, 0, 1), (0, 1, 0, 2), (0, 2, 0, 1)],
          config: AvailabilityConfig.classic);
      expect(s.isSelectable(0), isTrue);
      expect(s.isSelectable(2), isTrue);
      // Opening the right side frees the middle tile.
      expect(s.withRemoved([2]).isSelectable(1), isTrue);
    });

    test('tiles in different rows do not side-block each other', () {
      final s = board([(0, 0, 0, 1), (0, 1, 1, 1), (0, 2, 0, 2), (0, 1, 0, 2)],
          config: AvailabilityConfig.classic);
      // Tile 3 at (1,0) is between 0 and 2 on row 0 → blocked.
      expect(s.isSelectable(3), isFalse);
      // Tile 1 is alone on row 1.
      expect(s.isSelectable(1), isTrue);
    });

    test('visible-but-blocked tiles are not selectable', () {
      final s = board([(0, 0, 0, 1), (0, 1, 0, 1), (1, 0.5, 0, 2)]);
      expect(
          TileAvailabilityService.isVisible(s.geometry, s.removed, 0), isTrue);
      expect(s.isSelectable(0), isFalse);
    });
  });

  group('Matching', () {
    test('5. two identical selectable tiles are removed', () {
      final s = board([(0, 0, 0, 7), (0, 3, 0, 7)]);
      final r = GameEngine.tryMatch(s, 0, 1);
      expect(r.type, MatchResultType.matched);
      expect(r.state.isCleared, isTrue);
    });

    test('6. two different tiles are not removed', () {
      final s = board([(0, 0, 0, 7), (0, 3, 0, 8)]);
      final r = GameEngine.tryMatch(s, 0, 1);
      expect(r.type, MatchResultType.mismatch);
      expect(r.state.remainingCount, 2);
    });

    test('blocked identical tiles are not removed', () {
      final s = board([(0, 0, 0, 7), (1, 0, 0, 8), (0, 3, 0, 7), (0, 5, 0, 8)]);
      expect(GameEngine.tryMatch(s, 0, 2).type, MatchResultType.invalid);
    });

    test('7. a tile cannot be selected again after removal', () {
      final s = board([(0, 0, 0, 7), (0, 3, 0, 7), (0, 6, 0, 7), (0, 9, 0, 7)]);
      final after = GameEngine.tryMatch(s, 0, 1).state;
      expect(GameEngine.canSelect(after, 0), isFalse);
      expect(GameEngine.tryMatch(after, 0, 2).type, MatchResultType.invalid);
      expect(GameEngine.tryMatch(after, 2, 3).type, MatchResultType.matched);
    });

    test('a tile cannot be matched with itself', () {
      final s = board([(0, 0, 0, 7), (0, 3, 0, 7)]);
      expect(GameEngine.tryMatch(s, 0, 0).type, MatchResultType.invalid);
    });
  });

  group('Undo', () {
    test('8. undo restores both tiles and their availability relationships',
        () {
      // Upper pair covers lower pair.
      final s = board([(0, 0, 0, 1), (1, 0, 0, 2), (0, 3, 0, 1), (1, 3, 0, 2)]);
      final session = GameSession(board: s);
      final beforeSel = s.selectableTiles;
      final (r, after) = session.match(1, 3);
      expect(r.isMatch, isTrue);
      expect(after.board.isSelectable(0), isTrue);

      final undone = after.undo()!;
      expect(undone.board.removed, s.removed);
      expect(undone.board.symbols, s.symbols);
      expect(undone.board.selectableTiles, beforeSel);
      expect(undone.board.isSelectable(0), isFalse);
      expect(undone.matches, 0);
      expect(undone.canUndo, isFalse);
    });

    test('undo after shuffle restores the pre-shuffle symbols', () {
      final level = const LevelGenerator().generateLevel(12);
      final session = GameSession(board: level.initialState);
      final shuffled = const ShuffleService()
          .shuffle(session.board, SeededRandom(3))!;
      final s2 = session.shuffled(shuffled);
      expect(s2.undo()!.board.symbols, level.symbols);
    });
  });

  group('Shuffle', () {
    final level = const LevelGenerator().generateLevel(40);

    BoardState midGame() {
      var s = level.initialState;
      for (final p in level.certificate.solution.take(8)) {
        s = s.withRemoved(p.both);
      }
      return s;
    }

    test('9. shuffle keeps every symbol count even and the multiset intact',
        () {
      final s = midGame();
      for (var seed = 0; seed < 20; seed++) {
        final shuffled = const ShuffleService().shuffle(s, SeededRandom(seed))!;
        final counts = shuffled.remainingSymbolCounts();
        expect(counts.values.every((c) => c.isEven), isTrue);
        expect(counts, s.remainingSymbolCounts());
        expect(shuffled.removed, s.removed);
        expect(identical(shuffled.geometry, s.geometry), isTrue);
      }
    });

    test('10. shuffle produces a solvable board', () {
      final s = midGame();
      for (var seed = 0; seed < 20; seed++) {
        final shuffled = const ShuffleService().shuffle(s, SeededRandom(seed))!;
        expect(const LevelSolver().solve(shuffled).isSolved, isTrue);
      }
    });

    test('shuffle refuses geometry that no deal can clear', () {
      // Only two stacked tiles remain: impossible regardless of symbols.
      final s = board([(0, 0, 0, 1), (1, 0, 0, 1)]);
      expect(const ShuffleService().shuffle(s, SeededRandom(1)), isNull);
    });
  });

  group('Generator', () {
    const gen = LevelGenerator();
    final levels = [
      for (final n in [1, 2, 5, 10, 11, 20, 26, 35, 51, 75, 101, 150, 201, 260])
        gen.generateLevel(n),
    ];

    test('11. every generated level has at least one complete solution', () {
      for (final l in levels) {
        final r = const LevelSolver(nodeBudget: 500000).solve(l.initialState);
        expect(r.isSolved, isTrue, reason: 'level ${l.levelNumber}');
        expect(GeometryValidator.validate(l.geometry), isEmpty);
      }
    });

    test('12. the certificate removes every tile exactly once', () {
      for (final l in levels) {
        final removed = <int>{};
        for (final p in l.certificate.solution) {
          expect(removed.add(p.a), isTrue);
          expect(removed.add(p.b), isTrue);
        }
        expect(removed.length, l.geometry.length);
        final report = LevelValidator.validate(
            l.geometry, l.symbols, l.certificate.solution);
        expect(report.isValid, isTrue, reason: report.toString());
      }
    });

    test('13. every covered tile eventually becomes selectable', () {
      for (final l in levels) {
        var s = l.initialState;
        final everSelectable = <int>{...s.selectableTiles};
        for (final p in l.certificate.solution) {
          s = s.withRemoved(p.both);
          everSelectable.addAll(s.selectableTiles);
        }
        for (var i = 0; i < l.geometry.length; i++) {
          if (l.geometry.coveredBy[i].isNotEmpty) {
            expect(everSelectable.contains(i), isTrue,
                reason: 'level ${l.levelNumber} tile $i');
          }
        }
      }
    });

    test('generation is deterministic', () {
      final a = gen.generateLevel(77);
      final b = gen.generateLevel(77);
      expect(a.symbols, b.symbols);
      expect(a.geometry.toJson(), b.geometry.toJson());
    });
  });

  group('Solver', () {
    test('14. the solver identifies an unsolvable board', () {
      // Two stacks with crossed symbols: tops differ, so no first move.
      final crossed = board([(0, 0, 0, 1), (1, 0, 0, 2), (0, 3, 0, 2), (1, 3, 0, 1)]);
      expect(const LevelSolver().solve(crossed).status, SolveStatus.unsolvable);

      // A tile stacked on its own partner can never be matched.
      final self = board([(0, 0, 0, 5), (1, 0, 0, 5), (0, 3, 0, 6), (0, 5, 0, 6)]);
      expect(const LevelSolver().solve(self).status, SolveStatus.unsolvable);

      // Odd symbol counts.
      final odd = board([(0, 0, 0, 1), (0, 3, 0, 1), (0, 6, 0, 1), (0, 9, 0, 2)]);
      expect(const LevelSolver().solve(odd).status, SolveStatus.unsolvable);
    });

    test('15. the solver handles multiple valid removal sequences', () {
      // Four copies of one symbol and two of another, all free.
      final s = board([
        (0, 0, 0, 1), (0, 3, 0, 1), (0, 6, 0, 1), (0, 9, 0, 1),
        (0, 0, 3, 2), (0, 3, 3, 2),
      ]);
      final r = const LevelSolver().solve(s);
      expect(r.isSolved, isTrue);
      var replay = s;
      for (final p in r.solution) {
        final m = GameEngine.tryMatch(replay, p.a, p.b);
        expect(m.isMatch, isTrue);
        replay = m.state;
      }
      expect(replay.isCleared, isTrue);

      // Several distinct first moves keep the board solvable.
      final viable = GameEngine.matchingPairs(s)
          .where((p) => const LevelSolver().solve(s.withRemoved(p.both)).isSolved)
          .length;
      expect(viable, greaterThan(1));
    });

    test('the solver avoids a trap that a greedy player falls into', () {
      // Symbol 1 has four copies (t0, t1, t4, t5); three are free.
      // Matching t0+t5 strands t2/t4 (different symbols, nothing else free);
      // only t0+t4 (or t4+t5) unlocks the stacks.
      final s = board([
        (0, 0, 0, 1), // t0 free
        (0, 3, 0, 1), // t1 under t2
        (1, 3, 0, 2), // t2
        (0, 6, 0, 2), // t3 under t4
        (1, 6, 0, 1), // t4
        (0, 9, 0, 1), // t5 free
      ]);
      final trap = s.withRemoved([0, 5]);
      expect(GameEngine.matchingPairs(trap), isEmpty);
      expect(const LevelSolver().solve(trap).status, SolveStatus.unsolvable);

      final r = const LevelSolver().solve(s);
      expect(r.isSolved, isTrue);
      expect(r.solution.first, isNot(TilePair(0, 5)));

      // The hint must not suggest the trap either.
      final h = const HintService().findHint(s);
      expect(h.status, HintStatus.safe);
      expect(h.pair, isNot(TilePair(0, 5)));
    });
  });

  group('Hints', () {
    test('hints are always two selectable identical tiles', () {
      final level = const LevelGenerator().generateLevel(60);
      var s = level.initialState;
      for (var step = 0; step < 20 && !s.isCleared; step++) {
        final h = const HintService().findHint(s);
        expect(h.pair, isNotNull);
        final p = h.pair!;
        expect(s.isSelectable(p.a), isTrue);
        expect(s.isSelectable(p.b), isTrue);
        expect(s.symbols[p.a], s.symbols[p.b]);
        expect(h.status, isNot(HintStatus.deadEnd));
        s = s.withRemoved(p.both);
      }
    });

    test('following hints clears a level', () {
      final level = const LevelGenerator().generateLevel(30);
      var s = level.initialState;
      while (!s.isCleared) {
        final h = const HintService().findHint(s);
        expect(h.status, HintStatus.safe);
        s = s.withRemoved(h.pair!.both);
      }
    });

    test('hint reports dead ends and no-move states', () {
      final crossed = board([(0, 0, 0, 1), (1, 0, 0, 2), (0, 3, 0, 2), (1, 3, 0, 1)]);
      expect(const HintService().findHint(crossed).status, HintStatus.noMoves);
    });
  });
}
