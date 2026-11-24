
/// Unfinished board persisted between app sessions.
class SavedGame {
  final int levelNumber;
  final int generatorVersion;
  final List<int> symbols;
  final List<int> removed;
  final int elapsedMs;
  final int matches;
  final Map<String, int> boostersUsed;

  const SavedGame({
    required this.levelNumber,
    required this.generatorVersion,
    required this.symbols,
    required this.removed,
    required this.elapsedMs,
    required this.matches,
    required this.boostersUsed,
  });

  Map<String, dynamic> toJson() => {
        'level': levelNumber,
        'v': generatorVersion,
        'symbols': symbols,
        'removed': removed,
        'elapsed': elapsedMs,
        'matches': matches,
        'used': boostersUsed,
      };

  factory SavedGame.fromJson(Map<String, dynamic> j) => SavedGame(
        levelNumber: j['level'] as int,
        generatorVersion: j['v'] as int,
        symbols: (j['symbols'] as List).cast<int>(),
        removed: (j['removed'] as List).cast<int>(),
        elapsedMs: j['elapsed'] as int,
        matches: j['matches'] as int,
        boostersUsed: (j['used'] as Map).cast<String, int>(),
      );
}

class PlayerProgress {
  /// Highest level the player may start.
  final int highestUnlocked;

  /// Best star rating (1-3) per cleared level.
  final Map<int, int> stars;
  final Set<String> achievements;
  final int totalMatches;
  final int bestTimeMs;
  final SavedGame? savedGame;

  const PlayerProgress({
    required this.highestUnlocked,
    required this.stars,
    required this.achievements,
    required this.totalMatches,
    required this.bestTimeMs,
    this.savedGame,
  });

  factory PlayerProgress.initial() => const PlayerProgress(
        highestUnlocked: 1,
        stars: {},
        achievements: {},
        totalMatches: 0,
        bestTimeMs: 0,
      );

  int get totalStars => stars.values.fold(0, (a, b) => a + b);
  int get levelsCleared => stars.length;

  PlayerProgress copyWith({
    int? highestUnlocked,
    Map<int, int>? stars,
    Set<String>? achievements,
    int? totalMatches,
    int? bestTimeMs,
    SavedGame? savedGame,
    bool clearSavedGame = false,
  }) =>
      PlayerProgress(
        highestUnlocked: highestUnlocked ?? this.highestUnlocked,
        stars: stars ?? this.stars,
        achievements: achievements ?? this.achievements,
        totalMatches: totalMatches ?? this.totalMatches,
        bestTimeMs: bestTimeMs ?? this.bestTimeMs,
        savedGame: clearSavedGame ? null : (savedGame ?? this.savedGame),
      );

  Map<String, dynamic> toJson() => {
        'highest': highestUnlocked,
        'stars': {for (final e in stars.entries) '${e.key}': e.value},
        'achievements': achievements.toList(),
        'matches': totalMatches,
        'bestTime': bestTimeMs,
        if (savedGame != null) 'saved': savedGame!.toJson(),
      };

  /// Unknown fields from older saves (coins, booster inventory) are ignored.
  factory PlayerProgress.fromJson(Map<String, dynamic> j) => PlayerProgress(
        highestUnlocked: j['highest'] as int? ?? 1,
        stars: {
          // Levels cleared while the game used coins carry no rating: 1 star.
          for (final l in ((j['cleared'] as List?) ?? const []).cast<int>()) l: 1,
          for (final e in ((j['stars'] as Map?) ?? const {}).entries)
            int.parse(e.key as String): e.value as int,
        },
        achievements: {...((j['achievements'] as List?) ?? []).cast<String>()},
        totalMatches: j['matches'] as int? ?? 0,
        bestTimeMs: j['bestTime'] as int? ?? 0,
        savedGame: j['saved'] == null
            ? null
            : SavedGame.fromJson(j['saved'] as Map<String, dynamic>),
      );
}
