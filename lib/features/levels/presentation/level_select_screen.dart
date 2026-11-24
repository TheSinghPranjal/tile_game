import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common.dart';
import '../../progress/data/progress_repository.dart';
import '../domain/level_config.dart';

class LevelSelectScreen extends ConsumerWidget {
  final void Function(int level) onPlay;
  const LevelSelectScreen({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final shown = ((p.highestUnlocked + 20) / 10).ceil() * 10;

    final slivers = <Widget>[];
    final tiers = DifficultyTier.values;
    for (var t = 0; t < tiers.length; t++) {
      final first = tiers[t].firstLevel;
      if (first > shown) break;
      final last = t + 1 < tiers.length
          ? (tiers[t + 1].firstLevel - 1).clamp(first, shown)
          : shown;
      slivers
        ..add(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              '${tiers[t].displayName}  ·  $first–$last',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ))
        ..add(SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 76,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, k) {
                final level = first + k;
                final unlocked = level <= p.highestUnlocked;
                return _LevelCell(
                  level: level,
                  stars: p.stars[level] ?? 0,
                  unlocked: unlocked,
                  current: level == p.highestUnlocked,
                  onTap: unlocked
                      ? () {
                          Navigator.of(context).pop();
                          onPlay(level);
                        }
                      : null,
                );
              },
              childCount: last - first + 1,
            ),
          ),
        ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
        backgroundColor: AppColors.cream,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StarBadge(stars: p.totalStars),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [...slivers, const SliverToBoxAdapter(child: SizedBox(height: 32))],
      ),
    );
  }
}

class _LevelCell extends StatelessWidget {
  final int level;
  final int stars;
  final bool unlocked;
  final bool current;
  final VoidCallback? onTap;

  const _LevelCell({
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = current
        ? AppColors.gold
        : unlocked
            ? Colors.white
            : Colors.black.withValues(alpha: 0.06);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      elevation: unlocked ? 2 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unlocked)
              Text('$level',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: current ? Colors.white : AppColors.ink))
            else
              const Icon(Icons.lock_rounded, color: Colors.black26),
            const SizedBox(height: 4),
            if (unlocked && !current) StarRow(stars: stars, size: 13),
            if (current)
              const Text('PLAY',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
