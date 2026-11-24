import '../../../../core/utils/bitset.dart';
import '../services/tile_availability_service.dart';
import 'board_geometry.dart';

/// An unordered pair of tile indices, normalised so that `a < b`.
class TilePair {
  final int a;
  final int b;

  TilePair(int x, int y)
      : assert(x != y),
        a = x < y ? x : y,
        b = x < y ? y : x;

  List<int> get both => [a, b];

  bool contains(int i) => a == i || b == i;

  @override
  bool operator ==(Object other) =>
      other is TilePair && other.a == a && other.b == b;

  @override
  int get hashCode => a * 7919 + b;

  List<int> toJson() => [a, b];

  factory TilePair.fromJson(List<dynamic> j) =>
      TilePair(j[0] as int, j[1] as int);

  @override
  String toString() => '($a,$b)';
}

/// Immutable snapshot of a board: fixed geometry + current symbols + which
/// tiles have been removed.
class BoardState {
  final BoardGeometry geometry;

  /// `symbols[i]` is the stable symbol ID of tile i. Matching compares these
  /// IDs only – never images or widgets.
  final List<int> symbols;
  final BitSet removed;

  BoardState({
    required this.geometry,
    required List<int> symbols,
    BitSet? removed,
  })  : assert(symbols.length == geometry.length),
        symbols = List.unmodifiable(symbols),
        removed = removed ?? BitSet.empty(geometry.length);

  int get length => geometry.length;
  int get remainingCount => length - removed.count;
  bool get isCleared => removed.isFull;

  bool isRemoved(int i) => removed[i];

  bool isSelectable(int i) =>
      TileAvailabilityService.isSelectable(geometry, removed, i);

  List<int> get selectableTiles =>
      TileAvailabilityService.selectableTiles(geometry, removed);

  Iterable<int> get remainingTiles sync* {
    for (var i = 0; i < length; i++) {
      if (!removed[i]) yield i;
    }
  }

  BoardState withRemoved(Iterable<int> indices) => BoardState(
        geometry: geometry,
        symbols: symbols,
        removed: removed.withBits(indices),
      );

  BoardState withSymbols(List<int> newSymbols) => BoardState(
        geometry: geometry,
        symbols: newSymbols,
        removed: removed,
      );

  /// Count of remaining tiles per symbol.
  Map<int, int> remainingSymbolCounts() {
    final m = <int, int>{};
    for (final i in remainingTiles) {
      m[symbols[i]] = (m[symbols[i]] ?? 0) + 1;
    }
    return m;
  }
}
