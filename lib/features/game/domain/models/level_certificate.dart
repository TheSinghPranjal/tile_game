import '../entities/board_geometry.dart';
import '../entities/board_state.dart';
import 'difficulty_report.dart';

/// Proof that a level is solvable. Stored for debugging/testing only and
/// never shown to the player.
class LevelCertificate {
  final int levelId;
  final List<Map<String, dynamic>> geometry;
  final List<int> symbols;
  final List<TilePair> solution;
  final DifficultyReport difficulty;
  final int layers;
  final int totalTiles;
  final String solverStatus;
  final int solverNodes;
  final int generatorVersion;
  final int seed;
  final int attempt;
  final String template;

  const LevelCertificate({
    required this.levelId,
    required this.geometry,
    required this.symbols,
    required this.solution,
    required this.difficulty,
    required this.layers,
    required this.totalTiles,
    required this.solverStatus,
    required this.solverNodes,
    required this.generatorVersion,
    required this.seed,
    required this.attempt,
    required this.template,
  });

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'generatorVersion': generatorVersion,
        'seed': seed,
        'attempt': attempt,
        'template': template,
        'layers': layers,
        'totalTiles': totalTiles,
        'solver': {'status': solverStatus, 'nodes': solverNodes},
        'difficulty': difficulty.toJson(),
        'geometry': geometry,
        'symbols': symbols,
        'solution': [for (final p in solution) p.toJson()],
      };

  factory LevelCertificate.fromJson(Map<String, dynamic> j) => LevelCertificate(
        levelId: j['levelId'] as int,
        generatorVersion: j['generatorVersion'] as int,
        seed: j['seed'] as int,
        attempt: j['attempt'] as int,
        template: j['template'] as String,
        layers: j['layers'] as int,
        totalTiles: j['totalTiles'] as int,
        solverStatus: (j['solver'] as Map)['status'] as String,
        solverNodes: (j['solver'] as Map)['nodes'] as int,
        difficulty:
            DifficultyReport.fromJson(j['difficulty'] as Map<String, dynamic>),
        geometry: (j['geometry'] as List).cast<Map<String, dynamic>>(),
        symbols: (j['symbols'] as List).cast<int>(),
        solution: [
          for (final p in j['solution'] as List) TilePair.fromJson(p as List),
        ],
      );
}

/// A fully generated, verified level ready to play.
class GeneratedLevel {
  final int levelNumber;
  final BoardGeometry geometry;
  final List<int> symbols;
  final String templateName;
  final int themeIndex;
  final LevelCertificate certificate;

  const GeneratedLevel({
    required this.levelNumber,
    required this.geometry,
    required this.symbols,
    required this.templateName,
    required this.themeIndex,
    required this.certificate,
  });

  BoardState get initialState =>
      BoardState(geometry: geometry, symbols: symbols);

  DifficultyReport get difficulty => certificate.difficulty;
}
