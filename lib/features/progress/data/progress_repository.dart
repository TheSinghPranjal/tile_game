import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/storage.dart';
import '../../achievements/domain/achievements.dart';
import '../domain/player_progress.dart';

/// Offline progress persisted as a JSON document in SharedPreferences.
class ProgressRepository {
  static const _key = 'progress.v1';
  final SharedPreferences _prefs;

  ProgressRepository(this._prefs);

  PlayerProgress load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return PlayerProgress.initial();
    try {
      return PlayerProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Corrupt progress, resetting: $e');
      return PlayerProgress.initial();
    }
  }

  Future<void> save(PlayerProgress p) =>
      _prefs.setString(_key, jsonEncode(p.toJson()));
}

/// Result of finishing a level, shown on the celebration dialog.
class LevelReward {
  final int stars;

  /// True when this beats the player's previous rating for the level.
  final bool newBest;
  final List<Achievement> achievements;
  const LevelReward(this.stars, this.newBest, this.achievements);
}

class ProgressNotifier extends Notifier<PlayerProgress> {
  late ProgressRepository _repo;

  @override
  PlayerProgress build() {
    _repo = ProgressRepository(ref.watch(sharedPreferencesProvider));
    return _repo.load();
  }

  void _set(PlayerProgress p) {
    state = p;
    _repo.save(p);
  }

  void saveGame(SavedGame g) => _set(state.copyWith(savedGame: g));

  void clearSavedGame() {
    if (state.savedGame != null) _set(state.copyWith(clearSavedGame: true));
  }

  /// 3 stars with no assist boosters, 2 with up to two, otherwise 1.
  /// Undo never costs stars.
  static int starsFor(int assistsUsed) =>
      assistsUsed == 0 ? 3 : (assistsUsed <= 2 ? 2 : 1);

  /// Records a completed level and returns the reward.
  LevelReward completeLevel({
    required int level,
    required int assistsUsed,
    required int matches,
    required Duration elapsed,
    required CompletionFacts facts,
  }) {
    final stars = starsFor(assistsUsed);
    final prev = state.stars[level] ?? 0;
    var next = state.copyWith(
      highestUnlocked: math.min(
        GameConstants.totalLevels,
        math.max(level + 1, state.highestUnlocked),
      ),
      stars: {...state.stars, level: stars > prev ? stars : prev},
      totalMatches: state.totalMatches + matches,
      bestTimeMs: state.bestTimeMs == 0 ||
              elapsed.inMilliseconds < state.bestTimeMs
          ? elapsed.inMilliseconds
          : state.bestTimeMs,
      clearSavedGame: true,
    );
    final earned = AchievementService.evaluate(next, facts);
    next = next.copyWith(
      achievements: {...next.achievements, ...earned.map((a) => a.name)},
    );
    _set(next);
    return LevelReward(stars, stars > prev, earned);
  }

  void resetAll() => _set(PlayerProgress.initial());
}

final progressProvider =
    NotifierProvider<ProgressNotifier, PlayerProgress>(ProgressNotifier.new);
