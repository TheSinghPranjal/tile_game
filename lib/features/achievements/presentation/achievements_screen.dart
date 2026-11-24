import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../progress/data/progress_repository.dart';
import '../domain/achievements.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Awards'), backgroundColor: AppColors.cream),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final a in Achievement.values)
            Card(
              color: p.achievements.contains(a.name)
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              elevation: p.achievements.contains(a.name) ? 2 : 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Opacity(
                  opacity: p.achievements.contains(a.name) ? 1 : 0.3,
                  child: Text(a.badge, style: const TextStyle(fontSize: 30)),
                ),
                title: Text(a.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(a.description),
                trailing: p.achievements.contains(a.name)
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.success)
                    : const Icon(Icons.lock_outline_rounded,
                        color: Colors.black26),
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${p.levelsCleared} levels cleared · ${p.totalStars} ★ · ${p.totalMatches} matches',
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
