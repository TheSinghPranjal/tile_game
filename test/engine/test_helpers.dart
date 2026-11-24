import 'package:tile_game/features/game/domain/entities/board_geometry.dart';
import 'package:tile_game/features/game/domain/entities/board_state.dart';
import 'package:tile_game/features/game/domain/entities/tile_position.dart';
import 'package:tile_game/features/game/domain/services/tile_availability_service.dart';

/// Builds a board from `(layer, x, y, symbol)` records.
BoardState board(
  List<(int, double, double, int)> spec, {
  AvailabilityConfig config = AvailabilityConfig.standard,
}) {
  final tiles = [
    for (var i = 0; i < spec.length; i++)
      TilePosition(id: i, layer: spec[i].$1, x: spec[i].$2, y: spec[i].$3),
  ];
  return BoardState(
    geometry: BoardGeometry(tiles, config: config),
    symbols: [for (final s in spec) s.$4],
  );
}
