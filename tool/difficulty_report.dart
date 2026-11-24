// ignore_for_file: avoid_print
// Prints the generated difficulty curve so levels can be tested & rebalanced.
//
//   dart run tool/difficulty_report.dart [from] [to]
import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/levels/domain/level_config.dart';

void main(List<String> args) {
  final from = args.isNotEmpty ? int.parse(args[0]) : 1;
  final to = args.length > 1 ? int.parse(args[1]) : 60;
  const gen = LevelGenerator();
  print('level | tier       | template       | tiles | L | init | depth | '
      'success | nodes  | score | label  | ms');
  for (var n = from; n <= to; n++) {
    final sw = Stopwatch()..start();
    final level = gen.generateLevel(n);
    final d = level.difficulty;
    final cfg = LevelConfig.forLevel(n);
    print('${'$n'.padLeft(5)} | ${cfg.tier.name.padRight(10)} | '
        '${level.certificate.template.padRight(14)} | '
        '${'${d.totalTiles}'.padLeft(5)} | ${d.layers} | '
        '${'${d.initialMatchingPairs}'.padLeft(4)} | '
        '${'${d.dependencyDepth}'.padLeft(5)} | '
        '${d.playoutSuccessRate.toStringAsFixed(2).padLeft(7)} | '
        '${'${d.solverNodes}'.padLeft(6)} | '
        '${d.score.toStringAsFixed(1).padLeft(5)} | ${d.label.padRight(6)} | '
        '${sw.elapsedMilliseconds}');
  }
}
