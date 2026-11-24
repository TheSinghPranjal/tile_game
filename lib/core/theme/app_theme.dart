import 'package:flutter/material.dart';

import '../../features/game/domain/entities/tile_symbol.dart';

class AppColors {
  const AppColors._();

  static const ink = Color(0xFF2B2541);
  static const inkSoft = Color(0xFF6E6787);
  static const cream = Color(0xFFFFFBF2);
  static const tileFace = Color(0xFFFFFCF5);
  static const tileFaceShade = Color(0xFFF1E9D8);
  static const tileSide = Color(0xFFD9C9A8);
  static const tileSideDark = Color(0xFFBFA982);
  static const gold = Color(0xFFFFB627);
  static const goldDeep = Color(0xFFE89B00);
  static const hint = Color(0xFF2EC4B6);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF3CB371);
  static const panel = Color(0xF2FFFFFF);
}

/// Background palettes per tile theme.
class ThemeBackdrop {
  final List<Color> gradient;
  final Color accent;
  final IconData icon;
  const ThemeBackdrop(this.gradient, this.accent, this.icon);

  static ThemeBackdrop of(TileTheme t) => switch (t) {
        TileTheme.fruits => const ThemeBackdrop(
            [Color(0xFFFFE3C8), Color(0xFFFFB199)],
            Color(0xFFFF7A59),
            Icons.local_florist_rounded),
        TileTheme.animals => const ThemeBackdrop(
            [Color(0xFFD9F7E8), Color(0xFF8FD9C2)],
            Color(0xFF2BA58A),
            Icons.pets_rounded),
        TileTheme.sweets => const ThemeBackdrop(
            [Color(0xFFFFE1F0), Color(0xFFD9B8FF)],
            Color(0xFFD45FB0),
            Icons.cake_rounded),
        TileTheme.garden => const ThemeBackdrop(
            [Color(0xFFEAF8D2), Color(0xFFA8D98A)],
            Color(0xFF5E9E3A),
            Icons.yard_rounded),
        TileTheme.ocean => const ThemeBackdrop(
            [Color(0xFFD3F0FF), Color(0xFF7CB8F2)],
            Color(0xFF2C7BD6),
            Icons.waves_rounded),
        TileTheme.fantasy => const ThemeBackdrop(
            [Color(0xFFE7DBFF), Color(0xFF9C86E8)],
            Color(0xFF6C4FD1),
            Icons.auto_awesome_rounded),
        TileTheme.objects => const ThemeBackdrop(
            [Color(0xFFFFF3C4), Color(0xFFFFCE7A)],
            Color(0xFFE0962B),
            Icons.star_rounded),
      };
}

/// Rounded display face matching the garden artwork (variable font, so the
/// weight is applied through the `wght` axis).
TextStyle fredoka(double size, double weight, Color color, {double? height}) =>
    TextStyle(
      fontFamily: 'Fredoka',
      fontSize: size,
      fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      height: height,
    );

/// Semantic colours that differ between light and dark mode. Widgets read
/// these through `context.palette` instead of hard-coding colours.
@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  /// Floating panels (top bar, info card, round buttons).
  final Color panel;

  /// Primary text / icons on panels.
  final Color onPanel;

  /// Secondary text on panels.
  final Color onPanelMuted;

  /// Hairlines and dividers on panels.
  final Color divider;

  /// Tint laid over the painted backgrounds (transparent in light mode).
  final Color backdropScrim;

  /// Tile face gradient (top, bottom).
  final Color tileFaceTop;
  final Color tileFaceBottom;

  const GamePalette({
    required this.panel,
    required this.onPanel,
    required this.onPanelMuted,
    required this.divider,
    required this.backdropScrim,
    required this.tileFaceTop,
    required this.tileFaceBottom,
  });

  static const light = GamePalette(
    panel: Color(0xF2FFFFFF),
    onPanel: Color(0xFF4A1C7A),
    onPanelMuted: Color(0xFF8A7F99),
    divider: Color(0xFFD9D0E4),
    backdropScrim: Color(0x00000000),
    tileFaceTop: Color(0xFFFFFEFA),
    tileFaceBottom: Color(0xFFF7EFE2),
  );

  static const dark = GamePalette(
    panel: Color(0xF0251D36),
    onPanel: Color(0xFFE7DCFF),
    onPanelMuted: Color(0xFFA99DC2),
    divider: Color(0xFF41365A),
    backdropScrim: Color(0x990B0820),
    tileFaceTop: Color(0xFFEDE7DA),
    tileFaceBottom: Color(0xFFDCD3C2),
  );

  @override
  GamePalette copyWith({
    Color? panel,
    Color? onPanel,
    Color? onPanelMuted,
    Color? divider,
    Color? backdropScrim,
    Color? tileFaceTop,
    Color? tileFaceBottom,
  }) =>
      GamePalette(
        panel: panel ?? this.panel,
        onPanel: onPanel ?? this.onPanel,
        onPanelMuted: onPanelMuted ?? this.onPanelMuted,
        divider: divider ?? this.divider,
        backdropScrim: backdropScrim ?? this.backdropScrim,
        tileFaceTop: tileFaceTop ?? this.tileFaceTop,
        tileFaceBottom: tileFaceBottom ?? this.tileFaceBottom,
      );

  @override
  GamePalette lerp(GamePalette? other, double t) {
    if (other == null) return this;
    return GamePalette(
      panel: Color.lerp(panel, other.panel, t)!,
      onPanel: Color.lerp(onPanel, other.onPanel, t)!,
      onPanelMuted: Color.lerp(onPanelMuted, other.onPanelMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      backdropScrim: Color.lerp(backdropScrim, other.backdropScrim, t)!,
      tileFaceTop: Color.lerp(tileFaceTop, other.tileFaceTop, t)!,
      tileFaceBottom: Color.lerp(tileFaceBottom, other.tileFaceBottom, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  GamePalette get palette =>
      Theme.of(this).extension<GamePalette>() ?? GamePalette.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A5CFA),
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.cream,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.inkSoft,
        ),
        GamePalette.light,
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A5CFA),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF1B1626),
          surfaceContainerHighest: const Color(0xFF2C2440),
          onSurface: const Color(0xFFF1EBFF),
          onSurfaceVariant: const Color(0xFFB6ABCB),
        ),
        GamePalette.dark,
      );

  static ThemeData _build(ColorScheme scheme, GamePalette palette) {
    final on = scheme.onSurface;
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: on,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        displaySmall: TextStyle(
            fontWeight: FontWeight.w900, color: on, letterSpacing: -0.5),
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: on),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: on),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: on),
        bodyMedium: TextStyle(color: scheme.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF3A3052)
            : AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
