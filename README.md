# Tile Grove

A layered **two-tile** matching puzzle game for Android and iOS, built with Flutter and Riverpod.
Tap two identical **free** tiles to clear them. Every board is generated procedurally and
**proven solvable** before you see it.

A tile is *free* when:

1. no remaining tile on a higher layer overlaps it (rectangle geometry, configurable
   threshold), **and**
2. its left **or** right side has no remaining same-layer neighbour.

## Running

```bash
flutter pub get
flutter run                                  # normal start
flutter run --dart-define=START_LEVEL=42     # debug: jump straight into a level
```

## Tests and validation

```bash
flutter test                                  # engine and widget tests (fast)
flutter test test/batch --run-skipped --tags batch          # 10,000-board batch (~10 min)
BATCH_COUNT=500 flutter test test/batch --run-skipped --tags batch
dart run tool/difficulty_report.dart 1 300   # print the difficulty curve for rebalancing
```

The batch run writes `build/batch_summary.json`. Any failing board is written in full,
with its certificate, to `build/batch_failures/board_<n>.json` so it can be reproduced.
Generation is deterministic: the same level number always produces the same board.

**Last batch result:** 10,000 boards, 0 failures, 780,872 tiles, all 16 templates at the time × 6 tiers.

## How solvability is guaranteed

`LevelGenerator` (`lib/features/game/domain/algorithms/level_generator.dart`):

1. **Geometry** comes from one of 17 parametric templates (`LayoutTemplate`). Upper layers
   are placed only where the layer below fully supports them. This works for aligned,
   staggered and half-offset grids.
2. **Geometry validation** (`GeometryValidator`): unique IDs, valid coordinates, no
   same-layer collisions, cover relations that only point upward (so there are no cycles),
   and at least two tiles free at the start.
3. **Removal sequence** (`RemovalSequenceGenerator`): a backtracking search over tile
   *positions* only. It uses the real availability rules and repeatedly removes two
   currently free positions until the board is empty.
4. **Symbol assignment** (`SymbolAssigner`): both tiles of each sequence pair get the same
   symbol, so the sequence is a valid solution by construction. No symbol appears more than
   4 times.
5. **Independent verification** (`LevelSolver`): a DFS solver with memoised failed states
   (bitsets), safe-move pruning and randomised restarts. It sees only geometry and symbols
   and must find its own solution.
6. **Certificate replay** (`LevelValidator`): every pair is replayed through `GameEngine`,
   and the check confirms each covered tile's blockers are removed first.
7. **Difficulty analysis** (`DifficultyAnalyzer`): initial pairs, dependency depth, forced
   moves, average alternatives, solver effort, and the success rate of random-play
   playouts. Early tiers reject boards that random play can get stuck on.
8. **Certificate** (`LevelCertificate`): stored for debugging and tests. It is never shown
   to the player.

**Shuffle** re-deals only the remaining symbols. It does this with a new removal sequence
over the remaining positions, then runs the solver again. It never returns an unsolvable
board. If no deal can work (for example, two stacked tiles left), it says so and suggests
Undo.

**Hints** only suggest selectable identical pairs. The solver ranks them so a hint never
leads into a dead end, and the hint service reports when no winning move remains.

## Architecture

```
lib/
  core/            constants, theme, storage provider, utils (BitSet, SeededRandom)
  features/
    game/
      domain/      pure Dart, no Flutter imports, runs in isolates and tools
        entities/      TilePosition, BoardGeometry (cached relations), BoardState, TileSymbol
        services/      TileAvailabilityService, GameEngine, GameSession (undo), Hint, Shuffle
        algorithms/    LevelGenerator, RemovalSequenceGenerator, SymbolAssigner
        solvers/       LevelSolver
        validators/    GeometryValidator, LevelValidator
        models/        LevelCertificate, DifficultyReport
      presentation/
        controllers/   GameController (Riverpod Notifier), GameViewState (game phases)
        widgets/       BoardLayout (board↔screen + hit-testing), BoardView, TileWidget, painter, HUD
        animations/    ParticleBurst
        screens/       GameScreen
    levels/        layout templates, progression curve (LevelConfig), repository (isolate + cache)
    boosters/ progress/ settings/ achievements/ home/
  shared/widgets/
```

Rendering and hit-testing both go through `BoardLayout`, so the tile you see is the tile you
tap. The topmost tile under the finger wins, and layer depth offsets are applied the same
way in both. Availability is always derived from the current removal bitset and is never
stored as a flag.

## Art

Tile faces use the platform's colour emoji. This gives a large, consistent, high-resolution
set with 92 symbols across 7 themes, and needs no asset pipeline. Matching compares only
stable `TileSymbol.id`s, and all drawing is isolated in `TileBodyPainter`. To use bespoke
illustrations, change the painter to draw an image per symbol ID; no game logic changes.
