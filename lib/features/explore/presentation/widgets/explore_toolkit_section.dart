import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../core/design/spacing/app_spacing.dart';
import '../../../../core/design/radius/app_radius.dart';
import 'package:go_router/go_router.dart';

class ExploreToolkitSection extends StatelessWidget {
  const ExploreToolkitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Toolkit',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        AppSpacing.v16,
        
        // Category 1: Calm Mind
        _buildCategorySection(
          title: '🧘 Calm Mind',
          color: AppColors.primary,
          items: [
            _ToolkitItem(title: 'Breathing Exercises', imagePath: 'assets/images/explore/BreathingRecoverySpirit.png', colSpan: 1, route: '/breathing'),
            _ToolkitItem(title: 'Grounding Techniques', imagePath: 'assets/images/explore/Grounding.jpg', colSpan: 1, route: '/grounding'),
            _ToolkitItem(title: 'Meditation', imagePath: 'assets/images/explore/MeditationV2.jpg', colSpan: 1, route: '/meditation'),
            _ToolkitItem(title: 'Recovery Hub', imagePath: 'assets/images/explore/GrowthSeedlingSpirit.png', colSpan: 1, route: '/recovery-engine'),
          ],
        ),
        AppSpacing.v24,

        // Category 2: Recovery & Sleep
        _buildCategorySection(
          title: '💤 Recovery & Sleep',
          color: AppColors.secondary,
          items: [
            _ToolkitItem(title: 'Sleep Tracking & Support', imagePath: 'assets/images/explore/SleepMoonSpirit.png', colSpan: 2, route: '/sleep'),
            _ToolkitItem(title: 'Audio & Soundscapes', imagePath: 'assets/images/explore/Audio.jpg', colSpan: 2, route: '/audio'),
          ],
        ),
        AppSpacing.v24,

        // Category 3: Focus & Clarity
        _buildCategorySection(
          title: '🎯 Focus & Clarity',
          color: AppColors.tertiary,
          items: [
            _ToolkitItem(title: 'Focus Timer', imagePath: 'assets/images/explore/FocusSpirit.png', colSpan: 1, route: '/focus'),
            _ToolkitItem(title: 'Challenges', imagePath: 'assets/images/explore/CelebrationSpirit.png', colSpan: 1, route: '/challenges'),
            _ToolkitItem(title: 'Habit Tracker', imagePath: 'assets/images/explore/Dual_Personality.png', colSpan: 2, route: '/habits'),
          ],
        ),
        AppSpacing.v24,

        // Category 4: Emotional Healing
        _buildCategorySection(
          title: '❤️ Emotional Healing',
          color: AppColors.primary,
          items: [
            _ToolkitItem(title: 'Journaling', imagePath: 'assets/images/explore/Journal.jpeg', colSpan: 1, route: '/journal'),
            _ToolkitItem(title: 'Gratitude Journal', imagePath: 'assets/images/explore/CalmHeartSpirit.png', colSpan: 1, route: '/gratitude'),
            _ToolkitItem(title: 'AI Prediction Hub', imagePath: 'assets/images/explore/ai_prediction_hub.png', colSpan: 1, route: '/prediction-hub'),
            _ToolkitItem(title: 'Nova AI Chat', imagePath: 'assets/images/explore/AI_Meditation.png', colSpan: 1, route: '/chat'),
          ],
        ),
        AppSpacing.v24,

        // Category 5: Community & Support
        _buildCategorySection(
          title: '👥 Community & Support',
          color: AppColors.secondary,
          items: [
            _ToolkitItem(title: 'Community Feed', imagePath: 'assets/images/explore/CommunitySupportSpirits.png', colSpan: 2, route: '/community'),
            _ToolkitItem(title: 'Support Groups', imagePath: 'assets/images/explore/community-care.jpg', colSpan: 1, route: '/groups'),
            _ToolkitItem(title: 'Live Community', imagePath: 'assets/images/explore/Live_Circles_chat.jpg', colSpan: 1, route: '/community/live_circles'),
          ],
        ),
        AppSpacing.v24,

        // Category 6: Professional Help
        _buildCategorySection(
          title: '🏥 Professional Help',
          color: AppColors.error,
          items: [
            _ToolkitItem(title: 'Therapist Sessions', imagePath: 'assets/images/explore/TherapySupportSpirit.png', colSpan: 2, route: '/therapist'),
            _ToolkitItem(title: 'Clinical Assessments', imagePath: 'assets/images/explore/Psychology_Counseling.jpg', colSpan: 1, route: '/assessment/depression'), // Redirecting to depression temporarily, could be a list screen
            _ToolkitItem(title: 'Crisis Support', imagePath: 'assets/images/explore/CrisisProtectionSpirit.png', colSpan: 1, route: '/crisis'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection({required String title, required Color color, required List<_ToolkitItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingMedium.copyWith(color: color),
        ),
        AppSpacing.v12,
        LayoutBuilder(
          builder: (context, constraints) {
            final double gap = AppSpacing.s12;
            final double itemWidth = (constraints.maxWidth - gap) / 2;

            List<Widget> rows = [];
            List<Widget> currentRow = [];
            int currentSpan = 0;

            for (var item in items) {
              if (item.colSpan == 2) {
                if (currentRow.isNotEmpty) {
                  rows.add(Row(children: currentRow));
                  rows.add(SizedBox(height: gap));
                  currentRow = [];
                  currentSpan = 0;
                }
                rows.add(_buildToolkitCard(item, constraints.maxWidth));
                rows.add(SizedBox(height: gap));
              } else {
                currentRow.add(_buildToolkitCard(item, itemWidth));
                currentSpan += 1;
                if (currentSpan == 2) {
                  currentRow.insert(1, SizedBox(width: gap));
                  rows.add(Row(children: currentRow));
                  rows.add(SizedBox(height: gap));
                  currentRow = [];
                  currentSpan = 0;
                }
              }
            }

            if (currentRow.isNotEmpty) {
              if (currentRow.length == 1) {
                // Pad to left
                rows.add(Row(children: [
                  currentRow.first,
                  SizedBox(width: gap),
                  SizedBox(width: itemWidth),
                ]));
              } else {
                rows.add(Row(children: currentRow));
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolkitCard(_ToolkitItem item, double width) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () => context.push(item.route),
          child: Container(
            width: width,
            height: 120, // min-h-[120px] in tailwind
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withOpacity(0.5), // glass-panel
              borderRadius: AppRadius.md,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: 500, // Optimize decoding for mobile memory limits
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.backgroundPrimary.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Text
            Positioned(
              left: AppSpacing.s12,
              bottom: AppSpacing.s12,
              right: AppSpacing.s12,
              child: Text(
                item.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
        );
      }
    );
  }
}

class _ToolkitItem {
  final String title;
  final String imagePath;
  final int colSpan;
  final String route;

  _ToolkitItem({required this.title, required this.imagePath, required this.colSpan, required this.route});
}
