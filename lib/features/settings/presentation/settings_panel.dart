import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/game_settings.dart';

/// Toggle list reused by the pause sheet and the home-screen settings.
class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    Widget tile(String title, String subtitle, bool value, IconData icon,
            ValueChanged<bool> onChanged) =>
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(icon),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          value: value,
          onChanged: onChanged,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile('Sound', 'Soft click on taps and matches', s.sound,
            Icons.volume_up_rounded, (v) => n.update(s.copyWith(sound: v))),
        tile('Haptics', 'Vibration feedback', s.haptics, Icons.vibration_rounded,
            (v) => n.update(s.copyWith(haptics: v))),
        tile('Dim blocked tiles', 'Make free tiles easier to spot',
            s.dimBlockedTiles, Icons.contrast_rounded,
            (v) => n.update(s.copyWith(dimBlockedTiles: v))),
        tile('Reduce motion', 'Fewer animations and particles', s.reduceMotion,
            Icons.motion_photos_off_rounded,
            (v) => n.update(s.copyWith(reduceMotion: v))),
      ],
    );
  }
}
