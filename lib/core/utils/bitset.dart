import 'dart:typed_data';

/// Immutable fixed-size bit set backed by 32-bit words (web-safe).
///
/// Used to represent which tiles have been removed. Supports value equality
/// and hashing so board states can be memoised by the solver.
class BitSet {
  final int length;
  final Uint32List _words;
  final int _hash;

  BitSet._(this.length, this._words) : _hash = _computeHash(_words);

  factory BitSet.empty(int length) =>
      BitSet._(length, Uint32List((length + 31) >> 5));

  factory BitSet.fromIndices(int length, Iterable<int> indices) {
    final words = Uint32List((length + 31) >> 5);
    for (final i in indices) {
      RangeError.checkValueInInterval(i, 0, length - 1);
      words[i >> 5] |= 1 << (i & 31);
    }
    return BitSet._(length, words);
  }

  static int _computeHash(Uint32List words) {
    var h = 17;
    for (final w in words) {
      h = (h * 31 + w) & 0x3FFFFFFF;
    }
    return h;
  }

  bool operator [](int i) => (_words[i >> 5] & (1 << (i & 31))) != 0;

  BitSet withBit(int i) {
    if (this[i]) return this;
    final w = Uint32List.fromList(_words);
    w[i >> 5] |= 1 << (i & 31);
    return BitSet._(length, w);
  }

  BitSet withBits(Iterable<int> indices) {
    final w = Uint32List.fromList(_words);
    for (final i in indices) {
      w[i >> 5] |= 1 << (i & 31);
    }
    return BitSet._(length, w);
  }

  BitSet withoutBits(Iterable<int> indices) {
    final w = Uint32List.fromList(_words);
    for (final i in indices) {
      w[i >> 5] &= ~(1 << (i & 31));
    }
    return BitSet._(length, w);
  }

  int get count {
    var c = 0;
    for (var w in _words) {
      while (w != 0) {
        w &= w - 1;
        c++;
      }
    }
    return c;
  }

  bool get isFull => count == length;

  Iterable<int> get setIndices sync* {
    for (var i = 0; i < length; i++) {
      if (this[i]) yield i;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! BitSet || other.length != length || other._hash != _hash) {
      return false;
    }
    for (var i = 0; i < _words.length; i++) {
      if (_words[i] != other._words[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => _hash;

  @override
  String toString() => 'BitSet(${setIndices.toList()})';
}
