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

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7A5CFA),
      brightness: Brightness.light,
    ).copyWith(surface: AppColors.cream);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: null,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
            fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -0.5),
        headlineSmall:
            TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyMedium: TextStyle(color: AppColors.inkSoft),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
