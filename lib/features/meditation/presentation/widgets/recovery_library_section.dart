import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import '../../domain/meditation_model.dart';
import '../providers/meditation_provider.dart';

class RecoveryLibrarySection extends ConsumerStatefulWidget {
  const RecoveryLibrarySection({super.key});

  @override
  ConsumerState<RecoveryLibrarySection> createState() =>
      _RecoveryLibrarySectionState();
}

class _RecoveryLibrarySectionState
    extends ConsumerState<RecoveryLibrarySection> {
  int _selectedTab = 0;

  static const _tabs = [
    {'label': 'All', 'key': null},
    {'label': 'Sleep', 'key': 'SLEEP'},
    {'label': 'Anxiety', 'key': 'ANXIETY_RELIEF'},
    {'label': 'Stress', 'key': 'STRESS_RECOVERY'},
    {'label': 'Burnout', 'key': 'STRESS_RECOVERY'},
    {'label': 'Healing', 'key': 'HEALING'},
    {'label': 'Focus', 'key': 'FOCUS'},
    {'label': 'Growth', 'key': 'GRATITUDE'},
  ];

  @override
  Widget build(BuildContext context) {
    final categoryKey = _tabs[_selectedTab]['key'];
    final catalogAsync = ref.watch(meditationCatalogProvider(categoryKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter tabs
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
            physics: const BouncingScrollPhysics(),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => AppSpacing.h8,
            itemBuilder: (context, index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.novaPurple
                        : Colors.white.withAlpha(10),
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.novaPurple
                          : Colors.white.withAlpha(20),
                    ),
                  ),
                  child: Text(
                    _tabs[index]['label'] as String,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AppSpacing.v16,

        // Content grid
        catalogAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyLibrary();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: items.length > 6 ? 6 : items.length,
                itemBuilder: (context, index) =>
                    _LibraryCard(content: items[index]),
              ),
            );
          },
          loading: () => _buildLoadingGrid(),
          error: (_, __) => _buildEmptyLibrary(),
        ),
      ],
    );
  }

  Widget _buildEmptyLibrary() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20, vertical: AppSpacing.s32),
      child: Center(
        child: Column(
          children: [
            const Text('🧘', style: TextStyle(fontSize: 40)),
            AppSpacing.v12,
            Text(
              'No sessions in this category yet',
              style:
                  AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: AppRadius.lg,
            border: Border.all(color: Colors.white.withAlpha(10)),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.novaPurple,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final MeditationContent content;
  const _LibraryCard({required this.content});

  @override
  Widget build(BuildContext context) {
    // Mock mood lift score based on difficulty
    final moodLift = content.difficulty == 'Beginner'
        ? '+3'
        : content.difficulty == 'Moderate'
            ? '+4'
            : '+5';

    return GestureDetector(
      onTap: () => context.push('/meditation/player', extra: content),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: AppRadius.lg,
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Favorite
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.novaPurple.withAlpha(64),
                        AppColors.novaPurple.withAlpha(26),
                      ],
                    ),
                    borderRadius: AppRadius.sm,
                    border: Border.all(
                        color: AppColors.novaPurple.withAlpha(76)),
                  ),
                  child: const Center(
                      child: Text('🧘', style: TextStyle(fontSize: 18))),
                ),
                const Spacer(),
                Icon(Icons.favorite_border_rounded,
                    color: Colors.white.withAlpha(64), size: 18),
              ],
            ),
            AppSpacing.v12,

            // Title
            Text(
              content.title,
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.v8,

            // Duration + Difficulty
            Row(
              children: [
                _buildTag('${content.durationMinutes} min',
                    AppColors.novaPurple),
                AppSpacing.h4,
                _buildTag(content.difficulty, null),
              ],
            ),
            const Spacer(),

            // Mood lift
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successSoft.withAlpha(15),
                borderRadius: AppRadius.xs,
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded,
                      color: AppColors.successSoft, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$moodLift mood lift',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.successSoft,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withAlpha(color != null ? 26 : 10),
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color ?? AppColors.textMuted,
          fontSize: 9,
        ),
      ),
    );
  }
}
