@Tags(['batch'])
@Timeout(Duration(hours: 2))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tile_game/features/game/domain/algorithms/level_generator.dart';
import 'package:tile_game/features/game/domain/services/game_engine.dart';
import 'package:tile_game/features/game/domain/entities/board_state.dart';
import 'package:tile_game/features/game/domain/solvers/level_solver.dart';
import 'package:tile_game/features/game/domain/validators/geometry_validator.dart';
import 'package:tile_game/features/game/domain/validators/level_validator.dart';
import 'package:tile_game/features/levels/domain/layout_templates.dart';
import 'package:tile_game/features/levels/domain/level_config.dart';

/// Batch validation across every template and difficulty tier.
///
///   flutter test test/batch --tags batch            # 10,000 boards
///   BATCH_COUNT=500 flutter test test/batch          # quicker run
///
/// Failing boards are written to build/batch_failures/ for debugging.
void main() {
  final count = int.tryParse(Platform.environment['BATCH_COUNT'] ?? '') ?? 10000;

  test('batch: $count generated boards are all independently solvable', () {
    const generator = LevelGenerator();
    // A separate solver instance with a larger budget: verification is
    // independent of the generator's own check.
    const verifier = LevelSolver(nodeBudget: 2000000, initialRunBudget: 5000);
    final failuresDir = Directory('build/batch_failures')
      ..createSync(recursive: true);
    for (final f in failuresDir.listSync()) {
      f.deleteSync();
    }

    final failures = <String>[];
    final perTemplate = <String, int>{};
    final tiers = DifficultyTier.values;
    final templates = LayoutTemplate.values;
    final sw = Stopwatch()..start();
    var tiles = 0;

    for (var i = 0; i < count; i++) {
      final tier = tiers[i % tiers.length];
      final template = templates[(i ~/ tiers.length) % templates.length];
      final levelNumber = tier.firstLevel + (i ~/ 96) % 40;
      final config =
          LevelConfig.forLevel(levelNumber).copyWith(template: template);

      final issues = <String>[];
      final level = generator.generate(config, salt: i + 1);
      final g = level.geometry;
      tiles += g.length;
      perTemplate[level.certificate.template] =
          (perTemplate[level.certificate.template] ?? 0) + 1;

      issues.addAll(GeometryValidator.validate(g));
      if (!LevelValidator.noStructurallyTrappedTiles(g)) {
        issues.add('structurally trapped tile');
      }

      // Tile conservation & even symbol counts.
      if (level.symbols.length != g.length) issues.add('symbol/tile mismatch');
      final counts = <int, int>{};
      for (final s in level.symbols) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
      if (counts.values.any((c) => c.isOdd)) issues.add('odd symbol count');

      // Independent solver.
      final r = verifier.solve(level.initialState);
      if (!r.isSolved) issues.add('verifier: ${r.status.name}');

      // Replay certificate AND verifier solution through the real engine.
      final report =
          LevelValidator.validate(g, level.symbols, level.certificate.solution);
      issues.addAll(report.issues);
      if (r.isSolved) {
        var s = level.initialState;
        for (final p in r.solution) {
          final m = GameEngine.tryMatch(s, p.a, p.b);
          if (!m.isMatch) {
            issues.add('verifier solution step $p is ${m.type.name}');
            break;
          }
          s = m.state;
        }
        if (!s.isCleared) issues.add('verifier replay left tiles');
      }

      // All dependencies resolved before completion: final state empty and
      // each covered tile freed before removal (checked in validate()).
      final finalState = level.certificate.solution
          .fold<BoardState>(level.initialState, (s, p) => s.withRemoved(p.both));
      if (!finalState.isCleared) issues.add('certificate does not clear board');

      if (issues.isNotEmpty) {
        failures.add('#$i level=$levelNumber template=${template.name}: '
            '${issues.take(3).join('; ')}');
        File('${failuresDir.path}/board_$i.json').writeAsStringSync(
          const JsonEncoder.withIndent(' ').convert({
            'index': i,
            'issues': issues,
            'certificate': level.certificate.toJson(),
          }),
        );
      }
    }

    final summary = {
      'boards': count,
      'failures': failures.length,
      'totalTiles': tiles,
      'seconds': sw.elapsed.inSeconds,
      'perTemplate': perTemplate,
    };
    File('build/batch_summary.json')
        .writeAsStringSync(const JsonEncoder.withIndent(' ').convert(summary));
    // ignore: avoid_print
    print('BATCH SUMMARY: ${jsonEncode(summary)}');
    expect(failures, isEmpty, reason: failures.take(20).join('\n'));
  });
}
