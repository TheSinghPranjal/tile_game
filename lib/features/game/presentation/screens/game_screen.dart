import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/common.dart';
import '../../../boosters/domain/booster.dart';
import '../../../settings/presentation/settings_panel.dart';
import '../controllers/game_controller.dart';
import '../controllers/game_view_state.dart';
import '../widgets/board_view.dart';
import '../widgets/game_dialogs.dart';
import '../widgets/game_hud.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;

  GameController get _controller => ref.read(gameControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.start(widget.level));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _controller.onAppResumed();
    }
  }

  // --------------------------------------------------------------- actions --

  Future<void> _onBooster(BoosterType t) async {
    switch (t) {
      case BoosterType.hint:
        await _controller.useHint();
      case BoosterType.undo:
        _controller.undo();
      case BoosterType.shuffle:
        await _controller.shuffle();
      case BoosterType.magic:
        _controller.armMagic();
    }
  }

  Future<void> _openMenu() async {
    _controller.pause();
    final action = await showModalBottomSheet<PauseAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      builder: (_) => const PauseSheet(settings: SettingsPanel()),
    );
    if (!mounted) return;
    switch (action) {
      case PauseAction.restart:
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Restart level?'),
            content: const Text('Your current progress on this board will be lost.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restart')),
            ],
          ),
        );
        if (ok == true) {
          _controller.restart();
        } else {
          _controller.resume();
        }
      case PauseAction.home:
        Navigator.of(context).pop();
      case PauseAction.resume:
      case null:
        _controller.resume();
    }
  }

  void _leave() {
    _controller.onAppPaused();
    Navigator.of(context).pop();
  }

  Future<void> _showCompletion(GameViewState s) async {
    if (_dialogOpen || s.reward == null) return;
    _dialogOpen = true;
    final next = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (c, _, _) => Stack(children: [
        const Positioned.fill(child: ConfettiOverlay()),
        Center(
          child: LevelCompleteDialog(
            level: s.levelNumber,
            reward: s.reward!,
            elapsedMs: s.elapsedMs,
            difficultyLabel: s.level?.difficulty.label ?? '',
            onNext: () => Navigator.pop(c, 'next'),
            onReplay: () => Navigator.pop(c, 'replay'),
            onHome: () => Navigator.pop(c, 'home'),
          ),
        ),
      ]),
      transitionBuilder: (_, a, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: a, child: child),
      ),
    );
    _dialogOpen = false;
    if (!mounted) return;
    switch (next) {
      case 'next':
        _controller.start(s.levelNumber + 1);
      case 'replay':
        _controller.start(s.levelNumber);
      default:
        Navigator.of(context).pop();
    }
  }

  Future<void> _showNoMoves() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (c) => NoMovesDialog(
        canUndo: ref.read(gameControllerProvider).session?.canUndo ?? false,
        onShuffle: () => Navigator.pop(c, 'shuffle'),
        onUndo: () => Navigator.pop(c, 'undo'),
      ),
    );
    _dialogOpen = false;
    if (!mounted) return;
    _controller.dismissNoMoves();
    if (choice == 'undo') {
      _controller.undo();
    } else {
      await _controller.shuffle(free: true);
    }
  }

  // ------------------------------------------------------------------ UI --

  @override
  Widget build(BuildContext context) {
    ref.listen<GamePhase>(gameControllerProvider.select((s) => s.phase),
        (prev, phase) {
      if (phase == GamePhase.completed) {
        _showCompletion(ref.read(gameControllerProvider));
      }
    });
    ref.listen<bool>(gameControllerProvider.select((s) => s.noMoves), (_, v) {
      if (v) _showNoMoves();
    });
    ref.listen<int>(gameControllerProvider.select((s) => s.toastNonce), (_, _) {
      final msg = ref.read(gameControllerProvider).toast;
      if (msg == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
        ));
    });

    final phase = ref.watch(gameControllerProvider.select((s) => s.phase));

    Widget body;
    if (phase == GamePhase.loading) {
      body = const _LoadingBoard();
    } else if (phase == GamePhase.error) {
      body = _ErrorBoard(onRetry: () => _controller.start(widget.level));
    } else {
      body = const BoardView();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: Stack(children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/game_bg.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                GameTopBar(onBack: _leave, onMenu: _openMenu),
                const SizedBox(height: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(phase == GamePhase.loading),
                      child: body,
                    ),
                  ),
                ),
                BoosterBar(onBooster: _onBooster),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _LoadingBoard extends StatelessWidget {
  const _LoadingBoard();

  @override
  Widget build(BuildContext context) => const Center(
        child: Pill(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 12),
            Text('Arranging tiles…',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
          ]),
        ),
      );
}

class _ErrorBoard extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBoard({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Something went wrong building this board.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ]),
      );
}
