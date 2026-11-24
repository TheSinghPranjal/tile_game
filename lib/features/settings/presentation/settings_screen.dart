import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/game_audio.dart';
import '../../../core/l10n/l10n.dart';
import '../../help/presentation/how_to_play_screen.dart';
import '../domain/game_settings.dart';

/// Full settings page: audio, display, language and help.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _Section(
              title: l.sectionAudio,
              children: AudioToggles.tiles(context, ref),
            ),
            _Section(
              title: l.sectionDisplay,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(children: [
                    Icon(Icons.brightness_6_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 16),
                    Text(l.appearance,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_rounded),
                          label: Text(l.themeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_rounded),
                          label: Text(l.themeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_rounded),
                          label: Text(l.themeDark),
                        ),
                      ],
                      selected: {s.themeMode},
                      onSelectionChanged: (v) =>
                          n.update(s.copyWith(themeMode: v.first)),
                    ),
                  ),
                ),
                _SwitchRow(
                  icon: Icons.contrast_rounded,
                  title: l.dimBlocked,
                  subtitle: l.dimBlockedSubtitle,
                  value: s.dimBlockedTiles,
                  onChanged: (v) => n.update(s.copyWith(dimBlockedTiles: v)),
                ),
                _SwitchRow(
                  icon: Icons.motion_photos_off_rounded,
                  title: l.reduceMotion,
                  subtitle: l.reduceMotionSubtitle,
                  value: s.reduceMotion,
                  onChanged: (v) => n.update(s.copyWith(reduceMotion: v)),
                ),
              ],
            ),
            _Section(
              title: l.sectionLanguage,
              children: [
                for (final lang in AppLanguage.values)
                  _LanguageRow(
                    language: lang,
                    selected: s.language == lang,
                    onTap: () => n.update(s.copyWith(language: lang)),
                  ),
              ],
            ),
            _Section(
              title: l.sectionHelp,
              children: [
                ListTile(
                  leading: Icon(Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(l.howToPlay,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(l.howToPlaySubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HowToPlayScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Music, sound effects and vibration switches. Shared by the settings page
/// and the in-game pause sheet.
class AudioToggles {
  const AudioToggles._();

  static List<Widget> tiles(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return [
      _SwitchRow(
        icon: Icons.music_note_rounded,
        title: l.music,
        subtitle: l.musicSubtitle,
        value: s.music,
        onChanged: (v) => n.update(s.copyWith(music: v)),
      ),
      _SwitchRow(
        icon: Icons.volume_up_rounded,
        title: l.soundEffects,
        subtitle: l.soundEffectsSubtitle,
        value: s.sound,
        onChanged: (v) {
          n.update(s.copyWith(sound: v));
          // Let the player hear what they just turned on.
          if (v) ref.read(gameAudioProvider).play(Sfx.button);
        },
      ),
      _SwitchRow(
        icon: Icons.vibration_rounded,
        title: l.vibration,
        subtitle: l.vibrationSubtitle,
        value: s.haptics,
        onChanged: (v) {
          n.update(s.copyWith(haptics: v));
          if (v) HapticFeedback.mediumImpact();
        },
      ),
    ];
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      );
}

class _LanguageRow extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor:
            selected ? scheme.primary : scheme.surfaceContainerHighest,
        child: Text(
          language.code.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(language.nativeName,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : null,
    );
  }
}
