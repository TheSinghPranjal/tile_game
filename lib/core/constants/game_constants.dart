/// Global gameplay tuning values.
class GameConstants {
  const GameConstants._();

  static const String appName = 'Tile Grove';

  /// Size of the campaign.
  static const int totalLevels = 1000;

  // Animation timings.
  static const Duration selectDuration = Duration(milliseconds: 140);
  static const Duration removeDuration = Duration(milliseconds: 300);
  static const Duration shakeDuration = Duration(milliseconds: 360);
  static const Duration revealDuration = Duration(milliseconds: 600);
  static const Duration burstDuration = Duration(milliseconds: 650);
  static const Duration hintDuration = Duration(milliseconds: 2600);
  static const Duration blockerInspectDuration = Duration(milliseconds: 1800);
  static const Duration completionDelay = Duration(milliseconds: 450);

  // Board rendering (fractions of one tile width).
  static const double tileAspect = 1.06; // height / width
  static const double layerShiftX = 0.0;
  static const double layerShiftY = -0.045;
  static const double tileGap = 0.025;
  static const double tileThickness = 0.12;

  /// Horizontal share of the 3D edge (the rest shows along the bottom).
  static const double tileSideRatio = 0.0;
  static const double minTileWidth = 34;
  static const double maxTileWidth = 58;
}
