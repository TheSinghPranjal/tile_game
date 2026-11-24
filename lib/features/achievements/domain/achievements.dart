import '../../progress/domain/player_progress.dart';

enum Achievement {
  firstClear('First Bloom', 'Clear your first board.', '🌱'),
  tenLevels('Rising Star', 'Clear 10 levels.', '⭐'),
  fiftyLevels('Tile Master', 'Clear 50 levels.', '🏆'),
  hundredLevels('Grove Legend', 'Clear 100 levels.', '👑'),
  perfectTen('Perfectionist', 'Earn 3 stars on 10 levels.', '💎'),
  speedster('Speedster', 'Clear a board in under 60 seconds.', '⚡'),
  thousandMatches('Collector', 'Make 1,000 matches.', '🎯'),
  pureSkill('Pure Skill', 'Clear a 4+ layer board without boosters.', '🧠');

  final String title;
  final String description;
  final String badge;

  const Achievement(this.title, this.description, this.badge);
}

/// Facts about the level that was just completed.
class CompletionFacts {
  final int layers;
  final Duration elapsed;
  final bool usedBoosters;
  const CompletionFacts(this.layers, this.elapsed, this.usedBoosters);
}

class AchievementService {
  const AchievementService._();

  /// Achievements newly earned given the updated [progress].
  static List<Achievement> evaluate(
    PlayerProgress progress,
    CompletionFacts facts,
  ) {
    final cleared = progress.levelsCleared;
    final threeStars = progress.stars.values.where((s) => s >= 3).length;
    final earned = <Achievement>[
      if (cleared >= 1) Achievement.firstClear,
      if (cleared >= 10) Achievement.tenLevels,
      if (cleared >= 50) Achievement.fiftyLevels,
      if (cleared >= 100) Achievement.hundredLevels,
      if (threeStars >= 10) Achievement.perfectTen,
      if (facts.elapsed.inSeconds < 60) Achievement.speedster,
      if (progress.totalMatches >= 1000) Achievement.thousandMatches,
      if (facts.layers >= 4 && !facts.usedBoosters) Achievement.pureSkill,
    ];
    return earned
        .where((a) => !progress.achievements.contains(a.name))
        .toList();
  }
}
