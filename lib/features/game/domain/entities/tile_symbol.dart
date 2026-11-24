/// Visual themes for tile collections.
enum TileTheme {
  fruits('Fruit Market'),
  animals('Animal Friends'),
  sweets('Sweet Shop'),
  garden('Secret Garden'),
  ocean('Deep Blue'),
  fantasy('Fantasy Realm'),
  objects('Everyday Treasures');

  final String displayName;
  const TileTheme(this.displayName);
}

/// A tile face. [id] is the stable symbol ID used for matching – it is the
/// index in [TileCatalog.all] and must never be reordered (append only).
class TileSymbol {
  final int id;
  final String key;
  final String glyph;
  final TileTheme theme;

  /// ARGB accent colour used for the tile's subtle tint.
  final int accent;

  const TileSymbol(this.id, this.key, this.glyph, this.theme, this.accent);
}

/// The master tile collection.
///
/// Glyphs are colour emoji so the game ships with a large, consistent and
/// high-resolution illustration set on every platform. Rendering is isolated
/// in the presentation layer, so the glyphs can be replaced by bespoke image
/// assets without touching any game logic (which only compares [TileSymbol.id]).
class TileCatalog {
  const TileCatalog._();

  static const List<TileSymbol> all = [
    // FRUITS
    TileSymbol(0, 'apple', '🍎', TileTheme.fruits, 0xFFE53935),
    TileSymbol(1, 'banana', '🍌', TileTheme.fruits, 0xFFFDD835),
    TileSymbol(2, 'orange', '🍊', TileTheme.fruits, 0xFFFB8C00),
    TileSymbol(3, 'grapes', '🍇', TileTheme.fruits, 0xFF8E24AA),
    TileSymbol(4, 'watermelon', '🍉', TileTheme.fruits, 0xFF43A047),
    TileSymbol(5, 'strawberry', '🍓', TileTheme.fruits, 0xFFD81B60),
    TileSymbol(6, 'pineapple', '🍍', TileTheme.fruits, 0xFFFBC02D),
    TileSymbol(7, 'cherry', '🍒', TileTheme.fruits, 0xFFC62828),
    TileSymbol(8, 'kiwi', '🥝', TileTheme.fruits, 0xFF7CB342),
    TileSymbol(9, 'lemon', '🍋', TileTheme.fruits, 0xFFFFEE58),
    TileSymbol(10, 'peach', '🍑', TileTheme.fruits, 0xFFFF8A65),
    TileSymbol(11, 'coconut', '🥥', TileTheme.fruits, 0xFF795548),
    TileSymbol(12, 'pear', '🍐', TileTheme.fruits, 0xFFC0CA33),
    // ANIMALS
    TileSymbol(13, 'cat', '🐱', TileTheme.animals, 0xFFFFB74D),
    TileSymbol(14, 'dog', '🐶', TileTheme.animals, 0xFFA1887F),
    TileSymbol(15, 'rabbit', '🐰', TileTheme.animals, 0xFFF8BBD0),
    TileSymbol(16, 'panda', '🐼', TileTheme.animals, 0xFF616161),
    TileSymbol(17, 'elephant', '🐘', TileTheme.animals, 0xFF90A4AE),
    TileSymbol(18, 'lion', '🦁', TileTheme.animals, 0xFFFFA726),
    TileSymbol(19, 'fox', '🦊', TileTheme.animals, 0xFFF4511E),
    TileSymbol(20, 'bear', '🐻', TileTheme.animals, 0xFF8D6E63),
    TileSymbol(21, 'frog', '🐸', TileTheme.animals, 0xFF66BB6A),
    TileSymbol(22, 'pig', '🐷', TileTheme.animals, 0xFFF48FB1),
    TileSymbol(23, 'monkey', '🐵', TileTheme.animals, 0xFFA1887F),
    TileSymbol(24, 'chick', '🐥', TileTheme.animals, 0xFFFFEB3B),
    TileSymbol(25, 'owl', '🦉', TileTheme.animals, 0xFF8D6E63),
    // SWEETS / FOOD
    TileSymbol(26, 'cake', '🎂', TileTheme.sweets, 0xFFF06292),
    TileSymbol(27, 'cupcake', '🧁', TileTheme.sweets, 0xFFBA68C8),
    TileSymbol(28, 'pizza', '🍕', TileTheme.sweets, 0xFFFFA000),
    TileSymbol(29, 'donut', '🍩', TileTheme.sweets, 0xFFEC407A),
    TileSymbol(30, 'burger', '🍔', TileTheme.sweets, 0xFFA1887F),
    TileSymbol(31, 'ice_cream', '🍦', TileTheme.sweets, 0xFFFFE0B2),
    TileSymbol(32, 'cookie', '🍪', TileTheme.sweets, 0xFFBCAAA4),
    TileSymbol(33, 'lollipop', '🍭', TileTheme.sweets, 0xFFE040FB),
    TileSymbol(34, 'chocolate', '🍫', TileTheme.sweets, 0xFF6D4C41),
    TileSymbol(35, 'croissant', '🥐', TileTheme.sweets, 0xFFFFCC80),
    TileSymbol(36, 'popcorn', '🍿', TileTheme.sweets, 0xFFEF5350),
    TileSymbol(37, 'candy', '🍬', TileTheme.sweets, 0xFF4FC3F7),
    TileSymbol(38, 'pretzel', '🥨', TileTheme.sweets, 0xFF8D6E63),
    // GARDEN / NATURE
    TileSymbol(39, 'blossom', '🌸', TileTheme.garden, 0xFFF8BBD0),
    TileSymbol(40, 'leaf', '🍁', TileTheme.garden, 0xFFE64A19),
    TileSymbol(41, 'mushroom', '🍄', TileTheme.garden, 0xFFE53935),
    TileSymbol(42, 'sun', '☀️', TileTheme.garden, 0xFFFFC107),
    TileSymbol(43, 'moon', '🌙', TileTheme.garden, 0xFFFFD54F),
    TileSymbol(44, 'cloud', '☁️', TileTheme.garden, 0xFF90CAF9),
    TileSymbol(45, 'butterfly', '🦋', TileTheme.garden, 0xFF42A5F5),
    TileSymbol(46, 'sunflower', '🌻', TileTheme.garden, 0xFFFDD835),
    TileSymbol(47, 'cactus', '🌵', TileTheme.garden, 0xFF43A047),
    TileSymbol(48, 'rainbow', '🌈', TileTheme.garden, 0xFFAB47BC),
    TileSymbol(49, 'ladybug', '🐞', TileTheme.garden, 0xFFD32F2F),
    TileSymbol(50, 'tulip', '🌷', TileTheme.garden, 0xFFEC407A),
    TileSymbol(51, 'clover', '🍀', TileTheme.garden, 0xFF2E7D32),
    TileSymbol(52, 'bee', '🐝', TileTheme.garden, 0xFFFFB300),
    // OCEAN
    TileSymbol(53, 'fish', '🐠', TileTheme.ocean, 0xFF29B6F6),
    TileSymbol(54, 'octopus', '🐙', TileTheme.ocean, 0xFFEC407A),
    TileSymbol(55, 'crab', '🦀', TileTheme.ocean, 0xFFE53935),
    TileSymbol(56, 'whale', '🐳', TileTheme.ocean, 0xFF1E88E5),
    TileSymbol(57, 'dolphin', '🐬', TileTheme.ocean, 0xFF4FC3F7),
    TileSymbol(58, 'shell', '🐚', TileTheme.ocean, 0xFFFFCCBC),
    TileSymbol(59, 'shark', '🦈', TileTheme.ocean, 0xFF78909C),
    TileSymbol(60, 'turtle', '🐢', TileTheme.ocean, 0xFF66BB6A),
    TileSymbol(61, 'anchor', '⚓', TileTheme.ocean, 0xFF37474F),
    TileSymbol(62, 'wave', '🌊', TileTheme.ocean, 0xFF0288D1),
    TileSymbol(63, 'sailboat', '⛵', TileTheme.ocean, 0xFF5C6BC0),
    TileSymbol(64, 'blowfish', '🐡', TileTheme.ocean, 0xFFFFCA28),
    // FANTASY
    TileSymbol(65, 'unicorn', '🦄', TileTheme.fantasy, 0xFFCE93D8),
    TileSymbol(66, 'dragon', '🐉', TileTheme.fantasy, 0xFF43A047),
    TileSymbol(67, 'crystal_ball', '🔮', TileTheme.fantasy, 0xFF7E57C2),
    TileSymbol(68, 'castle', '🏰', TileTheme.fantasy, 0xFF8D6E63),
    TileSymbol(69, 'swords', '⚔️', TileTheme.fantasy, 0xFF78909C),
    TileSymbol(70, 'gem', '💎', TileTheme.fantasy, 0xFF4FC3F7),
    TileSymbol(71, 'scroll', '📜', TileTheme.fantasy, 0xFFD7CCC8),
    TileSymbol(72, 'potion', '🧪', TileTheme.fantasy, 0xFF66BB6A),
    TileSymbol(73, 'shield', '🛡️', TileTheme.fantasy, 0xFF5C6BC0),
    TileSymbol(74, 'ghost', '👻', TileTheme.fantasy, 0xFFB0BEC5),
    TileSymbol(75, 'pumpkin', '🎃', TileTheme.fantasy, 0xFFFF7043),
    TileSymbol(76, 'volcano', '🌋', TileTheme.fantasy, 0xFFD84315),
    // OBJECTS
    TileSymbol(77, 'star', '⭐', TileTheme.objects, 0xFFFFC107),
    TileSymbol(78, 'balloon', '🎈', TileTheme.objects, 0xFFE53935),
    TileSymbol(79, 'gift', '🎁', TileTheme.objects, 0xFFEC407A),
    TileSymbol(80, 'crown', '👑', TileTheme.objects, 0xFFFFB300),
    TileSymbol(81, 'bell', '🔔', TileTheme.objects, 0xFFFFCA28),
    TileSymbol(82, 'key', '🔑', TileTheme.objects, 0xFFFFA000),
    TileSymbol(83, 'heart', '❤️', TileTheme.objects, 0xFFE53935),
    TileSymbol(84, 'alarm', '⏰', TileTheme.objects, 0xFFEF5350),
    TileSymbol(85, 'music', '🎵', TileTheme.objects, 0xFF5C6BC0),
    TileSymbol(86, 'books', '📚', TileTheme.objects, 0xFF26A69A),
    TileSymbol(87, 'palette', '🎨', TileTheme.objects, 0xFFFFB74D),
    TileSymbol(88, 'teddy', '🧸', TileTheme.objects, 0xFFA1887F),
    TileSymbol(89, 'umbrella', '☂️', TileTheme.objects, 0xFF7E57C2),
    TileSymbol(90, 'bulb', '💡', TileTheme.objects, 0xFFFFEE58),
    TileSymbol(91, 'ribbon', '🎀', TileTheme.objects, 0xFFF06292),
  ];

  static TileSymbol byId(int id) => all[id];

  static List<TileSymbol> ofTheme(TileTheme theme) =>
      all.where((s) => s.theme == theme).toList(growable: false);

  /// Returns [size] distinct symbol IDs, filling from [primary] first and then
  /// from the remaining themes in a fixed rotation.
  static List<int> pool(TileTheme primary, int size) {
    final ids = <int>[for (final s in ofTheme(primary)) s.id];
    var t = primary.index;
    while (ids.length < size) {
      t = (t + 1) % TileTheme.values.length;
      if (t == primary.index) break;
      ids.addAll(ofTheme(TileTheme.values[t]).map((s) => s.id));
    }
    return ids.take(size).toList();
  }
}
