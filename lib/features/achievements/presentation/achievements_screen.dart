import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../progress/data/progress_repository.dart';
import '../domain/achievements.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final p = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.menuAwards)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final a in Achievement.values)
            Builder(builder: (context) {
              final earned = p.achievements.contains(a.name);
              return Card(
                color: earned
                    ? scheme.surfaceContainerHighest
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                elevation: earned ? 2 : 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Opacity(
                    opacity: earned ? 1 : 0.3,
                    child: Text(a.badge, style: const TextStyle(fontSize: 30)),
                  ),
                  title: Text(l.achievementTitle(a),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(l.achievementDescription(a)),
                  trailing: earned
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.success)
                      : Icon(Icons.lock_outline_rounded,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
              );
            }),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l.awardsSummary(p.levelsCleared, p.totalStars, p.totalMatches),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
