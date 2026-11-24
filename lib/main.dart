import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/game_constants.dart';
import 'core/storage.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/home/presentation/home_screen.dart';

/// Debug aid: `--dart-define=START_LEVEL=42` opens that level directly.
const _startLevel = int.fromEnvironment('START_LEVEL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const TileGroveApp(),
  ));
}

class TileGroveApp extends StatelessWidget {
  const TileGroveApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: GameConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: _startLevel > 0 && kDebugMode
            ? GameScreen(level: _startLevel)
            : const HomeScreen(),
      );
}
