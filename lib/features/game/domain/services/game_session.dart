import '../entities/board_state.dart';
import 'game_engine.dart';

/// What produced a history entry.
enum HistoryKind { match, shuffle, magic }

class HistoryEntry {
  final HistoryKind kind;

  /// The complete board BEFORE the action – undo restores it exactly.
  final BoardState before;

  /// Pair removed by the action (null for shuffles).
  final TilePair? pair;

  const HistoryEntry(this.kind, this.before, [this.pair]);
}

/// Immutable game progress: current board plus undo history.
class GameSession {
  final BoardState board;
  final List<HistoryEntry> history;
  final int matches;

  GameSession({
    required this.board,
    List<HistoryEntry> history = const [],
    this.matches = 0,
  }) : history = List.unmodifiable(history);

  bool get canUndo => history.isNotEmpty;
  bool get isCleared => board.isCleared;

  /// Attempts to match [a] with [b]. Returns the outcome plus the new
  /// session (unchanged unless the tiles matched).
  (MatchResult, GameSession) match(
    int a,
    int b, {
    HistoryKind kind = HistoryKind.match,
  }) {
    final r = GameEngine.tryMatch(board, a, b);
    if (!r.isMatch) return (r, this);
    return (
      r,
      GameSession(
        board: r.state,
        history: [...history, HistoryEntry(kind, board, TilePair(a, b))],
        matches: matches + 1,
      ),
    );
  }

  /// Restores the exact previous board. Returns null when nothing to undo.
  GameSession? undo() {
    if (history.isEmpty) return null;
    final last = history.last;
    return GameSession(
      board: last.before,
      history: history.sublist(0, history.length - 1),
      matches: last.pair != null ? matches - 1 : matches,
    );
  }

  /// Replaces the board with a reshuffled version (undoable).
  GameSession shuffled(BoardState next) {
    assert(identical(next.geometry, board.geometry));
    assert(next.removed == board.removed);
    return GameSession(
      board: next,
      history: [...history, HistoryEntry(HistoryKind.shuffle, board)],
      matches: matches,
    );
  }
}
