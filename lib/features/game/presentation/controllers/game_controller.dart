import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/utils/bitset.dart';
import '../../../../core/utils/seeded_random.dart';
import '../../../achievements/domain/achievements.dart';
import '../../../boosters/domain/booster.dart';
import '../../../levels/data/level_repository.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../progress/domain/player_progress.dart';
import '../../../settings/domain/game_settings.dart';
import '../../domain/algorithms/level_generator.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/models/level_certificate.dart';
import '../../domain/services/game_engine.dart';
import '../../domain/services/game_session.dart';
import '../../domain/services/hint_service.dart';
import '../../domain/services/shuffle_service.dart';
import '../../domain/services/tile_availability_service.dart';
import 'game_view_state.dart';

// Solver-backed work runs off the UI thread (inline on web).
HintResult _computeHint(BoardState s) => const HintService().findHint(s);
int? _computePartner((BoardState, int) a) =>
    const HintService().partnerFor(a.$1, a.$2);
BoardState? _computeShuffle((BoardState, int) a) =>
    const ShuffleService().shuffle(a.$1, SeededRandom(a.$2));

/// Runs solver-heavy work off the UI thread. Overridable for tests.
typedef BackgroundRunner = Future<R> Function<Q, R>(
    ComputeCallback<Q, R> callback, Q message);

final backgroundRunnerProvider = Provider<BackgroundRunner>(
  (_) => <Q, R>(ComputeCallback<Q, R> cb, Q msg) => compute(cb, msg),
);

/// Outcome of pressing a booster button.
enum BoosterOutcome { used, unavailable, exhausted }

class GameController extends Notifier<GameViewState> {
  Timer? _clock;
  Timer? _phaseTimer;
  Timer? _hintTimer;
  Timer? _inspectTimer;
  int _nonce = 0;
  int _loadToken = 0;

  /// True when the game was paused by the app going to the background
  /// (not by the player), so it should resume when the app returns.
  bool _autoPaused = false;

  @override
  GameViewState build() {
    ref.onDispose(_cancelTimers);
    return const GameViewState();
  }

  GameSettings get _settings => ref.read(settingsProvider);
  BackgroundRunner get _run => ref.read(backgroundRunnerProvider);
  ProgressNotifier get _progress => ref.read(progressProvider.notifier);

  // ------------------------------------------------------------ lifecycle --

  Future<void> start(int levelNumber) async {
    final token = ++_loadToken;
    _cancelTimers();
    state = GameViewState(levelNumber: levelNumber);
    try {
      final level = await ref.read(levelRepositoryProvider).load(levelNumber);
      if (!ref.mounted || token != _loadToken) return;
      final restored = _restore(level);
      state = state.copyWith(
        phase: GamePhase.ready,
        level: level,
        session: restored?.$1 ?? GameSession(board: level.initialState),
        elapsedMs: restored?.$2 ?? 0,
        boostersUsed: restored?.$3 ?? const {},
      );
      _startClock();
      _setPhaseSoon(GamePhase.playing, const Duration(milliseconds: 350));
      _checkNoMoves();
      ref.read(levelRepositoryProvider).prefetch(levelNumber + 1);
    } catch (e, st) {
      debugPrint('Level load failed: $e\n$st');
      if (!ref.mounted || token != _loadToken) return;
      state = state.copyWith(phase: GamePhase.error, error: '$e');
    }
  }

  void restart() {
    final level = state.level;
    if (level == null) return;
    _cancelTimers();
    _progress.clearSavedGame();
    state = GameViewState(
      phase: GamePhase.playing,
      levelNumber: state.levelNumber,
      level: level,
      session: GameSession(board: level.initialState),
    );
    _startClock();
  }

  void pause() {
    if (!state.isInteractive) return;
    _autoPaused = false;
    _clock?.cancel();
    state = state.copyWith(phase: GamePhase.paused, selected: null, hint: null);
    _persist();
  }

  void resume() {
    _autoPaused = false;
    if (state.phase != GamePhase.paused) return;
    state = state.copyWith(phase: GamePhase.playing);
    _startClock();
  }

