// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tile Grove';

  @override
  String get tagline => 'Finde die Paare. Räume den Hain.';

  @override
  String playLevel(int level) {
    return 'Level $level spielen';
  }

  @override
  String continueLevel(int level) {
    return 'Level $level fortsetzen';
  }

  @override
  String replayLevel(int level) {
    return 'Level $level wiederholen';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'Level $level von $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return 'Alle $total Level geschafft!';
  }

  @override
  String get menuLevels => 'Level';

  @override
  String get menuAwards => 'Erfolge';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get homeInfo =>
      'Tippe zwei gleiche FREIE Steine an, um sie zu entfernen. Ein Stein ist frei, wenn nichts auf ihm liegt und seine linke oder rechte Seite offen ist. Halte einen Stein gedrückt, um zu sehen, was ihn blockiert.';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get back => 'Zurück';

  @override
  String get pauseAndSettings => 'Pause & Einstellungen';

  @override
  String tilesLeft(int count) {
    return 'Noch $count Steine';
  }

  @override
  String get restartLevelTitle => 'Level neu starten?';

  @override
  String get restartLevelBody =>
      'Dein Fortschritt auf diesem Brett geht verloren.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get restart => 'Neustart';

  @override
  String get arrangingTiles => 'Steine werden gelegt…';

  @override
  String get buildError =>
      'Beim Erstellen des Bretts ist etwas schiefgelaufen.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get boardCleared => 'Brett geschafft!';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'Level $level · $difficulty';
  }

  @override
  String get threeStarTip => 'Ohne Tipp, Mischen oder Magie gibt es 3 Sterne';

  @override
  String get newBest => 'Neuer Rekord!';

  @override
  String achievementUnlocked(String title) {
    return 'Erfolg: $title';
  }

  @override
  String get finishJourney => 'Reise abschließen';

  @override
  String get replay => 'Wiederholen';

  @override
  String get home => 'Start';

  @override
  String get noMatchesTitle => 'Keine Paare mehr';

  @override
  String get noMatchesBody =>
      'Gerade passen keine freien Steine zusammen. Kostenloses Mischen verteilt die restlichen Steine garantiert lösbar neu.';

  @override
  String get undo => 'Rückgängig';

  @override
  String get freeShuffle => 'Gratis mischen';

  @override
  String get paused => 'Pausiert';

  @override
  String get resume => 'Weiter';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels Level · $stars ★ · $matches Paare';
  }

  @override
  String get play => 'SPIELEN';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'Gesperrt';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionAudio => 'Ton & Vibration';

  @override
  String get music => 'Musik';

  @override
  String get musicSubtitle => 'Entspannende Hintergrundmelodie';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get soundEffectsSubtitle => 'Tippen, Paare und Jubel';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Sanftes haptisches Feedback';

  @override
  String get sectionDisplay => 'Anzeige';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get dimBlocked => 'Blockierte Steine abdunkeln';

  @override
  String get dimBlockedSubtitle => 'Freie Steine leichter erkennen';

  @override
  String get reduceMotion => 'Bewegung reduzieren';

  @override
  String get reduceMotionSubtitle => 'Weniger Animationen und Partikel';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get sectionHelp => 'Hilfe';

  @override
  String get howToPlay => 'So wird gespielt';

  @override
  String get howToPlaySubtitle => 'Regeln, Booster und Sterne';

  @override
  String get allSettings => 'Alle Einstellungen';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current von $total';
  }

  @override
  String get htpTitle1 => 'Paare finden';

  @override
  String get htpBody1 =>
      'Tippe zwei Steine mit gleichem Bild an, um sie zu entfernen. Räume alle ab, um zu gewinnen.';

  @override
  String get htpTitle2 => 'Nur freie Steine';

  @override
  String get htpBody2 =>
      'Ein Stein ist frei, wenn nichts auf ihm liegt und links oder rechts offen ist. Blockierte Steine sind nicht wählbar.';

  @override
  String get htpFree => 'Frei';

  @override
  String get htpBlocked => 'Blockiert';

  @override
  String get htpTitle3 => 'Unter den Stapel schauen';

  @override
  String get htpBody3 =>
      'Halte einen Stein gedrückt, um seine Blocker zu sehen. Plane voraus, um die richtigen Steine freizulegen.';

  @override
  String get htpTitle4 => 'Booster';

  @override
  String get htpBody4 => 'Jedes Level gibt dir neue Booster.';

  @override
  String get boosterHintDesc => 'Zeigt ein passendes Paar.';

  @override
  String get boosterUndoDesc => 'Nimmt dein letztes Paar zurück. Immer gratis.';

  @override
  String get boosterShuffleDesc =>
      'Mischt die übrigen Steine zu einem lösbaren Brett.';

  @override
  String get boosterMagicDesc =>
      'Tippe einen freien Stein an – er findet seinen Zwilling automatisch.';

  @override
  String get htpTitle5 => 'Sterne sammeln';

  @override
  String htpBody5(int total) {
    return 'Schaffe ein Brett ohne Tipp, Mischen oder Magie für 3 Sterne. Alle $total Level sind lösbar.';
  }

  @override
  String get htpNext => 'Weiter';

  @override
  String get htpBack => 'Zurück';

  @override
  String get htpDone => 'Los geht\'s!';

  @override
  String get htpSkip => 'Überspringen';

  @override
  String get msgTileFree => 'Dieser Stein ist frei!';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'Kein $booster mehr in diesem Level.';
  }

  @override
  String get msgNoWinningMoves =>
      'Kein Gewinnzug mehr – versuche Rückgängig oder Mischen.';

  @override
  String get msgNothingToUndo => 'Noch nichts rückgängig zu machen.';

  @override
  String get msgCantShuffle =>
      'Diese Steine ergeben kein lösbares Brett – versuche Rückgängig.';

  @override
  String get msgMagicArmed =>
      'Tippe einen freien Stein zum automatischen Paaren.';

  @override
  String get msgTwinNotFree =>
      'Sein Zwilling ist noch nicht frei – versuche einen anderen.';

  @override
  String get boosterHint => 'Tipp';

  @override
  String get boosterUndo => 'Zurück';

  @override
  String get boosterShuffle => 'Mischen';

  @override
  String get boosterMagic => 'Magie';

  @override
  String get tierBeginner => 'Anfänger';

  @override
  String get tierApprentice => 'Lehrling';

  @override
  String get tierAdept => 'Geübt';

  @override
  String get tierExpert => 'Experte';

  @override
  String get tierMaster => 'Meister';

  @override
  String get tierLegend => 'Legende';

  @override
  String get diffEasy => 'Leicht';

  @override
  String get diffMedium => 'Mittel';

  @override
  String get diffHard => 'Schwer';

  @override
  String get diffExpert => 'Experte';

  @override
  String get layoutSmallRectangle => 'Kleine Kiste';

  @override
  String get layoutLargeRectangle => 'Große Halle';

  @override
  String get layoutPyramid => 'Pyramide';

  @override
  String get layoutDoublePyramid => 'Zwillingsgipfel';

  @override
  String get layoutDiamond => 'Raute';

  @override
  String get layoutCross => 'Kreuz';

  @override
  String get layoutButterfly => 'Schmetterling';

  @override
  String get layoutFlower => 'Blume';

  @override
  String get layoutCircle => 'Ring';

  @override
  String get layoutStaircase => 'Treppe';

  @override
  String get layoutZigzag => 'Zickzack';

  @override
  String get layoutLayeredSquare => 'Schichttorte';

  @override
  String get layoutAsymmetricTower => 'Leuchtturm';

  @override
  String get layoutClusters => 'Inseln';

  @override
  String get layoutComplex => 'Festung';

  @override
  String get layoutProcedural => 'Wildnis';

  @override
  String get layoutPile => 'Schatzhaufen';

  @override
  String get layoutShape => 'Bild';

  @override
  String shapeLetter(String name) {
    return 'Buchstabe $name';
  }

  @override
  String shapeNumber(String name) {
    return 'Zahl $name';
  }

  @override
  String get shapeLittleHeart => 'Kleines Herz';

  @override
  String get shapePlus => 'Plus';

  @override
  String get shapeLittleHouse => 'Häuschen';

  @override
  String get shapeLittleFish => 'Fischlein';

  @override
  String get shapeCat => 'Katze';

  @override
  String get shapeBunny => 'Häschen';

  @override
  String get shapeOwl => 'Eule';

  @override
  String get shapeFish => 'Fisch';

  @override
  String get shapeTurtle => 'Schildkröte';

  @override
  String get shapeCrab => 'Krabbe';

  @override
  String get shapeBear => 'Bär';

  @override
  String get shapeDuck => 'Ente';

  @override
  String get shapeButterfly => 'Schmetterling';

  @override
  String get shapeSnail => 'Schnecke';

  @override
  String get shapeHeart => 'Herz';

  @override
  String get shapeStar => 'Stern';

  @override
  String get shapeHouse => 'Haus';

  @override
  String get shapeTree => 'Baum';

  @override
  String get shapeMushroom => 'Pilz';

  @override
  String get shapeUmbrella => 'Regenschirm';

  @override
  String get shapeBell => 'Glocke';

  @override
  String get shapeCrown => 'Krone';

  @override
  String get shapeGem => 'Edelstein';

  @override
  String get shapeRocket => 'Rakete';

  @override
  String get shapeAnchor => 'Anker';

  @override
  String get shapeApple => 'Apfel';

  @override
  String get shapeHourglass => 'Sanduhr';

  @override
  String get shapeSailboat => 'Segelboot';

  @override
  String get shapeSun => 'Sonne';

  @override
  String get shapeSpade => 'Pik';

  @override
  String get shapeKey => 'Schlüssel';

  @override
  String get shapeCup => 'Tasse';

  @override
  String get themeFruits => 'Obstmarkt';

  @override
  String get themeAnimals => 'Tierfreunde';

  @override
  String get themeSweets => 'Süßwarenladen';

  @override
  String get themeGarden => 'Geheimer Garten';

  @override
  String get themeOcean => 'Tiefblau';

  @override
  String get themeFantasy => 'Fantasiereich';

  @override
  String get themeObjects => 'Alltagsschätze';

  @override
  String get achFirstClearTitle => 'Erste Blüte';

  @override
  String get achFirstClearDesc => 'Schaffe dein erstes Brett.';

  @override
  String get achTenLevelsTitle => 'Aufsteigender Stern';

  @override
  String get achTenLevelsDesc => 'Schaffe 10 Level.';

  @override
  String get achFiftyLevelsTitle => 'Steinmeister';

  @override
  String get achFiftyLevelsDesc => 'Schaffe 50 Level.';

  @override
  String get achHundredLevelsTitle => 'Hain-Legende';

  @override
  String get achHundredLevelsDesc => 'Schaffe 100 Level.';

  @override
  String get achPerfectTenTitle => 'Perfektionist';

  @override
  String get achPerfectTenDesc => 'Hole 3 Sterne in 10 Leveln.';

  @override
  String get achSpeedsterTitle => 'Blitzschnell';

  @override
  String get achSpeedsterDesc => 'Schaffe ein Brett in unter 60 Sekunden.';

  @override
  String get achThousandMatchesTitle => 'Sammler';

  @override
  String get achThousandMatchesDesc => 'Finde 1.000 Paare.';

  @override
  String get achPureSkillTitle => 'Reines Können';

  @override
  String get achPureSkillDesc =>
      'Schaffe ein Brett mit 4+ Ebenen ohne Booster.';
}
