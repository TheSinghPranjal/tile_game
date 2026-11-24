import '../../../boosters/domain/booster.dart';
import '../../../progress/data/progress_repository.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/models/level_certificate.dart';
import '../../domain/services/game_session.dart';

enum GamePhase {
  loading,
  ready,
  playing,
  tileSelected,
  matching,
  hintActive,
  undoActive,
  shuffleActive,
  paused,
  completed,

  /// Only used by optional challenge modes; standard levels never fail.
  failed,
  error,
}

enum FeedbackKind { select, match, mismatch, blocked, undo, shuffle, magic }

/// A one-shot visual/haptic event. [nonce] makes repeated events distinct.
class FeedbackEvent {
  final FeedbackKind kind;
  final List<int> tiles;
  final int nonce;
  const FeedbackEvent(this.kind, this.tiles, this.nonce);
}

const _unset = Object();

class GameViewState {
  final GamePhase phase;
  final int levelNumber;
  final GeneratedLevel? level;
  final GameSession? session;
  final int? selected;
  final TilePair? hint;
  final int? inspected;
  final List<int> blockers;
  final FeedbackEvent? event;
  final bool magicArmed;
  final int elapsedMs;
  final Map<BoosterType, int> boostersUsed;
  final bool noMoves;
  final String? toast;
  final int toastNonce;
  final LevelReward? reward;
  final String? error;
  final bool busy;

  const GameViewState({
    this.phase = GamePhase.loading,
    this.levelNumber = 1,
    this.level,
    this.session,
    this.selected,
    this.hint,
    this.inspected,
    this.blockers = const [],
    this.event,
    this.magicArmed = false,
    this.elapsedMs = 0,
    this.boostersUsed = const {},
    this.noMoves = false,
    this.toast,
    this.toastNonce = 0,
    this.reward,
    this.error,
    this.busy = false,
  });

  BoardState? get board => session?.board;
  int get totalTiles => level?.geometry.length ?? 0;
  int get remainingTiles => board?.remainingCount ?? 0;
  double get progress =>
      totalTiles == 0 ? 0 : (totalTiles - remainingTiles) / totalTiles;

  bool get isInteractive =>
      !busy &&
      session != null &&
      const {
        GamePhase.ready,
        GamePhase.playing,
        GamePhase.tileSelected,
        GamePhase.matching,
        GamePhase.hintActive,
        GamePhase.undoActive,
        GamePhase.shuffleActive,
      }.contains(phase);

  int used(BoosterType t) => boostersUsed[t] ?? 0;

  /// Boosters of type [t] still available on this level.
  int remaining(BoosterType t) => t.perLevel - used(t);

  /// Boosters that lower the star rating (undo is free of penalty).
  int get assistsUsed =>
      used(BoosterType.hint) + used(BoosterType.shuffle) + used(BoosterType.magic);

  GameViewState copyWith({
    GamePhase? phase,
    int? levelNumber,
    Object? level = _unset,
    Object? session = _unset,
    Object? selected = _unset,
    Object? hint = _unset,
    Object? inspected = _unset,
    List<int>? blockers,
    Object? event = _unset,
    bool? magicArmed,
    int? elapsedMs,
    Map<BoosterType, int>? boostersUsed,
    bool? noMoves,
    Object? toast = _unset,
    int? toastNonce,
    Object? reward = _unset,
    Object? error = _unset,
    bool? busy,
  }) =>
      GameViewState(
        phase: phase ?? this.phase,
        levelNumber: levelNumber ?? this.levelNumber,
        level: level == _unset ? this.level : level as GeneratedLevel?,
        session: session == _unset ? this.session : session as GameSession?,
        selected: selected == _unset ? this.selected : selected as int?,
        hint: hint == _unset ? this.hint : hint as TilePair?,
        inspected: inspected == _unset ? this.inspected : inspected as int?,
        blockers: blockers ?? this.blockers,
        event: event == _unset ? this.event : event as FeedbackEvent?,
        magicArmed: magicArmed ?? this.magicArmed,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        boostersUsed: boostersUsed ?? this.boostersUsed,
        noMoves: noMoves ?? this.noMoves,
        toast: toast == _unset ? this.toast : toast as String?,
        toastNonce: toastNonce ?? this.toastNonce,
        reward: reward == _unset ? this.reward : reward as LevelReward?,
        error: error == _unset ? this.error : error as String?,
        busy: busy ?? this.busy,
      );
}
