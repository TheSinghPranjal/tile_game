/// Deterministic, platform-independent pseudo random generator (xorshift32).
///
/// `dart:math`'s `Random(seed)` is not guaranteed to produce identical
/// sequences on every platform (VM vs. web), so the level generator uses this
/// class to make every generated board reproducible from its seed.
class SeededRandom {
  int _state;

  SeededRandom(int seed) : _state = _mix(seed) == 0 ? 0x9E3779B9 : _mix(seed);

  /// Derives a well-mixed seed from several integer components.
  static int seedFrom(List<int> parts) {
    var h = 0x811C9DC5;
    for (final p in parts) {
      var v = p.toUnsigned(32);
      for (var i = 0; i < 4; i++) {
        h = (h ^ (v & 0xFF)).toUnsigned(32);
        h = _mul32(h, 0x01000193);
        v = v >> 8;
      }
    }
    return h == 0 ? 0x2545F491 : h;
  }

  static int _mix(int seed) {
    var x = seed.toUnsigned(32);
    x = ((x ^ (x >> 16)) & 0xFFFFFFFF);
    x = _mul32(x, 0x45D9F3B);
    x = ((x ^ (x >> 16)) & 0xFFFFFFFF);
    return x.toUnsigned(32);
  }

  /// 32-bit multiply that stays exact on the web (53-bit doubles).
  static int _mul32(int a, int b) {
    final aLo = a & 0xFFFF;
    final aHi = (a >> 16) & 0xFFFF;
    final lo = aLo * b;
    final hi = (aHi * b) & 0xFFFF;
    return (lo + (hi << 16)).toUnsigned(32);
  }

  int nextUint32() {
    var x = _state;
    x = (x ^ (x << 13)).toUnsigned(32);
    x = (x ^ (x >> 17)).toUnsigned(32);
    x = (x ^ (x << 5)).toUnsigned(32);
    _state = x;
    return x;
  }

  /// Uniform integer in `[0, max)`.
  int nextInt(int max) {
    assert(max > 0);
    return nextUint32() % max;
  }

  /// Uniform double in `[0, 1)`.
  double nextDouble() => nextUint32() / 4294967296.0;

  bool nextBool([double probability = 0.5]) => nextDouble() < probability;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  /// In-place Fisher–Yates shuffle.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }
}
