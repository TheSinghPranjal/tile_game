import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/domain/algorithms/level_generator.dart';
import '../../game/domain/models/level_certificate.dart';

GeneratedLevel _generateInBackground(int level) =>
    const LevelGenerator().generateLevel(level);

/// Produces verified levels. Generation (geometry + sequence + solver +
/// difficulty analysis) runs on a background isolate so the UI never janks,
/// and recently used levels are cached (including a prefetch of the next).
class LevelRepository {
  final _cache = <int, Future<GeneratedLevel>>{}; // insertion-ordered
  static const _maxCached = 6;

  /// Generate on the calling isolate (tests / tooling).
  final bool inline;

  LevelRepository({this.inline = false});

  Future<GeneratedLevel> load(int level) {
    final hit = _cache.remove(level);
    final future = hit ??
        (inline
            ? Future.value(_generateInBackground(level))
            : compute(_generateInBackground, level));
    _cache[level] = future;
    // Never cache a failure.
    future.then((_) {}, onError: (Object _) => _cache.remove(level));
    while (_cache.length > _maxCached) {
      _cache.remove(_cache.keys.first);
    }
    return future;
  }

  /// Starts generating [level] without waiting for it.
  void prefetch(int level) {
    if (!_cache.containsKey(level)) load(level).ignore();
  }
}

final levelRepositoryProvider = Provider<LevelRepository>((_) => LevelRepository());
