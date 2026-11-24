import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tile Grove'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Find the pairs. Clear the grove.'**
  String get tagline;

  /// No description provided for @playLevel.
  ///
  /// In en, this message translates to:
  /// **'Play Level {level}'**
  String playLevel(int level);

  /// No description provided for @continueLevel.
  ///
  /// In en, this message translates to:
  /// **'Continue Level {level}'**
  String continueLevel(int level);

  /// No description provided for @replayLevel.
  ///
  /// In en, this message translates to:
  /// **'Replay Level {level}'**
  String replayLevel(int level);

  /// No description provided for @levelOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Level {level} of {total} • {tier}'**
  String levelOfTotal(int level, int total, String tier);

  /// No description provided for @allLevelsCleared.
  ///
  /// In en, this message translates to:
  /// **'All {total} levels cleared!'**
  String allLevelsCleared(int total);

  /// No description provided for @menuLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get menuLevels;

  /// No description provided for @menuAwards.
  ///
  /// In en, this message translates to:
  /// **'Awards'**
  String get menuAwards;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @homeInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap two identical FREE tiles to clear them. A tile is free when nothing sits on top of it and its left or right side is open. Long-press any tile to see what is blocking it.'**
  String get homeInfo;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @pauseAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Pause & settings'**
  String get pauseAndSettings;

  /// No description provided for @tilesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} tiles left'**
  String tilesLeft(int count);

  /// No description provided for @restartLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart level?'**
  String get restartLevelTitle;

  /// No description provided for @restartLevelBody.
  ///
  /// In en, this message translates to:
  /// **'Your current progress on this board will be lost.'**
  String get restartLevelBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @arrangingTiles.
  ///
  /// In en, this message translates to:
  /// **'Arranging tiles…'**
  String get arrangingTiles;

  /// No description provided for @buildError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong building this board.'**
  String get buildError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @boardCleared.
  ///
  /// In en, this message translates to:
  /// **'Board Cleared!'**
  String get boardCleared;

  /// No description provided for @levelDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {difficulty}'**
  String levelDifficulty(int level, String difficulty);

  /// No description provided for @threeStarTip.
  ///
  /// In en, this message translates to:
  /// **'Clear it without Hint, Shuffle or Magic for 3 stars'**
  String get threeStarTip;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'New best!'**
  String get newBest;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement: {title}'**
  String achievementUnlocked(String title);

  /// No description provided for @finishJourney.
  ///
  /// In en, this message translates to:
  /// **'Finish the journey'**
  String get finishJourney;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches left'**
  String get noMatchesTitle;

  /// No description provided for @noMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'None of the free tiles match right now. A free shuffle will re-deal the remaining tiles into a board that is guaranteed to be clearable.'**
  String get noMatchesBody;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @freeShuffle.
  ///
  /// In en, this message translates to:
  /// **'Free shuffle'**
  String get freeShuffle;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @awardsSummary.
  ///
  /// In en, this message translates to:
  /// **'{levels} levels cleared · {stars} ★ · {matches} matches'**
  String awardsSummary(int levels, int stars, int matches);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @tierRange.
  ///
  /// In en, this message translates to:
  /// **'{tier}  ·  {first}–{last}'**
  String tierRange(String tier, int first, int last);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAudio.
  ///
  /// In en, this message translates to:
  /// **'Sound & vibration'**
  String get sectionAudio;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @musicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Relaxing background melody'**
  String get musicSubtitle;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Taps, matches and celebrations'**
  String get soundEffectsSubtitle;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle haptic feedback'**
  String get vibrationSubtitle;

  /// No description provided for @sectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get sectionDisplay;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @dimBlocked.
  ///
  /// In en, this message translates to:
  /// **'Dim blocked tiles'**
  String get dimBlocked;

  /// No description provided for @dimBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make free tiles easier to spot'**
  String get dimBlockedSubtitle;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fewer animations and particles'**
  String get reduceMotionSubtitle;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @sectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get sectionHelp;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @howToPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules, boosters and stars'**
  String get howToPlaySubtitle;

  /// No description provided for @allSettings.
  ///
  /// In en, this message translates to:
  /// **'All settings'**
  String get allSettings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @htpStep.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String htpStep(int current, int total);

  /// No description provided for @htpTitle1.
  ///
  /// In en, this message translates to:
  /// **'Match pairs'**
  String get htpTitle1;

  /// No description provided for @htpBody1.
  ///
  /// In en, this message translates to:
  /// **'Tap two tiles with the same picture to clear them. Clear every tile to win the level.'**
  String get htpBody1;

  /// No description provided for @htpTitle2.
  ///
  /// In en, this message translates to:
  /// **'Only free tiles'**
  String get htpTitle2;

  /// No description provided for @htpBody2.
  ///
  /// In en, this message translates to:
  /// **'A tile is free when nothing sits on top of it and its left or right side is open. Blocked tiles can\'t be picked.'**
  String get htpBody2;

  /// No description provided for @htpFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get htpFree;

  /// No description provided for @htpBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get htpBlocked;

  /// No description provided for @htpTitle3.
  ///
  /// In en, this message translates to:
  /// **'Peek under the pile'**
  String get htpTitle3;

  /// No description provided for @htpBody3.
  ///
  /// In en, this message translates to:
  /// **'Long-press any tile to see which tiles are blocking it. Plan ahead to free the tiles you need.'**
  String get htpBody3;

  /// No description provided for @htpTitle4.
  ///
  /// In en, this message translates to:
  /// **'Boosters'**
  String get htpTitle4;

  /// No description provided for @htpBody4.
  ///
  /// In en, this message translates to:
  /// **'Every level gives you a fresh set of boosters.'**
  String get htpBody4;

  /// No description provided for @boosterHintDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows a pair you can match.'**
  String get boosterHintDesc;

  /// No description provided for @boosterUndoDesc.
  ///
  /// In en, this message translates to:
  /// **'Takes back your last match. Always free.'**
  String get boosterUndoDesc;

  /// No description provided for @boosterShuffleDesc.
  ///
  /// In en, this message translates to:
  /// **'Re-deals the remaining tiles into a solvable board.'**
  String get boosterShuffleDesc;

  /// No description provided for @boosterMagicDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap a free tile and it matches with its twin automatically.'**
  String get boosterMagicDesc;

  /// No description provided for @htpTitle5.
  ///
  /// In en, this message translates to:
  /// **'Earn stars'**
  String get htpTitle5;

  /// No description provided for @htpBody5.
  ///
  /// In en, this message translates to:
  /// **'Clear a board without Hint, Shuffle or Magic for 3 stars. Every one of the {total} levels can be solved.'**
  String htpBody5(int total);

  /// No description provided for @htpNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get htpNext;

  /// No description provided for @htpBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get htpBack;

  /// No description provided for @htpDone.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get htpDone;

  /// No description provided for @htpSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get htpSkip;

  /// No description provided for @msgTileFree.
  ///
  /// In en, this message translates to:
  /// **'This tile is free to match!'**
  String get msgTileFree;

  /// No description provided for @msgNoBoosterLeft.
  ///
  /// In en, this message translates to:
  /// **'No {booster} left on this level.'**
  String msgNoBoosterLeft(String booster);

  /// No description provided for @msgNoWinningMoves.
  ///
  /// In en, this message translates to:
  /// **'No winning moves from here — try Undo or Shuffle.'**
  String get msgNoWinningMoves;

  /// No description provided for @msgNothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo yet.'**
  String get msgNothingToUndo;

  /// No description provided for @msgCantShuffle.
  ///
  /// In en, this message translates to:
  /// **'These tiles can\'t be rearranged into a winnable board — try Undo.'**
  String get msgCantShuffle;

  /// No description provided for @msgMagicArmed.
  ///
  /// In en, this message translates to:
  /// **'Tap any free tile to auto-match it.'**
  String get msgMagicArmed;

  /// No description provided for @msgTwinNotFree.
  ///
  /// In en, this message translates to:
  /// **'Its twin isn\'t free yet — try another tile.'**
  String get msgTwinNotFree;

  /// No description provided for @boosterHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get boosterHint;

  /// No description provided for @boosterUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get boosterUndo;

  /// No description provided for @boosterShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get boosterShuffle;

  /// No description provided for @boosterMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get boosterMagic;

  /// No description provided for @tierBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get tierBeginner;

  /// No description provided for @tierApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get tierApprentice;

  /// No description provided for @tierAdept.
  ///
  /// In en, this message translates to:
  /// **'Adept'**
  String get tierAdept;

  /// No description provided for @tierExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get tierExpert;

  /// No description provided for @tierMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get tierMaster;

  /// No description provided for @tierLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get tierLegend;

  /// No description provided for @diffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get diffEasy;

  /// No description provided for @diffMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get diffMedium;

  /// No description provided for @diffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diffHard;

  /// No description provided for @diffExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get diffExpert;

  /// No description provided for @layoutSmallRectangle.
  ///
  /// In en, this message translates to:
  /// **'Little Box'**
  String get layoutSmallRectangle;

  /// No description provided for @layoutLargeRectangle.
  ///
  /// In en, this message translates to:
  /// **'Grand Hall'**
  String get layoutLargeRectangle;

  /// No description provided for @layoutPyramid.
  ///
  /// In en, this message translates to:
  /// **'Pyramid'**
  String get layoutPyramid;

  /// No description provided for @layoutDoublePyramid.
  ///
  /// In en, this message translates to:
  /// **'Twin Peaks'**
  String get layoutDoublePyramid;

  /// No description provided for @layoutDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get layoutDiamond;

  /// No description provided for @layoutCross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get layoutCross;

  /// No description provided for @layoutButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get layoutButterfly;

  /// No description provided for @layoutFlower.
  ///
  /// In en, this message translates to:
  /// **'Flower'**
  String get layoutFlower;

  /// No description provided for @layoutCircle.
  ///
  /// In en, this message translates to:
  /// **'Ring'**
  String get layoutCircle;

  /// No description provided for @layoutStaircase.
  ///
  /// In en, this message translates to:
  /// **'Staircase'**
  String get layoutStaircase;

  /// No description provided for @layoutZigzag.
  ///
  /// In en, this message translates to:
  /// **'Zigzag'**
  String get layoutZigzag;

  /// No description provided for @layoutLayeredSquare.
  ///
  /// In en, this message translates to:
  /// **'Layer Cake'**
  String get layoutLayeredSquare;

  /// No description provided for @layoutAsymmetricTower.
  ///
  /// In en, this message translates to:
  /// **'Lighthouse'**
  String get layoutAsymmetricTower;

  /// No description provided for @layoutClusters.
  ///
  /// In en, this message translates to:
  /// **'Islands'**
  String get layoutClusters;

  /// No description provided for @layoutComplex.
  ///
  /// In en, this message translates to:
  /// **'Fortress'**
  String get layoutComplex;

  /// No description provided for @layoutProcedural.
  ///
  /// In en, this message translates to:
  /// **'Wilds'**
  String get layoutProcedural;

  /// No description provided for @layoutPile.
  ///
  /// In en, this message translates to:
  /// **'Treasure Pile'**
  String get layoutPile;

  /// No description provided for @layoutShape.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get layoutShape;

  /// No description provided for @shapeLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter {name}'**
  String shapeLetter(String name);

  /// No description provided for @shapeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number {name}'**
  String shapeNumber(String name);

  /// No description provided for @shapeLittleHeart.
  ///
  /// In en, this message translates to:
  /// **'Little Heart'**
  String get shapeLittleHeart;

  /// No description provided for @shapePlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get shapePlus;

  /// No description provided for @shapeLittleHouse.
  ///
  /// In en, this message translates to:
  /// **'Little House'**
  String get shapeLittleHouse;

  /// No description provided for @shapeLittleFish.
  ///
  /// In en, this message translates to:
  /// **'Little Fish'**
  String get shapeLittleFish;

  /// No description provided for @shapeCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get shapeCat;

  /// No description provided for @shapeBunny.
  ///
  /// In en, this message translates to:
  /// **'Bunny'**
  String get shapeBunny;

  /// No description provided for @shapeOwl.
  ///
  /// In en, this message translates to:
  /// **'Owl'**
  String get shapeOwl;

  /// No description provided for @shapeFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get shapeFish;

  /// No description provided for @shapeTurtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle'**
  String get shapeTurtle;

  /// No description provided for @shapeCrab.
  ///
  /// In en, this message translates to:
  /// **'Crab'**
  String get shapeCrab;

  /// No description provided for @shapeBear.
  ///
  /// In en, this message translates to:
  /// **'Bear'**
  String get shapeBear;

  /// No description provided for @shapeDuck.
  ///
  /// In en, this message translates to:
  /// **'Duck'**
  String get shapeDuck;

  /// No description provided for @shapeButterfly.
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get shapeButterfly;

  /// No description provided for @shapeSnail.
  ///
  /// In en, this message translates to:
  /// **'Snail'**
  String get shapeSnail;

  /// No description provided for @shapeHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get shapeHeart;

  /// No description provided for @shapeStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get shapeStar;

  /// No description provided for @shapeHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get shapeHouse;

  /// No description provided for @shapeTree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get shapeTree;

  /// No description provided for @shapeMushroom.
  ///
  /// In en, this message translates to:
  /// **'Mushroom'**
  String get shapeMushroom;

  /// No description provided for @shapeUmbrella.
  ///
  /// In en, this message translates to:
  /// **'Umbrella'**
  String get shapeUmbrella;

  /// No description provided for @shapeBell.
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get shapeBell;

  /// No description provided for @shapeCrown.
  ///
  /// In en, this message translates to:
  /// **'Crown'**
  String get shapeCrown;

  /// No description provided for @shapeGem.
  ///
  /// In en, this message translates to:
  /// **'Gem'**
  String get shapeGem;

  /// No description provided for @shapeRocket.
  ///
  /// In en, this message translates to:
  /// **'Rocket'**
  String get shapeRocket;

  /// No description provided for @shapeAnchor.
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get shapeAnchor;

  /// No description provided for @shapeApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get shapeApple;

  /// No description provided for @shapeHourglass.
  ///
  /// In en, this message translates to:
  /// **'Hourglass'**
  String get shapeHourglass;

  /// No description provided for @shapeSailboat.
  ///
  /// In en, this message translates to:
  /// **'Sailboat'**
  String get shapeSailboat;

  /// No description provided for @shapeSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get shapeSun;

  /// No description provided for @shapeSpade.
  ///
  /// In en, this message translates to:
  /// **'Spade'**
  String get shapeSpade;

  /// No description provided for @shapeKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get shapeKey;

  /// No description provided for @shapeCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get shapeCup;

  /// No description provided for @themeFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruit Market'**
  String get themeFruits;

  /// No description provided for @themeAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animal Friends'**
  String get themeAnimals;

  /// No description provided for @themeSweets.
  ///
  /// In en, this message translates to:
  /// **'Sweet Shop'**
  String get themeSweets;

  /// No description provided for @themeGarden.
  ///
  /// In en, this message translates to:
  /// **'Secret Garden'**
  String get themeGarden;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Deep Blue'**
  String get themeOcean;

  /// No description provided for @themeFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy Realm'**
  String get themeFantasy;

  /// No description provided for @themeObjects.
  ///
  /// In en, this message translates to:
  /// **'Everyday Treasures'**
  String get themeObjects;

  /// No description provided for @achFirstClearTitle.
  ///
  /// In en, this message translates to:
  /// **'First Bloom'**
  String get achFirstClearTitle;

  /// No description provided for @achFirstClearDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear your first board.'**
  String get achFirstClearDesc;

  /// No description provided for @achTenLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get achTenLevelsTitle;

  /// No description provided for @achTenLevelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 10 levels.'**
  String get achTenLevelsDesc;

  /// No description provided for @achFiftyLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tile Master'**
  String get achFiftyLevelsTitle;

  /// No description provided for @achFiftyLevelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 50 levels.'**
  String get achFiftyLevelsDesc;

  /// No description provided for @achHundredLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grove Legend'**
  String get achHundredLevelsTitle;

  /// No description provided for @achHundredLevelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear 100 levels.'**
  String get achHundredLevelsDesc;

  /// No description provided for @achPerfectTenTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get achPerfectTenTitle;

  /// No description provided for @achPerfectTenDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 3 stars on 10 levels.'**
  String get achPerfectTenDesc;

  /// No description provided for @achSpeedsterTitle.
  ///
  /// In en, this message translates to:
  /// **'Speedster'**
  String get achSpeedsterTitle;

  /// No description provided for @achSpeedsterDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear a board in under 60 seconds.'**
  String get achSpeedsterDesc;

  /// No description provided for @achThousandMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achThousandMatchesTitle;

  /// No description provided for @achThousandMatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Make 1,000 matches.'**
  String get achThousandMatchesDesc;

  /// No description provided for @achPureSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'Pure Skill'**
  String get achPureSkillTitle;

  /// No description provided for @achPureSkillDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear a 4+ layer board without boosters.'**
  String get achPureSkillDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