  /// Called when the app goes to the background (or loses focus).
  void onAppPaused() {
    if (state.session != null && state.phase != GamePhase.completed) {
      _persist();
      if (state.isInteractive) {
        pause();
        _autoPaused = true;
      }
    }
  }

  /// Called when the app is in the foreground again. Only undoes pauses the
  /// app made itself; a pause from the menu stays until the player resumes.
  void onAppResumed() {
    if (_autoPaused && state.phase == GamePhase.paused) resume();
    _autoPaused = false;
  }

  // ------------------------------------------------------------- gameplay --

  void tapTile(int i) {
    final session = state.session;
    if (!state.isInteractive || session == null) return;
    final board = session.board;
    if (board.isRemoved(i)) return;

    if (!board.isSelectable(i)) {
      _emit(FeedbackKind.blocked, [i]);
      _haptic(HapticFeedback.lightImpact);
      return;
    }

    if (state.magicArmed) {
      _performMagic(i);
      return;
    }

    final selected = state.selected;
    if (selected == null) {
      state = state.copyWith(selected: i, phase: GamePhase.tileSelected);
      _emit(FeedbackKind.select, [i]);
      _haptic(HapticFeedback.selectionClick);
      _click();
      return;
    }
    if (selected == i) {
      state = state.copyWith(selected: null, phase: GamePhase.playing);
      return;
    }

    final (result, next) = session.match(selected, i);
    switch (result.type) {
      case MatchResultType.matched:
        _applyMatch(next, [selected, i]);
      case MatchResultType.mismatch:
        // Gentle feedback; the newly tapped tile becomes the selection.
        _emit(FeedbackKind.mismatch, [selected, i]);
        _haptic(HapticFeedback.mediumImpact);
        state = state.copyWith(selected: i, phase: GamePhase.tileSelected);
      case MatchResultType.invalid:
        state = state.copyWith(selected: null, phase: GamePhase.playing);
    }
  }

  void _applyMatch(GameSession next, List<int> tiles,
      {FeedbackKind kind = FeedbackKind.match}) {
    _hintTimer?.cancel();
    state = state.copyWith(
      session: next,
      selected: null,
      hint: null,
      magicArmed: false,
      phase: GamePhase.matching,
    );
    _emit(kind, tiles);
    _haptic(HapticFeedback.lightImpact);
    _click();
    if (next.isCleared) {
      _complete();
      return;
    }
    _setPhaseSoon(GamePhase.playing, GameConstants.removeDuration);
    _persist();
    _checkNoMoves();
  }

  /// Long-press: highlight the tiles that currently block [i].
  void inspect(int i) {
    final board = state.board;
    if (board == null || board.isRemoved(i) || !state.isInteractive) return;
    final blockers =
        TileAvailabilityService.blockersOf(board.geometry, board.removed, i);
    _inspectTimer?.cancel();
    state = state.copyWith(inspected: i, blockers: blockers);
    if (blockers.isEmpty) _toast('This tile is free to match!');
    _inspectTimer = Timer(GameConstants.blockerInspectDuration, () {
      if (ref.mounted) state = state.copyWith(inspected: null, blockers: const []);
    });
  }

  // ------------------------------------------------------------- boosters --

  BoosterOutcome _checkInventory(BoosterType t) {
    if (!state.isInteractive) return BoosterOutcome.unavailable;
    if (state.remaining(t) <= 0) {
      _toast('No ${t.label}s left on this level.');
      return BoosterOutcome.exhausted;
    }
    return BoosterOutcome.used;
  }

  void _markUsed(BoosterType t, {bool free = false}) {
    state = state.copyWith(
      boostersUsed: {...state.boostersUsed, t: state.used(t) + (free ? 0 : 1)},
    );
  }

