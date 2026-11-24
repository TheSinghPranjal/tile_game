import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../help/presentation/how_to_play_screen.dart';
import 'settings_screen.dart';

/// Quick settings shown in the in-game pause sheet: the audio switches plus
/// links to the full settings page and the How to play guide.
class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...AudioToggles.tiles(context, ref),
        const Divider(height: 8),
        ListTile(
          leading: Icon(Icons.menu_book_rounded, color: primary),
          title: Text(l.howToPlay,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HowToPlayScreen())),
        ),
        ListTile(
          leading: Icon(Icons.tune_rounded, color: primary),
          title: Text(l.allSettings,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
    );
  }
}
