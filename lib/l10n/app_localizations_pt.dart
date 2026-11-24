// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Tile Grove';

  @override
  String get tagline => 'Encontre os pares. Limpe o bosque.';

  @override
  String playLevel(int level) {
    return 'Jogar nível $level';
  }

  @override
  String continueLevel(int level) {
    return 'Continuar nível $level';
  }

  @override
  String replayLevel(int level) {
    return 'Repetir nível $level';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'Nível $level de $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return 'Todos os $total níveis concluídos!';
  }

  @override
  String get menuLevels => 'Níveis';

  @override
  String get menuAwards => 'Conquistas';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get homeInfo =>
      'Toque em duas peças LIVRES iguais para removê-las. Uma peça está livre quando nada está sobre ela e seu lado esquerdo ou direito está aberto. Toque e segure uma peça para ver o que a bloqueia.';

  @override
  String levelLabel(int level) {
    return 'Nível $level';
  }

  @override
  String get back => 'Voltar';

  @override
  String get pauseAndSettings => 'Pausa e configurações';

  @override
  String tilesLeft(int count) {
    return '$count peças restantes';
  }

  @override
  String get restartLevelTitle => 'Reiniciar nível?';

  @override
  String get restartLevelBody => 'Seu progresso neste tabuleiro será perdido.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get arrangingTiles => 'Organizando peças…';

  @override
  String get buildError => 'Algo deu errado ao montar este tabuleiro.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get boardCleared => 'Tabuleiro limpo!';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'Nível $level · $difficulty';
  }

  @override
  String get threeStarTip =>
      'Conclua sem Dica, Embaralhar ou Mágica para 3 estrelas';

  @override
  String get newBest => 'Novo recorde!';

  @override
  String achievementUnlocked(String title) {
    return 'Conquista: $title';
  }

  @override
  String get finishJourney => 'Concluir a jornada';

  @override
  String get replay => 'Repetir';

  @override
  String get home => 'Início';

  @override
  String get noMatchesTitle => 'Sem pares disponíveis';

  @override
  String get noMatchesBody =>
      'Nenhuma peça livre combina agora. Um embaralhamento grátis redistribui as peças restantes em um tabuleiro com solução garantida.';

  @override
  String get undo => 'Desfazer';

  @override
  String get freeShuffle => 'Embaralhar grátis';

  @override
  String get paused => 'Pausado';

  @override
  String get resume => 'Continuar';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels níveis · $stars ★ · $matches pares';
  }

  @override
  String get play => 'JOGAR';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'Bloqueado';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get sectionAudio => 'Som e vibração';

  @override
  String get music => 'Música';

  @override
  String get musicSubtitle => 'Melodia relaxante de fundo';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get soundEffectsSubtitle => 'Toques, pares e comemorações';

  @override
  String get vibration => 'Vibração';

  @override
  String get vibrationSubtitle => 'Resposta tátil suave';

  @override
  String get sectionDisplay => 'Tela';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get dimBlocked => 'Escurecer peças bloqueadas';

  @override
  String get dimBlockedSubtitle => 'Facilita ver as peças livres';

  @override
  String get reduceMotion => 'Reduzir movimento';

  @override
  String get reduceMotionSubtitle => 'Menos animações e partículas';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get sectionHelp => 'Ajuda';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get howToPlaySubtitle => 'Regras, reforços e estrelas';

  @override
  String get allSettings => 'Todas as configurações';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current de $total';
  }

  @override
  String get htpTitle1 => 'Combine pares';

  @override
  String get htpBody1 =>
      'Toque em duas peças com a mesma imagem para removê-las. Remova todas para vencer.';

  @override
  String get htpTitle2 => 'Só peças livres';

  @override
  String get htpBody2 =>
      'Uma peça está livre quando nada está sobre ela e seu lado esquerdo ou direito está aberto. Peças bloqueadas não podem ser escolhidas.';

  @override
  String get htpFree => 'Livre';

  @override
  String get htpBlocked => 'Bloqueada';

  @override
  String get htpTitle3 => 'Espie embaixo da pilha';

  @override
  String get htpBody3 =>
      'Toque e segure uma peça para ver o que a bloqueia. Planeje para liberar as peças de que precisa.';

  @override
  String get htpTitle4 => 'Reforços';

  @override
  String get htpBody4 => 'Cada nível oferece novos reforços.';

  @override
  String get boosterHintDesc => 'Mostra um par que você pode combinar.';

  @override
  String get boosterUndoDesc => 'Desfaz seu último par. Sempre grátis.';

  @override
  String get boosterShuffleDesc =>
      'Redistribui as peças restantes em um tabuleiro solucionável.';

  @override
  String get boosterMagicDesc =>
      'Toque em uma peça livre e ela combina com a gêmea automaticamente.';

  @override
  String get htpTitle5 => 'Ganhe estrelas';

  @override
  String htpBody5(int total) {
    return 'Conclua sem Dica, Embaralhar ou Mágica para 3 estrelas. Todos os $total níveis têm solução.';
  }

  @override
  String get htpNext => 'Próximo';

  @override
  String get htpBack => 'Voltar';

  @override
  String get htpDone => 'Vamos jogar!';

  @override
  String get htpSkip => 'Pular';

  @override
  String get msgTileFree => 'Esta peça está livre!';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'Sem $booster neste nível.';
  }

  @override
  String get msgNoWinningMoves =>
      'Sem jogadas vencedoras — tente Desfazer ou Embaralhar.';

  @override
  String get msgNothingToUndo => 'Nada para desfazer ainda.';

  @override
  String get msgCantShuffle =>
      'Estas peças não formam um tabuleiro vencível — tente Desfazer.';

  @override
  String get msgMagicArmed => 'Toque em uma peça livre para combiná-la.';

  @override
  String get msgTwinNotFree =>
      'A gêmea ainda não está livre — tente outra peça.';

  @override
  String get boosterHint => 'Dica';

  @override
  String get boosterUndo => 'Desfazer';

  @override
  String get boosterShuffle => 'Embaralhar';

  @override
  String get boosterMagic => 'Mágica';

  @override
  String get tierBeginner => 'Iniciante';

  @override
  String get tierApprentice => 'Aprendiz';

  @override
  String get tierAdept => 'Hábil';

  @override
  String get tierExpert => 'Especialista';

  @override
  String get tierMaster => 'Mestre';

  @override
  String get tierLegend => 'Lenda';

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffMedium => 'Médio';

  @override
  String get diffHard => 'Difícil';

  @override
  String get diffExpert => 'Especialista';

  @override
  String get layoutSmallRectangle => 'Caixinha';

  @override
  String get layoutLargeRectangle => 'Grande salão';

  @override
  String get layoutPyramid => 'Pirâmide';

  @override
  String get layoutDoublePyramid => 'Picos gêmeos';

  @override
  String get layoutDiamond => 'Losango';

  @override
  String get layoutCross => 'Cruz';

  @override
  String get layoutButterfly => 'Borboleta';

  @override
  String get layoutFlower => 'Flor';

  @override
  String get layoutCircle => 'Anel';

  @override
  String get layoutStaircase => 'Escada';

  @override
  String get layoutZigzag => 'Zigue-zague';

  @override
  String get layoutLayeredSquare => 'Bolo em camadas';

  @override
  String get layoutAsymmetricTower => 'Farol';

  @override
  String get layoutClusters => 'Ilhas';

  @override
  String get layoutComplex => 'Fortaleza';

  @override
  String get layoutProcedural => 'Selva';

  @override
  String get layoutPile => 'Pilha de tesouros';

  @override
  String get layoutShape => 'Imagem';

  @override
  String shapeLetter(String name) {
    return 'Letra $name';
  }

  @override
  String shapeNumber(String name) {
    return 'Número $name';
  }

  @override
  String get shapeLittleHeart => 'Coraçãozinho';

  @override
  String get shapePlus => 'Mais';

  @override
  String get shapeLittleHouse => 'Casinha';

  @override
  String get shapeLittleFish => 'Peixinho';

  @override
  String get shapeCat => 'Gato';

  @override
  String get shapeBunny => 'Coelhinho';

  @override
  String get shapeOwl => 'Coruja';

  @override
  String get shapeFish => 'Peixe';

  @override
  String get shapeTurtle => 'Tartaruga';

  @override
  String get shapeCrab => 'Caranguejo';

  @override
  String get shapeBear => 'Urso';

  @override
  String get shapeDuck => 'Pato';

  @override
  String get shapeButterfly => 'Borboleta';

  @override
  String get shapeSnail => 'Caracol';

  @override
  String get shapeHeart => 'Coração';

  @override
  String get shapeStar => 'Estrela';

  @override
  String get shapeHouse => 'Casa';

  @override
  String get shapeTree => 'Árvore';

  @override
  String get shapeMushroom => 'Cogumelo';

  @override
  String get shapeUmbrella => 'Guarda-chuva';

  @override
  String get shapeBell => 'Sino';

  @override
  String get shapeCrown => 'Coroa';

  @override
  String get shapeGem => 'Joia';

  @override
  String get shapeRocket => 'Foguete';

  @override
  String get shapeAnchor => 'Âncora';

  @override
  String get shapeApple => 'Maçã';

  @override
  String get shapeHourglass => 'Ampulheta';

  @override
  String get shapeSailboat => 'Veleiro';

  @override
  String get shapeSun => 'Sol';

  @override
  String get shapeSpade => 'Espadas';

  @override
  String get shapeKey => 'Chave';

  @override
  String get shapeCup => 'Xícara';

  @override
  String get themeFruits => 'Feira de frutas';

  @override
  String get themeAnimals => 'Amigos animais';

  @override
  String get themeSweets => 'Doceria';

  @override
  String get themeGarden => 'Jardim secreto';

  @override
  String get themeOcean => 'Azul profundo';

  @override
  String get themeFantasy => 'Reino da fantasia';

  @override
  String get themeObjects => 'Tesouros do dia a dia';

  @override
  String get achFirstClearTitle => 'Primeira flor';

  @override
  String get achFirstClearDesc => 'Conclua seu primeiro tabuleiro.';

  @override
  String get achTenLevelsTitle => 'Estrela em ascensão';

  @override
  String get achTenLevelsDesc => 'Conclua 10 níveis.';

  @override
  String get achFiftyLevelsTitle => 'Mestre das peças';

  @override
  String get achFiftyLevelsDesc => 'Conclua 50 níveis.';

  @override
  String get achHundredLevelsTitle => 'Lenda do bosque';

  @override
  String get achHundredLevelsDesc => 'Conclua 100 níveis.';

  @override
  String get achPerfectTenTitle => 'Perfeccionista';

  @override
  String get achPerfectTenDesc => 'Ganhe 3 estrelas em 10 níveis.';

  @override
  String get achSpeedsterTitle => 'Velocista';

  @override
  String get achSpeedsterDesc =>
      'Conclua um tabuleiro em menos de 60 segundos.';

  @override
  String get achThousandMatchesTitle => 'Colecionador';

  @override
  String get achThousandMatchesDesc => 'Faça 1.000 pares.';

  @override
  String get achPureSkillTitle => 'Pura habilidade';

  @override
  String get achPureSkillDesc =>
      'Conclua um tabuleiro de 4+ camadas sem reforços.';
}