  Future<BoosterOutcome> useHint() async {
    final check = _checkInventory(BoosterType.hint);
    if (check != BoosterOutcome.used) return check;
    final board = state.board!;
    state = state.copyWith(busy: true);
    final result = await _run(_computeHint, board);
    if (!ref.mounted) return BoosterOutcome.unavailable;
    state = state.copyWith(busy: false);
    if (!identical(state.board, board)) return BoosterOutcome.unavailable;

    switch (result.status) {
      case HintStatus.safe:
      case HintStatus.legal:
        _markUsed(BoosterType.hint);
        state = state.copyWith(
          hint: result.pair,
          selected: null,
          phase: GamePhase.hintActive,
        );
        _hintTimer?.cancel();
        _hintTimer = Timer(GameConstants.hintDuration, () {
          if (!ref.mounted) return;
          if (state.phase == GamePhase.hintActive) {
            state = state.copyWith(hint: null, phase: GamePhase.playing);
          } else {
            state = state.copyWith(hint: null);
          }
        });
        return BoosterOutcome.used;
      case HintStatus.deadEnd:
        _toast('No winning moves from here — try Undo or Shuffle.');
        return BoosterOutcome.unavailable;
      case HintStatus.noMoves:
        state = state.copyWith(noMoves: true);
        return BoosterOutcome.unavailable;
    }
  }

  BoosterOutcome undo() {
    final check = _checkInventory(BoosterType.undo);
    if (check != BoosterOutcome.used) return check;
    final session = state.session!;
    final prev = session.undo();
    if (prev == null) {
      _toast('Nothing to undo yet.');
      return BoosterOutcome.unavailable;
    }
    final entry = session.history.last;
    _markUsed(BoosterType.undo);
    state = state.copyWith(
      session: prev,
      selected: null,
      hint: null,
      noMoves: false,
      magicArmed: false,
      phase: GamePhase.undoActive,
    );
    _emit(FeedbackKind.undo, entry.pair?.both ?? const []);
    _setPhaseSoon(GamePhase.playing, GameConstants.removeDuration);
    _persist();
    return BoosterOutcome.used;
  }

  /// Reshuffles remaining symbols. Free when the board has no moves left.
  Future<BoosterOutcome> shuffle({bool free = false}) async {
    if (!free) {
      final check = _checkInventory(BoosterType.shuffle);
      if (check != BoosterOutcome.used) return check;
    } else if (state.session == null || state.busy) {
      return BoosterOutcome.unavailable;
    }
    final session = state.session!;
    state = state.copyWith(busy: true, phase: GamePhase.shuffleActive);
    final seed = DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF;
    final next = await _run(_computeShuffle, (session.board, seed));
    if (!ref.mounted) return BoosterOutcome.unavailable;
    state = state.copyWith(busy: false);
    if (!identical(state.session, session)) return BoosterOutcome.unavailable;
    if (next == null) {
      state = state.copyWith(phase: GamePhase.playing);
      _toast('These tiles can\'t be rearranged into a winnable board — try Undo.');
      return BoosterOutcome.unavailable;
    }
    _markUsed(BoosterType.shuffle, free: free);
    state = state.copyWith(
      session: session.shuffled(next),
      selected: null,
      hint: null,
      noMoves: false,
    );
    _emit(FeedbackKind.shuffle, next.remainingTiles.toList());
    _setPhaseSoon(GamePhase.playing, GameConstants.revealDuration);
    _persist();
    return BoosterOutcome.used;
  }

  /// Magic match: removes the selected tile (or the next tapped one) with a
  /// selectable partner.
  BoosterOutcome armMagic() {
    final check = _checkInventory(BoosterType.magic);
    if (check != BoosterOutcome.used) return check;
    if (state.selected != null) {
      _performMagic(state.selected!);
    } else {
      state = state.copyWith(magicArmed: !state.magicArmed);
      if (state.magicArmed) _toast('Tap any free tile to auto-match it.');
    }
    return BoosterOutcome.used;
  }

  Future<void> _performMagic(int tile) async {
    final session = state.session!;
    state = state.copyWith(busy: true);
    final partner = await _run(_computePartner, (session.board, tile));
    if (!ref.mounted) return;
    state = state.copyWith(busy: false, magicArmed: false);
    if (!identical(state.session, session)) return;
    if (partner == null) {
      _emit(FeedbackKind.blocked, [tile]);
      _toast('Its twin isn\'t free yet — try another tile.');
      state = state.copyWith(magicArmed: true);
      return;
    }
    final (result, next) = session.match(tile, partner, kind: HistoryKind.magic);
    if (!result.isMatch) return;
    _markUsed(BoosterType.magic);
    _applyMatch(next, [tile, partner], kind: FeedbackKind.magic);
  }

