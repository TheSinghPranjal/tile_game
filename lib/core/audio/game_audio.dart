import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/game_settings.dart';

/// Short sound effects. Files live in `assets/audio/` and were synthesized
/// for this game by `tool/synth_audio.py`.
enum Sfx {
  tap('tap.wav', 0.55),
  match('match.wav', 0.7),
  mismatch('mismatch.wav', 0.6),
  shuffle('shuffle.wav', 0.6),
  hint('hint.wav', 0.6),
  magic('magic.wav', 0.65),
  win('win.wav', 0.8),
  button('button.wav', 0.5);

  final String file;
  final double volume;
  const Sfx(this.file, this.volume);
}

/// Game audio: a looping background track plus one-shot effects.
/// Music and effects follow the player's settings independently.
abstract class GameAudio {
  void play(Sfx sfx);

  /// Applies the latest settings (starts / stops the music as needed).
  void apply(GameSettings settings);

  /// Called when the app goes to the background / comes back.
  void onAppPaused();
  void onAppResumed();

  void dispose();
}

/// Used in tests and anywhere audio plugins are unavailable.
class SilentAudio implements GameAudio {
  const SilentAudio();
  @override
  void play(Sfx sfx) {}
  @override
  void apply(GameSettings settings) {}
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
  @override
  void dispose() {}
}

class PlayerAudio implements GameAudio {
  static const _musicAsset = 'audio/music_garden.m4a';
  static const _musicVolume = 0.32;

  final _pools = <Sfx, Future<AudioPool>>{};
  AudioPlayer? _music;
  bool _musicOn = false;
  bool _soundOn = false;
  bool _foreground = true;

  PlayerAudio() {
    // Casual-game audio etiquette: mix with the player's own music or
    // podcasts instead of stopping it, and stay quiet when the iPhone's
    // silent switch is on (iOS "ambient" category does both).
    _guard(AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      android: const AudioContextAndroid(
        usageType: AndroidUsageType.game,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.none,
      ),
    )));
  }

  @override
  void apply(GameSettings s) {
    _soundOn = s.sound;
    if (s.sound) {
      // Warm the pools so the first tap has no delay.
      for (final x in Sfx.values) {
        _pool(x);
      }
    }
    if (s.music != _musicOn) {
      _musicOn = s.music;
      _syncMusic();
    }
  }

  @override
  void play(Sfx sfx) {
    if (!_soundOn || !_foreground) return;
    _guard(_pool(sfx).then((p) => p.start(volume: sfx.volume)));
  }

  @override
  void onAppPaused() {
    _foreground = false;
    _syncMusic();
  }

  @override
  void onAppResumed() {
    _foreground = true;
    _syncMusic();
  }

  Future<AudioPool> _pool(Sfx sfx) => _pools.putIfAbsent(
        sfx,
        () => AudioPool.create(
          source: AssetSource('audio/${sfx.file}'),
          maxPlayers: 3,
          playerMode: PlayerMode.lowLatency,
        ),
      );

  void _syncMusic() {
    final shouldPlay = _musicOn && _foreground;
    if (shouldPlay) {
      final player = _music ??= AudioPlayer(playerId: 'music');
      _guard(() async {
        await player.setReleaseMode(ReleaseMode.loop);
        if (player.state == PlayerState.paused) {
          await player.resume();
        } else if (player.state != PlayerState.playing) {
          await player.play(AssetSource(_musicAsset), volume: _musicVolume);
        }
      }());
    } else if (_music?.state == PlayerState.playing) {
      _guard(_music!.pause());
    }
  }

  /// Audio must never crash the game (e.g. a missing codec on a device).
  void _guard(Future<void> f) {
    f.catchError((Object e) => debugPrint('Audio error: $e'));
  }

  @override
  void dispose() {
    _music?.dispose();
    for (final p in _pools.values) {
      p.then((x) => x.dispose()).catchError((_) {});
    }
  }
}

/// Overridden with [SilentAudio] in tests.
final gameAudioProvider = Provider<GameAudio>((ref) {
  final audio = PlayerAudio();
  ref.onDispose(audio.dispose);
  audio.apply(ref.read(settingsProvider));
  ref.listen<GameSettings>(settingsProvider, (_, s) => audio.apply(s));
  return audio;
});
