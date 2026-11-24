// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tile Grove';

  @override
  String get tagline => 'Encuentra las parejas. Despeja el bosque.';

  @override
  String playLevel(int level) {
    return 'Jugar nivel $level';
  }

  @override
  String continueLevel(int level) {
    return 'Continuar nivel $level';
  }

  @override
  String replayLevel(int level) {
    return 'Repetir nivel $level';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'Nivel $level de $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return '¡$total niveles completados!';
  }

  @override
  String get menuLevels => 'Niveles';

  @override
  String get menuAwards => 'Logros';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get homeInfo =>
      'Toca dos fichas LIBRES iguales para quitarlas. Una ficha está libre si no tiene nada encima y su lado izquierdo o derecho está despejado. Mantén pulsada una ficha para ver qué la bloquea.';

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String get back => 'Atrás';

  @override
  String get pauseAndSettings => 'Pausa y ajustes';

  @override
  String tilesLeft(int count) {
    return 'Quedan $count fichas';
  }

  @override
  String get restartLevelTitle => '¿Reiniciar nivel?';

  @override
  String get restartLevelBody => 'Se perderá tu progreso en este tablero.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get arrangingTiles => 'Colocando fichas…';

  @override
  String get buildError => 'Algo salió mal al crear este tablero.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get boardCleared => '¡Tablero despejado!';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'Nivel $level · $difficulty';
  }

  @override
  String get threeStarTip =>
      'Complétalo sin Pista, Barajar ni Magia para 3 estrellas';

  @override
  String get newBest => '¡Nuevo récord!';

  @override
  String achievementUnlocked(String title) {
    return 'Logro: $title';
  }

  @override
  String get finishJourney => 'Terminar el viaje';

  @override
  String get replay => 'Repetir';

  @override
  String get home => 'Inicio';

  @override
  String get noMatchesTitle => 'No quedan parejas';

  @override
  String get noMatchesBody =>
      'Ninguna ficha libre coincide ahora. Un barajado gratis reparte las fichas restantes en un tablero que seguro se puede completar.';

  @override
  String get undo => 'Deshacer';

  @override
  String get freeShuffle => 'Barajar gratis';

  @override
  String get paused => 'En pausa';

  @override
  String get resume => 'Continuar';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels niveles · $stars ★ · $matches parejas';
  }

  @override
  String get play => 'JUGAR';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'Bloqueado';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAudio => 'Sonido y vibración';

  @override
  String get music => 'Música';

  @override
  String get musicSubtitle => 'Melodía relajante de fondo';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get soundEffectsSubtitle => 'Toques, parejas y celebraciones';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationSubtitle => 'Respuesta háptica suave';

  @override
  String get sectionDisplay => 'Pantalla';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get dimBlocked => 'Atenuar fichas bloqueadas';

  @override
  String get dimBlockedSubtitle => 'Para ver mejor las fichas libres';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get reduceMotionSubtitle => 'Menos animaciones y partículas';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get sectionHelp => 'Ayuda';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get howToPlaySubtitle => 'Reglas, potenciadores y estrellas';

  @override
  String get allSettings => 'Todos los ajustes';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current de $total';
  }

  @override
  String get htpTitle1 => 'Une parejas';

  @override
  String get htpBody1 =>
      'Toca dos fichas con el mismo dibujo para quitarlas. Quita todas para ganar el nivel.';

  @override
  String get htpTitle2 => 'Solo fichas libres';

  @override
  String get htpBody2 =>
      'Una ficha está libre si no tiene nada encima y su lado izquierdo o derecho está despejado. Las bloqueadas no se pueden elegir.';

  @override
  String get htpFree => 'Libre';

  @override
  String get htpBlocked => 'Bloqueada';

  @override
  String get htpTitle3 => 'Mira bajo la pila';

  @override
  String get htpBody3 =>
      'Mantén pulsada una ficha para ver qué fichas la bloquean. Planea con antelación para liberar las que necesitas.';

  @override
  String get htpTitle4 => 'Potenciadores';

  @override
  String get htpBody4 => 'Cada nivel te da potenciadores nuevos.';

  @override
  String get boosterHintDesc => 'Muestra una pareja que puedes unir.';

  @override
  String get boosterUndoDesc => 'Deshace tu última pareja. Siempre gratis.';

  @override
  String get boosterShuffleDesc =>
      'Reparte las fichas restantes en un tablero resoluble.';

  @override
  String get boosterMagicDesc =>
      'Toca una ficha libre y se une sola con su gemela.';

  @override
  String get htpTitle5 => 'Gana estrellas';

  @override
  String htpBody5(int total) {
    return 'Completa un tablero sin Pista, Barajar ni Magia para 3 estrellas. Los $total niveles tienen solución.';
  }

  @override
  String get htpNext => 'Siguiente';

  @override
  String get htpBack => 'Atrás';

  @override
  String get htpDone => '¡A jugar!';

  @override
  String get htpSkip => 'Omitir';

  @override
  String get msgTileFree => '¡Esta ficha está libre!';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'No te queda $booster en este nivel.';
  }

  @override
  String get msgNoWinningMoves =>
      'No hay jugadas ganadoras — prueba Deshacer o Barajar.';

  @override
  String get msgNothingToUndo => 'Aún no hay nada que deshacer.';

  @override
  String get msgCantShuffle =>
      'Estas fichas no pueden formar un tablero ganable — prueba Deshacer.';

  @override
  String get msgMagicArmed => 'Toca una ficha libre para unirla sola.';

  @override
  String get msgTwinNotFree => 'Su gemela aún no está libre — prueba otra.';

  @override
  String get boosterHint => 'Pista';

  @override
  String get boosterUndo => 'Deshacer';

  @override
  String get boosterShuffle => 'Barajar';

  @override
  String get boosterMagic => 'Magia';

  @override
  String get tierBeginner => 'Principiante';

  @override
  String get tierApprentice => 'Aprendiz';

  @override
  String get tierAdept => 'Experto';

  @override
  String get tierExpert => 'Maestro';

  @override
  String get tierMaster => 'Gran maestro';

  @override
  String get tierLegend => 'Leyenda';

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffMedium => 'Media';

  @override
  String get diffHard => 'Difícil';

  @override
  String get diffExpert => 'Experta';

  @override
  String get layoutSmallRectangle => 'Cajita';

  @override
  String get layoutLargeRectangle => 'Gran salón';

  @override
  String get layoutPyramid => 'Pirámide';

  @override
  String get layoutDoublePyramid => 'Picos gemelos';

  @override
  String get layoutDiamond => 'Diamante';

  @override
  String get layoutCross => 'Cruz';

  @override
  String get layoutButterfly => 'Mariposa';

  @override
  String get layoutFlower => 'Flor';

  @override
  String get layoutCircle => 'Anillo';

  @override
  String get layoutStaircase => 'Escalera';

  @override
  String get layoutZigzag => 'Zigzag';

  @override
  String get layoutLayeredSquare => 'Pastel de capas';

  @override
  String get layoutAsymmetricTower => 'Faro';

  @override
  String get layoutClusters => 'Islas';

  @override
  String get layoutComplex => 'Fortaleza';

  @override
  String get layoutProcedural => 'Tierras salvajes';

  @override
  String get layoutPile => 'Montón de tesoros';

  @override
  String get layoutShape => 'Imagen';

  @override
  String shapeLetter(String name) {
    return 'Letra $name';
  }

  @override
  String shapeNumber(String name) {
    return 'Número $name';
  }

  @override
  String get shapeLittleHeart => 'Corazoncito';

  @override
  String get shapePlus => 'Más';

  @override
  String get shapeLittleHouse => 'Casita';

  @override
  String get shapeLittleFish => 'Pececito';

  @override
  String get shapeCat => 'Gato';

  @override
  String get shapeBunny => 'Conejito';

  @override
  String get shapeOwl => 'Búho';

  @override
  String get shapeFish => 'Pez';

  @override
  String get shapeTurtle => 'Tortuga';

  @override
  String get shapeCrab => 'Cangrejo';

  @override
  String get shapeBear => 'Oso';

  @override
  String get shapeDuck => 'Pato';

  @override
  String get shapeButterfly => 'Mariposa';

  @override
  String get shapeSnail => 'Caracol';

  @override
  String get shapeHeart => 'Corazón';

  @override
  String get shapeStar => 'Estrella';

  @override
  String get shapeHouse => 'Casa';

  @override
  String get shapeTree => 'Árbol';

  @override
  String get shapeMushroom => 'Seta';

  @override
  String get shapeUmbrella => 'Paraguas';

  @override
  String get shapeBell => 'Campana';

  @override
  String get shapeCrown => 'Corona';

  @override
  String get shapeGem => 'Gema';

  @override
  String get shapeRocket => 'Cohete';

  @override
  String get shapeAnchor => 'Ancla';

  @override
  String get shapeApple => 'Manzana';

  @override
  String get shapeHourglass => 'Reloj de arena';

  @override
  String get shapeSailboat => 'Velero';

  @override
  String get shapeSun => 'Sol';

  @override
  String get shapeSpade => 'Pica';

  @override
  String get shapeKey => 'Llave';

  @override
  String get shapeCup => 'Taza';

  @override
  String get themeFruits => 'Mercado de frutas';

  @override
  String get themeAnimals => 'Amigos animales';

  @override
  String get themeSweets => 'Dulcería';

  @override
  String get themeGarden => 'Jardín secreto';

  @override
  String get themeOcean => 'Azul profundo';

  @override
  String get themeFantasy => 'Reino de fantasía';

  @override
  String get themeObjects => 'Tesoros cotidianos';

  @override
  String get achFirstClearTitle => 'Primera flor';

  @override
  String get achFirstClearDesc => 'Completa tu primer tablero.';

  @override
  String get achTenLevelsTitle => 'Estrella en ascenso';

  @override
  String get achTenLevelsDesc => 'Completa 10 niveles.';

  @override
  String get achFiftyLevelsTitle => 'Maestro de fichas';

  @override
  String get achFiftyLevelsDesc => 'Completa 50 niveles.';

  @override
  String get achHundredLevelsTitle => 'Leyenda del bosque';

  @override
  String get achHundredLevelsDesc => 'Completa 100 niveles.';

  @override
  String get achPerfectTenTitle => 'Perfeccionista';

  @override
  String get achPerfectTenDesc => 'Consigue 3 estrellas en 10 niveles.';

  @override
  String get achSpeedsterTitle => 'Velocista';

  @override
  String get achSpeedsterDesc => 'Completa un tablero en menos de 60 segundos.';

  @override
  String get achThousandMatchesTitle => 'Coleccionista';

  @override
  String get achThousandMatchesDesc => 'Haz 1.000 parejas.';

  @override
  String get achPureSkillTitle => 'Pura habilidad';

  @override
  String get achPureSkillDesc =>
      'Completa un tablero de 4+ capas sin potenciadores.';
}