  void dismissNoMoves() => state = state.copyWith(noMoves: false);

  // ------------------------------------------------------------- internal --

  void _checkNoMoves() {
    final board = state.board;
    if (board == null || board.isCleared) return;
    if (GameEngine.matchingPairs(board).isEmpty) {
      state = state.copyWith(noMoves: true);
    }
  }

  void _complete() {
    _clock?.cancel();
    final s = state;
    final reward = _progress.completeLevel(
      level: s.levelNumber,
      assistsUsed: s.assistsUsed,
      matches: s.session?.matches ?? 0,
      elapsed: Duration(milliseconds: s.elapsedMs),
      facts: CompletionFacts(
        s.level?.geometry.layerCount ?? 1,
        Duration(milliseconds: s.elapsedMs),
        s.assistsUsed > 0,
      ),
    );
    _phaseTimer?.cancel();
    _phaseTimer = Timer(GameConstants.completionDelay, () {
      if (!ref.mounted) return;
      state = state.copyWith(phase: GamePhase.completed, reward: reward);
      _haptic(HapticFeedback.heavyImpact);
    });
  }

  void _persist() {
    final s = state;
    final session = s.session;
    final level = s.level;
    if (session == null || level == null || session.isCleared) return;
    _progress.saveGame(SavedGame(
      levelNumber: s.levelNumber,
      generatorVersion: LevelGenerator.version,
      symbols: session.board.symbols,
      removed: session.board.removed.setIndices.toList(),
      elapsedMs: s.elapsedMs,
      matches: session.matches,
      boostersUsed: {for (final e in s.boostersUsed.entries) e.key.name: e.value},
    ));
  }

  (GameSession, int, Map<BoosterType, int>)? _restore(GeneratedLevel level) {
    final saved = ref.read(progressProvider).savedGame;
    if (saved == null ||
        saved.levelNumber != level.levelNumber ||
        saved.generatorVersion != LevelGenerator.version ||
        saved.symbols.length != level.geometry.length) {
      return null;
    }
    // Saved symbols must be a permutation-compatible deal of the level.
    final board = BoardState(
      geometry: level.geometry,
      symbols: saved.symbols,
      removed: BitSet.fromIndices(level.geometry.length, saved.removed),
    );
    if (board.remainingSymbolCounts().values.any((c) => c.isOdd)) return null;
    return (
      GameSession(board: board, matches: saved.matches),
      saved.elapsedMs,
      {
        for (final b in BoosterType.values)
          if (saved.boostersUsed[b.name] != null) b: saved.boostersUsed[b.name]!,
      },
    );
  }

  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) return;
      if (state.isInteractive) {
        state = state.copyWith(elapsedMs: state.elapsedMs + 1000);
      }
    });
  }

  void _setPhaseSoon(GamePhase phase, Duration after) {
    _phaseTimer?.cancel();
    _phaseTimer = Timer(after, () {
      if (!ref.mounted) return;
      const transient = {
        GamePhase.ready,
        GamePhase.matching,
        GamePhase.undoActive,
        GamePhase.shuffleActive,
      };
      if (transient.contains(state.phase)) {
        state = state.copyWith(
          phase: state.selected != null ? GamePhase.tileSelected : phase,
        );
      }
    });
  }

  void _emit(FeedbackKind kind, List<int> tiles) {
    state = state.copyWith(event: FeedbackEvent(kind, tiles, ++_nonce));
  }

  void _toast(String message) {
    state = state.copyWith(toast: message, toastNonce: state.toastNonce + 1);
  }

  void _haptic(Future<void> Function() fx) {
    if (_settings.haptics) fx();
  }

  void _click() {
    if (_settings.sound) SystemSound.play(SystemSoundType.click);
  }

  void _cancelTimers() {
    _clock?.cancel();
    _phaseTimer?.cancel();
    _hintTimer?.cancel();
    _inspectTimer?.cancel();
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameViewState>(GameController.new);
