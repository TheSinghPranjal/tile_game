import 'package:flutter_test/flutter_test.dart';
import 'package:tile_game/features/progress/data/progress_repository.dart';
import 'package:tile_game/features/progress/domain/player_progress.dart';

void main() {
  test('star rating depends only on assist boosters', () {
    expect(ProgressNotifier.starsFor(0), 3);
    expect(ProgressNotifier.starsFor(1), 2);
    expect(ProgressNotifier.starsFor(2), 2);
    expect(ProgressNotifier.starsFor(3), 1);
  });

  test('older saves load: coins/boosters ignored, cleared levels get 1 star',
      () {
    final p = PlayerProgress.fromJson({
      'highest': 5,
      'cleared': [1, 2, 4],
      'stars': {'4': 3},
      'coins': 555,
      'boosters': {'hint': 9},
    });
    expect(p.stars, {1: 1, 2: 1, 4: 3});
    expect(p.totalStars, 5);
    final json = p.toJson();
    expect(json.containsKey('coins'), isFalse);
    expect(json.containsKey('boosters'), isFalse);
    expect(PlayerProgress.fromJson(json).stars, p.stars);
  });
}
