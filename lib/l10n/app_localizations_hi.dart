// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'टाइल ग्रोव';

  @override
  String get tagline => 'जोड़े खोजें। बगीचा साफ़ करें।';

  @override
  String playLevel(int level) {
    return 'लेवल $level खेलें';
  }

  @override
  String continueLevel(int level) {
    return 'लेवल $level जारी रखें';
  }

  @override
  String replayLevel(int level) {
    return 'लेवल $level फिर खेलें';
  }

  @override
  String levelOfTotal(int level, int total, String tier) {
    return 'लेवल $level / $total • $tier';
  }

  @override
  String allLevelsCleared(int total) {
    return 'सभी $total लेवल पूरे!';
  }

  @override
  String get menuLevels => 'लेवल';

  @override
  String get menuAwards => 'पुरस्कार';

  @override
  String get menuSettings => 'सेटिंग्स';

  @override
  String get homeInfo =>
      'दो एक जैसी खुली टाइलें टैप करके हटाएँ। टाइल तब खुली होती है जब उसके ऊपर कुछ न हो और उसका बायाँ या दायाँ किनारा खाली हो। किसी टाइल को देर तक दबाकर देखें कि उसे क्या रोक रहा है।';

  @override
  String levelLabel(int level) {
    return 'लेवल $level';
  }

  @override
  String get back => 'वापस';

  @override
  String get pauseAndSettings => 'रोकें और सेटिंग्स';

  @override
  String tilesLeft(int count) {
    return '$count टाइलें बाकी';
  }

  @override
  String get restartLevelTitle => 'लेवल फिर से शुरू करें?';

  @override
  String get restartLevelBody => 'इस बोर्ड की आपकी मौजूदा प्रगति मिट जाएगी।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get restart => 'फिर शुरू करें';

  @override
  String get arrangingTiles => 'टाइलें सजाई जा रही हैं…';

  @override
  String get buildError => 'यह बोर्ड बनाते समय कुछ गड़बड़ हो गई।';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get boardCleared => 'बोर्ड साफ़!';

  @override
  String levelDifficulty(int level, String difficulty) {
    return 'लेवल $level · $difficulty';
  }

  @override
  String get threeStarTip =>
      '3 सितारों के लिए संकेत, फेरबदल या जादू के बिना पूरा करें';

  @override
  String get newBest => 'नया रिकॉर्ड!';

  @override
  String achievementUnlocked(String title) {
    return 'उपलब्धि: $title';
  }

  @override
  String get finishJourney => 'सफ़र पूरा करें';

  @override
  String get replay => 'फिर खेलें';

  @override
  String get home => 'होम';

  @override
  String get noMatchesTitle => 'कोई जोड़ा नहीं बचा';

  @override
  String get noMatchesBody =>
      'अभी कोई भी खुली टाइल मेल नहीं खाती। मुफ़्त फेरबदल बची हुई टाइलों को ऐसे बोर्ड में फिर से बाँटेगा जो ज़रूर पूरा हो सकता है।';

  @override
  String get undo => 'वापस लें';

  @override
  String get freeShuffle => 'मुफ़्त फेरबदल';

  @override
  String get paused => 'रुका हुआ';

  @override
  String get resume => 'जारी रखें';

  @override
  String awardsSummary(int levels, int stars, int matches) {
    return '$levels लेवल पूरे · $stars ★ · $matches जोड़े';
  }

  @override
  String get play => 'खेलें';

  @override
  String tierRange(String tier, int first, int last) {
    return '$tier  ·  $first–$last';
  }

  @override
  String get locked => 'बंद';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get sectionAudio => 'ध्वनि और कंपन';

  @override
  String get music => 'संगीत';

  @override
  String get musicSubtitle => 'सुकून भरा पृष्ठभूमि संगीत';

  @override
  String get soundEffects => 'ध्वनि प्रभाव';

  @override
  String get soundEffectsSubtitle => 'टैप, जोड़े और जश्न';

  @override
  String get vibration => 'कंपन';

  @override
  String get vibrationSubtitle => 'हल्की कंपन प्रतिक्रिया';

  @override
  String get sectionDisplay => 'डिस्प्ले';

  @override
  String get appearance => 'रूप';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get dimBlocked => 'रुकी टाइलें धुंधली करें';

  @override
  String get dimBlockedSubtitle => 'खुली टाइलें आसानी से दिखें';

  @override
  String get reduceMotion => 'कम एनिमेशन';

  @override
  String get reduceMotionSubtitle => 'कम एनिमेशन और कण';

  @override
  String get sectionLanguage => 'भाषा';

  @override
  String get sectionHelp => 'सहायता';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get howToPlaySubtitle => 'नियम, बूस्टर और सितारे';

  @override
  String get allSettings => 'सभी सेटिंग्स';

  @override
  String version(String version) {
    return 'संस्करण $version';
  }

  @override
  String htpStep(int current, int total) {
    return '$current / $total';
  }

  @override
  String get htpTitle1 => 'जोड़े मिलाएँ';

  @override
  String get htpBody1 =>
      'एक जैसी तस्वीर वाली दो टाइलें टैप करके हटाएँ। लेवल जीतने के लिए सारी टाइलें हटाएँ।';

  @override
  String get htpTitle2 => 'सिर्फ़ खुली टाइलें';

  @override
  String get htpBody2 =>
      'टाइल तब खुली है जब उस पर कुछ न हो और उसका बायाँ या दायाँ किनारा खाली हो। रुकी टाइलें नहीं चुनी जा सकतीं।';

  @override
  String get htpFree => 'खुली';

  @override
  String get htpBlocked => 'रुकी';

  @override
  String get htpTitle3 => 'ढेर के नीचे झाँकें';

  @override
  String get htpBody3 =>
      'किसी टाइल को देर तक दबाएँ और देखें कि कौन-सी टाइलें उसे रोक रही हैं। ज़रूरी टाइलें खोलने की पहले से योजना बनाएँ।';

  @override
  String get htpTitle4 => 'बूस्टर';

  @override
  String get htpBody4 => 'हर लेवल में आपको बूस्टर का नया सेट मिलता है।';

  @override
  String get boosterHintDesc => 'मिलाने लायक एक जोड़ा दिखाता है।';

  @override
  String get boosterUndoDesc => 'आपका पिछला जोड़ा वापस लेता है। हमेशा मुफ़्त।';

  @override
  String get boosterShuffleDesc =>
      'बची टाइलों को हल होने लायक बोर्ड में फिर बाँटता है।';

  @override
  String get boosterMagicDesc =>
      'खुली टाइल टैप करें, वह अपने जोड़ीदार से अपने आप मिल जाएगी।';

  @override
  String get htpTitle5 => 'सितारे कमाएँ';

  @override
  String htpBody5(int total) {
    return '3 सितारों के लिए बिना संकेत, फेरबदल या जादू के बोर्ड पूरा करें। सभी $total लेवल हल हो सकते हैं।';
  }

  @override
  String get htpNext => 'आगे';

  @override
  String get htpBack => 'पीछे';

  @override
  String get htpDone => 'चलो खेलें!';

  @override
  String get htpSkip => 'छोड़ें';

  @override
  String get msgTileFree => 'यह टाइल मिलाने के लिए खुली है!';

  @override
  String msgNoBoosterLeft(String booster) {
    return 'इस लेवल में $booster खत्म।';
  }

  @override
  String get msgNoWinningMoves =>
      'यहाँ से जीतने की कोई चाल नहीं — वापस लें या फेरबदल आज़माएँ।';

  @override
  String get msgNothingToUndo => 'अभी वापस लेने को कुछ नहीं।';

  @override
  String get msgCantShuffle =>
      'इन टाइलों से जीतने लायक बोर्ड नहीं बन सकता — वापस लें आज़माएँ।';

  @override
  String get msgMagicArmed => 'अपने आप मिलाने के लिए कोई खुली टाइल टैप करें।';

  @override
  String get msgTwinNotFree =>
      'इसका जोड़ीदार अभी खुला नहीं — दूसरी टाइल आज़माएँ।';

  @override
  String get boosterHint => 'संकेत';

  @override
  String get boosterUndo => 'वापस';

  @override
  String get boosterShuffle => 'फेरबदल';

  @override
  String get boosterMagic => 'जादू';

  @override
  String get tierBeginner => 'शुरुआती';

  @override
  String get tierApprentice => 'प्रशिक्षु';

  @override
  String get tierAdept => 'कुशल';

  @override
  String get tierExpert => 'विशेषज्ञ';

  @override
  String get tierMaster => 'उस्ताद';

  @override
  String get tierLegend => 'महारथी';

  @override
  String get diffEasy => 'आसान';

  @override
  String get diffMedium => 'मध्यम';

  @override
  String get diffHard => 'कठिन';

  @override
  String get diffExpert => 'विशेषज्ञ';

  @override
  String get layoutSmallRectangle => 'छोटा डिब्बा';

  @override
  String get layoutLargeRectangle => 'बड़ा हॉल';

  @override
  String get layoutPyramid => 'पिरामिड';

  @override
  String get layoutDoublePyramid => 'जुड़वाँ चोटियाँ';

  @override
  String get layoutDiamond => 'हीरा';

  @override
  String get layoutCross => 'क्रॉस';

  @override
  String get layoutButterfly => 'तितली';

  @override
  String get layoutFlower => 'फूल';

  @override
  String get layoutCircle => 'छल्ला';

  @override
  String get layoutStaircase => 'सीढ़ियाँ';

  @override
  String get layoutZigzag => 'टेढ़ी-मेढ़ी';

  @override
  String get layoutLayeredSquare => 'परतदार केक';

  @override
  String get layoutAsymmetricTower => 'प्रकाशस्तंभ';

  @override
  String get layoutClusters => 'द्वीप';

  @override
  String get layoutComplex => 'किला';

  @override
  String get layoutProcedural => 'जंगल';

  @override
  String get layoutPile => 'ख़ज़ाने का ढेर';

  @override
  String get layoutShape => 'चित्र';

  @override
  String shapeLetter(String name) {
    return 'अक्षर $name';
  }

  @override
  String shapeNumber(String name) {
    return 'अंक $name';
  }

  @override
  String get shapeLittleHeart => 'छोटा दिल';

  @override
  String get shapePlus => 'प्लस';

  @override
  String get shapeLittleHouse => 'छोटा घर';

  @override
  String get shapeLittleFish => 'छोटी मछली';

  @override
  String get shapeCat => 'बिल्ली';

  @override
  String get shapeBunny => 'खरगोश';

  @override
  String get shapeOwl => 'उल्लू';

  @override
  String get shapeFish => 'मछली';

  @override
  String get shapeTurtle => 'कछुआ';

  @override
  String get shapeCrab => 'केकड़ा';

  @override
  String get shapeBear => 'भालू';

  @override
  String get shapeDuck => 'बत्तख';

  @override
  String get shapeButterfly => 'तितली';

  @override
  String get shapeSnail => 'घोंघा';

  @override
  String get shapeHeart => 'दिल';

  @override
  String get shapeStar => 'तारा';

  @override
  String get shapeHouse => 'घर';

  @override
  String get shapeTree => 'पेड़';

  @override
  String get shapeMushroom => 'मशरूम';

  @override
  String get shapeUmbrella => 'छाता';

  @override
  String get shapeBell => 'घंटी';

  @override
  String get shapeCrown => 'मुकुट';

  @override
  String get shapeGem => 'रत्न';

  @override
  String get shapeRocket => 'रॉकेट';

  @override
  String get shapeAnchor => 'लंगर';

  @override
  String get shapeApple => 'सेब';

  @override
  String get shapeHourglass => 'रेत घड़ी';

  @override
  String get shapeSailboat => 'पाल नाव';

  @override
  String get shapeSun => 'सूरज';

  @override
  String get shapeSpade => 'हुकुम';

  @override
  String get shapeKey => 'चाबी';

  @override
  String get shapeCup => 'प्याला';

  @override
  String get themeFruits => 'फल बाज़ार';

  @override
  String get themeAnimals => 'पशु मित्र';

  @override
  String get themeSweets => 'मिठाई की दुकान';

  @override
  String get themeGarden => 'गुप्त बगीचा';

  @override
  String get themeOcean => 'गहरा नीला';

  @override
  String get themeFantasy => 'कल्पना लोक';

  @override
  String get themeObjects => 'रोज़ के ख़ज़ाने';

  @override
  String get achFirstClearTitle => 'पहला फूल';

  @override
  String get achFirstClearDesc => 'अपना पहला बोर्ड पूरा करें।';

  @override
  String get achTenLevelsTitle => 'उभरता सितारा';

  @override
  String get achTenLevelsDesc => '10 लेवल पूरे करें।';

  @override
  String get achFiftyLevelsTitle => 'टाइल उस्ताद';

  @override
  String get achFiftyLevelsDesc => '50 लेवल पूरे करें।';

  @override
  String get achHundredLevelsTitle => 'बगीचे का महारथी';

  @override
  String get achHundredLevelsDesc => '100 लेवल पूरे करें।';

  @override
  String get achPerfectTenTitle => 'परफ़ेक्शनिस्ट';

  @override
  String get achPerfectTenDesc => '10 लेवल में 3 सितारे पाएँ।';

  @override
  String get achSpeedsterTitle => 'तेज़ रफ़्तार';

  @override
  String get achSpeedsterDesc => '60 सेकंड से कम में बोर्ड पूरा करें।';

  @override
  String get achThousandMatchesTitle => 'संग्राहक';

  @override
  String get achThousandMatchesDesc => '1,000 जोड़े बनाएँ।';

  @override
  String get achPureSkillTitle => 'शुद्ध कौशल';

  @override
  String get achPureSkillDesc =>
      'बिना बूस्टर के 4+ परतों वाला बोर्ड पूरा करें।';
}
