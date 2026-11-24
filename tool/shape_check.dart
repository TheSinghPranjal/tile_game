// ignore_for_file: avoid_print


import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/levels/domain/level_config.dart';

void main(List<String> args) {
  final from = int.parse(args[0]), to = int.parse(args[1]), step = args.length > 2 ? int.parse(args[2]) : 1;
  const gen = LevelGenerator();
  var fallbacks = 0, slow = 0;
  for (var l = from; l <= to; l += step) {
    final c = LevelConfig.forLevel(l);
    final sw = Stopwatch()..start();
    final g = gen.generate(c);
    final ms = sw.elapsedMilliseconds;
    final fb = g.templateName != c.displayName;
    if (fb) fallbacks++;
    if (ms > 1500) slow++;
    print('L$l ${c.tier.name} ${c.displayName} -> ${g.templateName} tiles=${g.geometry.length} layers=${g.geometry.layerCount} ${ms}ms${fb ? '  FALLBACK' : ''}');
  }
  print('fallbacks=$fallbacks slow=$slow');
}
