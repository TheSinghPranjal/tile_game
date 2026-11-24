import 'package:flutter/widgets.dart';

import '../../features/achievements/domain/achievements.dart';
import '../../features/boosters/domain/booster.dart';
import '../../features/game/domain/entities/tile_symbol.dart';
import '../../features/game/presentation/controllers/game_view_state.dart';
import '../../features/levels/domain/layout_templates.dart';
import '../../features/levels/domain/level_config.dart';
import '../../features/levels/domain/shape_library.dart';
import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Translations for values that come from the (language-neutral) domain.
extension DomainL10n on AppLocalizations {
  String tier(DifficultyTier t) => switch (t) {
        DifficultyTier.beginner => tierBeginner,
        DifficultyTier.apprentice => tierApprentice,
        DifficultyTier.adept => tierAdept,
        DifficultyTier.expert => tierExpert,
        DifficultyTier.master => tierMaster,
        DifficultyTier.legend => tierLegend,
      };

  String theme(TileTheme t) => switch (t) {
        TileTheme.fruits => themeFruits,
        TileTheme.animals => themeAnimals,
        TileTheme.sweets => themeSweets,
        TileTheme.garden => themeGarden,
        TileTheme.ocean => themeOcean,
        TileTheme.fantasy => themeFantasy,
        TileTheme.objects => themeObjects,
      };

  String booster(BoosterType t) => switch (t) {
        BoosterType.hint => boosterHint,
        BoosterType.undo => boosterUndo,
        BoosterType.shuffle => boosterShuffle,
        BoosterType.magic => boosterMagic,
      };

  String boosterDescription(BoosterType t) => switch (t) {
        BoosterType.hint => boosterHintDesc,
        BoosterType.undo => boosterUndoDesc,
        BoosterType.shuffle => boosterShuffleDesc,
        BoosterType.magic => boosterMagicDesc,
      };

  /// [label] is the English label from `DifficultyReport.label`.
  String difficulty(String label) => switch (label) {
        'Easy' => diffEasy,
        'Medium' => diffMedium,
        'Hard' => diffHard,
        'Expert' => diffExpert,
        _ => label,
      };

  String achievementTitle(Achievement a) => switch (a) {
        Achievement.firstClear => achFirstClearTitle,
        Achievement.tenLevels => achTenLevelsTitle,
        Achievement.fiftyLevels => achFiftyLevelsTitle,
        Achievement.hundredLevels => achHundredLevelsTitle,
        Achievement.perfectTen => achPerfectTenTitle,
        Achievement.speedster => achSpeedsterTitle,
        Achievement.thousandMatches => achThousandMatchesTitle,
        Achievement.pureSkill => achPureSkillTitle,
      };

  String achievementDescription(Achievement a) => switch (a) {
        Achievement.firstClear => achFirstClearDesc,
        Achievement.tenLevels => achTenLevelsDesc,
        Achievement.fiftyLevels => achFiftyLevelsDesc,
        Achievement.hundredLevels => achHundredLevelsDesc,
        Achievement.perfectTen => achPerfectTenDesc,
        Achievement.speedster => achSpeedsterDesc,
        Achievement.thousandMatches => achThousandMatchesDesc,
        Achievement.pureSkill => achPureSkillDesc,
      };

  String message(GameToast t) => switch (t.message) {
        GameMessage.tileFree => msgTileFree,
        GameMessage.noBoosterLeft =>
          msgNoBoosterLeft(t.booster == null ? '' : booster(t.booster!)),
        GameMessage.noWinningMoves => msgNoWinningMoves,
        GameMessage.nothingToUndo => msgNothingToUndo,
        GameMessage.cantShuffle => msgCantShuffle,
        GameMessage.magicArmed => msgMagicArmed,
        GameMessage.twinNotFree => msgTwinNotFree,
      };

