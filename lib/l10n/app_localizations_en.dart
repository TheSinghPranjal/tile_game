// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tile Grove';

  @override
  String get tagline => 'Find the pairs. Clear the grove.';

  @override
  String playLevel(int level) {
    return 'Play Level $level';
  }

  @override
  String continueLevel(int level) {
    return 'Continue Level $level';
  }

  @override
  String replayLevel(int level) {
    return 'Replay Level $level';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'Level $level of $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return 'All $total levels cleared!';
  }

  @override
  String get menuLevels => 'Levels';

  @override
  String get menuAwards => 'Awards';

  @override
  String get menuSettings => 'Settings';

  @override
  String get homeInfo =>
      'Tap two identical FREE tiles to clear them. A tile is free when nothing sits on top of it and its left or right side is open. Long-press any tile to see what is blocking it.';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get back => 'Back';

  @override
  String get pauseAndSettings => 'Pause & settings';

  @override
  String tilesLeft(int count) {
    return '$count tiles left';
  }

  @override
  String get restartLevelTitle => 'Restart level?';

  @override
  String get restartLevelBody =>
      'Your current progress on this board will be lost.';

  @override
  String get cancel => 'Cancel';

  @override
  String get restart => 'Restart';

  @override
  String get arrangingTiles => 'Arranging tiles…';

  @override
  String get buildError => 'Something went wrong building this board.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get boardCleared => 'Board Cleared!';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'Level $level · $difficulty';
  }

  @override
  String get threeStarTip =>
      'Clear it without Hint, Shuffle or Magic for 3 stars';

  @override
  String get newBest => 'New best!';

  @override
  String achievementUnlocked(String title) {
    return 'Achievement: $title';
  }

  @override
  String get finishJourney => 'Finish the journey';

  @override
  String get replay => 'Replay';

  @override
  String get home => 'Home';

  @override
  String get noMatchesTitle => 'No matches left';

  @override
  String get noMatchesBody =>
      'None of the free tiles match right now. A free shuffle will re-deal the remaining tiles into a board that is guaranteed to be clearable.';

  @override
  String get undo => 'Undo';

  @override
  String get freeShuffle => 'Free shuffle';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels levels cleared · $stars ★ · $matches matches';
  }

  @override
  String get play => 'PLAY';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'Locked';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAudio => 'Sound & vibration';

  @override
  String get music => 'Music';

  @override
  String get musicSubtitle => 'Relaxing background melody';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsSubtitle => 'Taps, matches and celebrations';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Gentle haptic feedback';

  @override
  String get sectionDisplay => 'Display';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get dimBlocked => 'Dim blocked tiles';

  @override
  String get dimBlockedSubtitle => 'Make free tiles easier to spot';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get reduceMotionSubtitle => 'Fewer animations and particles';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get sectionHelp => 'Help';

  @override
  String get howToPlay => 'How to play';

  @override
  String get howToPlaySubtitle => 'Rules, boosters and stars';

  @override
  String get allSettings => 'All settings';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current of $total';
  }

  @override
  String get htpTitle1 => 'Match pairs';

  @override
  String get htpBody1 =>
      'Tap two tiles with the same picture to clear them. Clear every tile to win the level.';

  @override
  String get htpTitle2 => 'Only free tiles';

  @override
  String get htpBody2 =>
      'A tile is free when nothing sits on top of it and its left or right side is open. Blocked tiles can\'t be picked.';

  @override
  String get htpFree => 'Free';

  @override
  String get htpBlocked => 'Blocked';

  @override
  String get htpTitle3 => 'Peek under the pile';

  @override
  String get htpBody3 =>
      'Long-press any tile to see which tiles are blocking it. Plan ahead to free the tiles you need.';

  @override
  String get htpTitle4 => 'Boosters';

  @override
  String get htpBody4 => 'Every level gives you a fresh set of boosters.';

  @override
  String get boosterHintDesc => 'Shows a pair you can match.';

  @override
  String get boosterUndoDesc => 'Takes back your last match. Always free.';

  @override
  String get boosterShuffleDesc =>
      'Re-deals the remaining tiles into a solvable board.';

  @override
  String get boosterMagicDesc =>
      'Tap a free tile and it matches with its twin automatically.';

  @override
  String get htpTitle5 => 'Earn stars';

  @override
  String htpBody5(int total) {
    return 'Clear a board without Hint, Shuffle or Magic for 3 stars. Every one of the $total levels can be solved.';
  }

  @override
  String get htpNext => 'Next';

  @override
  String get htpBack => 'Back';

  @override
  String get htpDone => 'Let\'s play!';

  @override
  String get htpSkip => 'Skip';

  @override
  String get msgTileFree => 'This tile is free to match!';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'No $booster left on this level.';
  }

  @override
  String get msgNoWinningMoves =>
      'No winning moves from here — try Undo or Shuffle.';

  @override
  String get msgNothingToUndo => 'Nothing to undo yet.';

  @override
  String get msgCantShuffle =>
      'These tiles can\'t be rearranged into a winnable board — try Undo.';

  @override
  String get msgMagicArmed => 'Tap any free tile to auto-match it.';

  @override
  String get msgTwinNotFree => 'Its twin isn\'t free yet — try another tile.';

  @override
  String get boosterHint => 'Hint';

  @override
  String get boosterUndo => 'Undo';

  @override
  String get boosterShuffle => 'Shuffle';

  @override
  String get boosterMagic => 'Magic';

  @override
  String get tierBeginner => 'Beginner';

  @override
  String get tierApprentice => 'Apprentice';

  @override
  String get tierAdept => 'Adept';

  @override
  String get tierExpert => 'Expert';

  @override
  String get tierMaster => 'Master';

  @override
  String get tierLegend => 'Legend';

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffMedium => 'Medium';

  @override
  String get diffHard => 'Hard';

  @override
  String get diffExpert => 'Expert';

  @override
  String get layoutSmallRectangle => 'Little Box';

  @override
  String get layoutLargeRectangle => 'Grand Hall';

  @override
  String get layoutPyramid => 'Pyramid';

  @override
  String get layoutDoublePyramid => 'Twin Peaks';

  @override
  String get layoutDiamond => 'Diamond';

  @override
  String get layoutCross => 'Cross';

  @override
  String get layoutButterfly => 'Butterfly';

  @override
  String get layoutFlower => 'Flower';

  @override
  String get layoutCircle => 'Ring';

  @override
  String get layoutStaircase => 'Staircase';

  @override
  String get layoutZigzag => 'Zigzag';

  @override
  String get layoutLayeredSquare => 'Layer Cake';

  @override
  String get layoutAsymmetricTower => 'Lighthouse';

  @override
  String get layoutClusters => 'Islands';

  @override
  String get layoutComplex => 'Fortress';

  @override
  String get layoutProcedural => 'Wilds';

  @override
  String get layoutPile => 'Treasure Pile';

  @override
  String get layoutShape => 'Picture';

  @override
  String shapeLetter(String name) {
    return 'Letter $name';
  }

  @override
  String shapeNumber(String name) {
    return 'Number $name';
  }

  @override
  String get shapeLittleHeart => 'Little Heart';

  @override
  String get shapePlus => 'Plus';

  @override
  String get shapeLittleHouse => 'Little House';

  @override
  String get shapeLittleFish => 'Little Fish';

  @override
  String get shapeCat => 'Cat';

  @override
  String get shapeBunny => 'Bunny';

  @override
  String get shapeOwl => 'Owl';

  @override
  String get shapeFish => 'Fish';

  @override
  String get shapeTurtle => 'Turtle';

  @override
  String get shapeCrab => 'Crab';

  @override
  String get shapeBear => 'Bear';

  @override
  String get shapeDuck => 'Duck';

  @override
  String get shapeButterfly => 'Butterfly';

  @override
  String get shapeSnail => 'Snail';

  @override
  String get shapeHeart => 'Heart';

  @override
  String get shapeStar => 'Star';

  @override
  String get shapeHouse => 'House';

  @override
  String get shapeTree => 'Tree';

  @override
  String get shapeMushroom => 'Mushroom';

  @override
  String get shapeUmbrella => 'Umbrella';

  @override
  String get shapeBell => 'Bell';

  @override
  String get shapeCrown => 'Crown';

  @override
  String get shapeGem => 'Gem';

  @override
  String get shapeRocket => 'Rocket';

  @override
  String get shapeAnchor => 'Anchor';

  @override
  String get shapeApple => 'Apple';

  @override
  String get shapeHourglass => 'Hourglass';

  @override
  String get shapeSailboat => 'Sailboat';

  @override
  String get shapeSun => 'Sun';

  @override
  String get shapeSpade => 'Spade';

  @override
  String get shapeKey => 'Key';

  @override
  String get shapeCup => 'Cup';

  @override
  String get themeFruits => 'Fruit Market';

  @override
  String get themeAnimals => 'Animal Friends';

  @override
  String get themeSweets => 'Sweet Shop';

  @override
  String get themeGarden => 'Secret Garden';

  @override
  String get themeOcean => 'Deep Blue';

  @override
  String get themeFantasy => 'Fantasy Realm';

  @override
  String get themeObjects => 'Everyday Treasures';

  @override
  String get achFirstClearTitle => 'First Bloom';

  @override
  String get achFirstClearDesc => 'Clear your first board.';

  @override
  String get achTenLevelsTitle => 'Rising Star';

  @override
  String get achTenLevelsDesc => 'Clear 10 levels.';

  @override
  String get achFiftyLevelsTitle => 'Tile Master';

  @override
  String get achFiftyLevelsDesc => 'Clear 50 levels.';

  @override
  String get achHundredLevelsTitle => 'Grove Legend';

  @override
  String get achHundredLevelsDesc => 'Clear 100 levels.';

  @override
  String get achPerfectTenTitle => 'Perfectionist';

  @override
  String get achPerfectTenDesc => 'Earn 3 stars on 10 levels.';

  @override
  String get achSpeedsterTitle => 'Speedster';

  @override
  String get achSpeedsterDesc => 'Clear a board in under 60 seconds.';

  @override
  String get achThousandMatchesTitle => 'Collector';

  @override
  String get achThousandMatchesDesc => 'Make 1,000 matches.';

  @override
  String get achPureSkillTitle => 'Pure Skill';

  @override
  String get achPureSkillDesc => 'Clear a 4+ layer board without boosters.';
}
