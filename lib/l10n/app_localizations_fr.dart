// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tile Grove';

  @override
  String get tagline => 'Trouvez les paires. Dégagez le bosquet.';

  @override
  String playLevel(int level) {
    return 'Jouer niveau $level';
  }

  @override
  String continueLevel(int level) {
    return 'Continuer niveau $level';
  }

  @override
  String replayLevel(int level) {
    return 'Rejouer niveau $level';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'Niveau $level sur $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return 'Les $total niveaux sont terminés !';
  }

  @override
  String get menuLevels => 'Niveaux';

  @override
  String get menuAwards => 'Trophées';

  @override
  String get menuSettings => 'Réglages';

  @override
  String get homeInfo =>
      'Touchez deux tuiles LIBRES identiques pour les retirer. Une tuile est libre si rien n\'est posé dessus et que son côté gauche ou droit est dégagé. Appui long sur une tuile pour voir ce qui la bloque.';

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String get back => 'Retour';

  @override
  String get pauseAndSettings => 'Pause et réglages';

  @override
  String tilesLeft(int count) {
    return '$count tuiles restantes';
  }

  @override
  String get restartLevelTitle => 'Recommencer le niveau ?';

  @override
  String get restartLevelBody =>
      'Votre progression sur ce plateau sera perdue.';

  @override
  String get cancel => 'Annuler';

  @override
  String get restart => 'Recommencer';

  @override
  String get arrangingTiles => 'Disposition des tuiles…';

  @override
  String get buildError =>
      'Un problème est survenu lors de la création du plateau.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get boardCleared => 'Plateau terminé !';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'Niveau $level · $difficulty';
  }

  @override
  String get threeStarTip =>
      'Terminez sans Indice, Mélange ni Magie pour 3 étoiles';

  @override
  String get newBest => 'Nouveau record !';

  @override
  String achievementUnlocked(String title) {
    return 'Trophée : $title';
  }

  @override
  String get finishJourney => 'Terminer l\'aventure';

  @override
  String get replay => 'Rejouer';

  @override
  String get home => 'Accueil';

  @override
  String get noMatchesTitle => 'Plus de paires';

  @override
  String get noMatchesBody =>
      'Aucune tuile libre ne correspond. Un mélange gratuit redistribue les tuiles restantes sur un plateau qu\'il est garanti de terminer.';

  @override
  String get undo => 'Annuler';

  @override
  String get freeShuffle => 'Mélange gratuit';

  @override
  String get paused => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels niveaux · $stars ★ · $matches paires';
  }

  @override
  String get play => 'JOUER';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'Verrouillé';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get sectionAudio => 'Son et vibration';

  @override
  String get music => 'Musique';

  @override
  String get musicSubtitle => 'Mélodie relaxante en fond';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get soundEffectsSubtitle => 'Touches, paires et célébrations';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationSubtitle => 'Retour haptique léger';

  @override
  String get sectionDisplay => 'Affichage';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get dimBlocked => 'Assombrir les tuiles bloquées';

  @override
  String get dimBlockedSubtitle => 'Repérer plus facilement les tuiles libres';

  @override
  String get reduceMotion => 'Réduire les animations';

  @override
  String get reduceMotionSubtitle => 'Moins d\'animations et de particules';

  @override
  String get sectionLanguage => 'Langue';

  @override
  String get sectionHelp => 'Aide';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get howToPlaySubtitle => 'Règles, bonus et étoiles';

  @override
  String get allSettings => 'Tous les réglages';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current sur $total';
  }

  @override
  String get htpTitle1 => 'Associez les paires';

  @override
  String get htpBody1 =>
      'Touchez deux tuiles identiques pour les retirer. Retirez-les toutes pour gagner.';

  @override
  String get htpTitle2 => 'Seulement les tuiles libres';

  @override
  String get htpBody2 =>
      'Une tuile est libre si rien n\'est dessus et que son côté gauche ou droit est dégagé. Les tuiles bloquées ne peuvent pas être choisies.';

  @override
  String get htpFree => 'Libre';

  @override
  String get htpBlocked => 'Bloquée';

  @override
  String get htpTitle3 => 'Regardez sous la pile';

  @override
  String get htpBody3 =>
      'Appui long sur une tuile pour voir ce qui la bloque. Anticipez pour libérer celles dont vous avez besoin.';

  @override
  String get htpTitle4 => 'Bonus';

  @override
  String get htpBody4 => 'Chaque niveau vous donne de nouveaux bonus.';

  @override
  String get boosterHintDesc => 'Montre une paire à associer.';

  @override
  String get boosterUndoDesc =>
      'Annule votre dernière paire. Toujours gratuit.';

  @override
  String get boosterShuffleDesc =>
      'Redistribue les tuiles restantes en un plateau soluble.';

  @override
  String get boosterMagicDesc =>
      'Touchez une tuile libre : elle s\'associe seule à sa jumelle.';

  @override
  String get htpTitle5 => 'Gagnez des étoiles';

  @override
  String htpBody5(int total) {
    return 'Terminez sans Indice, Mélange ni Magie pour 3 étoiles. Les $total niveaux ont tous une solution.';
  }

  @override
  String get htpNext => 'Suivant';

  @override
  String get htpBack => 'Précédent';

  @override
  String get htpDone => 'C\'est parti !';

  @override
  String get htpSkip => 'Passer';

  @override
  String get msgTileFree => 'Cette tuile est libre !';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'Plus de $booster pour ce niveau.';
  }

  @override
  String get msgNoWinningMoves =>
      'Aucun coup gagnant — essayez Annuler ou Mélanger.';

  @override
  String get msgNothingToUndo => 'Rien à annuler pour l\'instant.';

  @override
  String get msgCantShuffle =>
      'Ces tuiles ne peuvent pas former un plateau gagnable — essayez Annuler.';

  @override
  String get msgMagicArmed => 'Touchez une tuile libre pour l\'associer.';

  @override
  String get msgTwinNotFree =>
      'Sa jumelle n\'est pas libre — essayez une autre tuile.';

  @override
  String get boosterHint => 'Indice';

  @override
  String get boosterUndo => 'Annuler';

  @override
  String get boosterShuffle => 'Mélanger';

  @override
  String get boosterMagic => 'Magie';

  @override
  String get tierBeginner => 'Débutant';

  @override
  String get tierApprentice => 'Apprenti';

  @override
  String get tierAdept => 'Adepte';

  @override
  String get tierExpert => 'Expert';

  @override
  String get tierMaster => 'Maître';

  @override
  String get tierLegend => 'Légende';

  @override
  String get diffEasy => 'Facile';

  @override
  String get diffMedium => 'Moyen';

  @override
  String get diffHard => 'Difficile';

  @override
  String get diffExpert => 'Expert';

  @override
  String get layoutSmallRectangle => 'Petite boîte';

  @override
  String get layoutLargeRectangle => 'Grande salle';

  @override
  String get layoutPyramid => 'Pyramide';

  @override
  String get layoutDoublePyramid => 'Pics jumeaux';

  @override
  String get layoutDiamond => 'Losange';

  @override
  String get layoutCross => 'Croix';

  @override
  String get layoutButterfly => 'Papillon';

  @override
  String get layoutFlower => 'Fleur';

  @override
  String get layoutCircle => 'Anneau';

  @override
  String get layoutStaircase => 'Escalier';

  @override
  String get layoutZigzag => 'Zigzag';

  @override
  String get layoutLayeredSquare => 'Gâteau étagé';

  @override
  String get layoutAsymmetricTower => 'Phare';

  @override
  String get layoutClusters => 'Îles';

  @override
  String get layoutComplex => 'Forteresse';

  @override
  String get layoutProcedural => 'Contrées sauvages';

  @override
  String get layoutPile => 'Pile au trésor';

  @override
  String get layoutShape => 'Image';

  @override
  String shapeLetter(String name) {
    return 'Lettre $name';
  }

  @override
  String shapeNumber(String name) {
    return 'Chiffre $name';
  }

  @override
  String get shapeLittleHeart => 'Petit cœur';

  @override
  String get shapePlus => 'Plus';

  @override
  String get shapeLittleHouse => 'Maisonnette';

  @override
  String get shapeLittleFish => 'Petit poisson';

  @override
  String get shapeCat => 'Chat';

  @override
  String get shapeBunny => 'Lapin';

  @override
  String get shapeOwl => 'Hibou';

  @override
  String get shapeFish => 'Poisson';

  @override
  String get shapeTurtle => 'Tortue';

  @override
  String get shapeCrab => 'Crabe';

  @override
  String get shapeBear => 'Ours';

  @override
  String get shapeDuck => 'Canard';

  @override
  String get shapeButterfly => 'Papillon';

  @override
  String get shapeSnail => 'Escargot';

  @override
  String get shapeHeart => 'Cœur';

  @override
  String get shapeStar => 'Étoile';

  @override
  String get shapeHouse => 'Maison';

  @override
  String get shapeTree => 'Arbre';

  @override
  String get shapeMushroom => 'Champignon';

  @override
  String get shapeUmbrella => 'Parapluie';

  @override
  String get shapeBell => 'Cloche';

  @override
  String get shapeCrown => 'Couronne';

  @override
  String get shapeGem => 'Gemme';

  @override
  String get shapeRocket => 'Fusée';

  @override
  String get shapeAnchor => 'Ancre';

  @override
  String get shapeApple => 'Pomme';

  @override
  String get shapeHourglass => 'Sablier';

  @override
  String get shapeSailboat => 'Voilier';

  @override
  String get shapeSun => 'Soleil';

  @override
  String get shapeSpade => 'Pique';

  @override
  String get shapeKey => 'Clé';

  @override
  String get shapeCup => 'Tasse';

  @override
  String get themeFruits => 'Marché aux fruits';

  @override
  String get themeAnimals => 'Amis les animaux';

  @override
  String get themeSweets => 'Confiserie';

  @override
  String get themeGarden => 'Jardin secret';

  @override
  String get themeOcean => 'Grand bleu';

  @override
  String get themeFantasy => 'Royaume fantastique';

  @override
  String get themeObjects => 'Trésors du quotidien';

  @override
  String get achFirstClearTitle => 'Première fleur';

  @override
  String get achFirstClearDesc => 'Terminez votre premier plateau.';

  @override
  String get achTenLevelsTitle => 'Étoile montante';

  @override
  String get achTenLevelsDesc => 'Terminez 10 niveaux.';

  @override
  String get achFiftyLevelsTitle => 'Maître des tuiles';

  @override
  String get achFiftyLevelsDesc => 'Terminez 50 niveaux.';

  @override
  String get achHundredLevelsTitle => 'Légende du bosquet';

  @override
  String get achHundredLevelsDesc => 'Terminez 100 niveaux.';

  @override
  String get achPerfectTenTitle => 'Perfectionniste';

  @override
  String get achPerfectTenDesc => 'Obtenez 3 étoiles sur 10 niveaux.';

  @override
  String get achSpeedsterTitle => 'Éclair';

  @override
  String get achSpeedsterDesc => 'Terminez un plateau en moins de 60 secondes.';

  @override
  String get achThousandMatchesTitle => 'Collectionneur';

  @override
  String get achThousandMatchesDesc => 'Formez 1 000 paires.';

  @override
  String get achPureSkillTitle => 'Pur talent';

  @override
  String get achPureSkillDesc =>
      'Terminez un plateau de 4+ couches sans bonus.';
}