  String template(LayoutTemplate t) => switch (t) {
        LayoutTemplate.smallRectangle => layoutSmallRectangle,
        LayoutTemplate.largeRectangle => layoutLargeRectangle,
        LayoutTemplate.pyramid => layoutPyramid,
        LayoutTemplate.doublePyramid => layoutDoublePyramid,
        LayoutTemplate.diamond => layoutDiamond,
        LayoutTemplate.cross => layoutCross,
        LayoutTemplate.butterfly => layoutButterfly,
        LayoutTemplate.flower => layoutFlower,
        LayoutTemplate.circle => layoutCircle,
        LayoutTemplate.staircase => layoutStaircase,
        LayoutTemplate.zigzag => layoutZigzag,
        LayoutTemplate.layeredSquare => layoutLayeredSquare,
        LayoutTemplate.asymmetricTower => layoutAsymmetricTower,
        LayoutTemplate.clusters => layoutClusters,
        LayoutTemplate.complex => layoutComplex,
        LayoutTemplate.procedural => layoutProcedural,
        LayoutTemplate.pile => layoutPile,
        LayoutTemplate.shape => layoutShape,
      };

  String shape(ShapeArt art) => switch (art.category) {
        ShapeCategory.letter => shapeLetter(art.name),
        ShapeCategory.number => shapeNumber(art.name),
        _ => _shapeNames[art.name] ?? art.name,
      };

  Map<String, String> get _shapeNames => {
        'Little Heart': shapeLittleHeart,
        'Plus': shapePlus,
        'Little House': shapeLittleHouse,
        'Little Fish': shapeLittleFish,
        'Cat': shapeCat,
        'Bunny': shapeBunny,
        'Owl': shapeOwl,
        'Fish': shapeFish,
        'Turtle': shapeTurtle,
        'Crab': shapeCrab,
        'Bear': shapeBear,
        'Duck': shapeDuck,
        'Butterfly': shapeButterfly,
        'Snail': shapeSnail,
        'Heart': shapeHeart,
        'Star': shapeStar,
        'House': shapeHouse,
        'Tree': shapeTree,
        'Mushroom': shapeMushroom,
        'Umbrella': shapeUmbrella,
        'Bell': shapeBell,
        'Crown': shapeCrown,
        'Gem': shapeGem,
        'Rocket': shapeRocket,
        'Anchor': shapeAnchor,
        'Apple': shapeApple,
        'Hourglass': shapeHourglass,
        'Sailboat': shapeSailboat,
        'Sun': shapeSun,
        'Spade': shapeSpade,
        'Key': shapeKey,
        'Cup': shapeCup,
        'Leaf': shapeLeaf,
        'Drop': shapeDrop,
        'Arrow': shapeArrow,
        'Moon': shapeMoon,
        'Kite': shapeKite,
        'Bow Tie': shapeBowTie,
        'Tulip': shapeTulip,
        'Bone': shapeBone,
        'Shield': shapeShield,
        'Mitten': shapeMitten,
        'Teapot': shapeTeapot,
        'Pine': shapePine,
        'Lantern': shapeLantern,
        'Fox': shapeFox,
        'Whale': shapeWhale,
        'Cloud': shapeCloud,
        'Pear': shapePear,
        'Castle': shapeCastle,
        'Trophy': shapeTrophy,
        'Hexagon': shapeHexagon,
        'Ladybug': shapeLadybug,
        'Bird': shapeBird,
        'Big Heart': shapeBigHeart,
        'Elephant': shapeElephant,
        'Big Star': shapeBigStar,
        'Spaceship': shapeSpaceship,
        'Big Flower': shapeBigFlower,
        'Octopus': shapeOctopus,
        'Big Tree': shapeBigTree,
        'Big Castle': shapeBigCastle,
        'Wave': shapeWave,
        'Penguin': shapePenguin,
        'Balloon': shapeBalloon,
        'Train': shapeTrain,
        'Snowman': shapeSnowman,
        'Bee': shapeBee,
      };

  /// Translates a level's layout name (as stored on the generated level,
  /// e.g. "Pyramid" or "Letter X").
  String layoutName(String english) {
    for (final art in ShapeLibrary.all) {
      if (art.title == english) return shape(art);
    }
    for (final t in LayoutTemplate.values) {
      if (t.displayName == english) return template(t);
    }
    return english;
  }
}
