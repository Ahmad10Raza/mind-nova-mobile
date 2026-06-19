import 'package:flutter/material.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../../core/design/spacing/app_spacing.dart';
import '../../../core/design/surfaces/app_surfaces.dart';
import '../../../core/design/typography/app_typography.dart';

import 'widgets/explore_hero_section.dart';
import 'widgets/explore_understand_myself.dart';
import 'widgets/explore_improve_mood.dart';

import 'widgets/explore_toolkit_section.dart';
import 'widgets/explore_sleep_sos_section.dart';
import 'widgets/explore_diagnostic_center.dart';
import '../../tools/presentation/widgets/tool_search_delegate.dart';
import 'package:go_router/go_router.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  final _searchDelegate = ToolSearchDelegate();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header & Search ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s48, AppSpacing.s24, AppSpacing.s24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _showCategoryBottomSheet(value.toLowerCase(), 'Search Results');
                          _searchController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        hintText: 'What does your soul need today?',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                  AppSpacing.v16,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildIntentTag('test', 'Assessments'),
                        const SizedBox(width: 8),
                        _buildIntentTag('calm', 'Immediate Calm'),
                        const SizedBox(width: 8),
                        _buildIntentTag('sleep', 'Deep Sleep'),
                        const SizedBox(width: 8),
                        _buildIntentTag('focus', 'Focus Protocol'),
                        const SizedBox(width: 8),
                        _buildIntentTag('community', 'Community'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── 1. Discovery Hero (Command Center) ────────────
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.s32),
            sliver: SliverToBoxAdapter(
              child: ExploreHeroSection(),
            ),
          ),

          // ─── 2. Understand Myself (Bento Box) ──────────────
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.s32),
            sliver: SliverToBoxAdapter(
              child: ExploreUnderstandMyself(),
            ),
          ),

          // ─── 3. Improve My Mood Today ──────────────────────
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.s32),
            sliver: SliverToBoxAdapter(
              child: ExploreImproveMood(),
            ),
          ),



          // ─── 5. Wellness Toolkit (6 Categories with Doodles)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24, 0, AppSpacing.s24, AppSpacing.s32,
            ),
            sliver: SliverToBoxAdapter(
              child: ExploreToolkitSection(),
            ),
          ),



          // ─── 7. Diagnostic Center ──────────────────────────
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.s32),
            sliver: SliverToBoxAdapter(
              child: ExploreDiagnosticCenter(),
            ),
          ),

          // ─── Bottom Safe Area ────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  void _showCategoryBottomSheet(String query, String title) {
    final filteredTools = _searchDelegate.tools.where((tool) => 
        tool.title.toLowerCase().contains(query) || 
        tool.subtitle.toLowerCase().contains(query)
    ).toList();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppSurfaces.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(title, style: AppTypography.headingLarge),
                AppSpacing.v16,
                Expanded(
                  child: filteredTools.isEmpty
                      ? Center(
                          child: Text('No tools found', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted))
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filteredTools.length,
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 120),
                          itemBuilder: (context, index) {
                            final tool = filteredTools[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.push(tool.route);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                                padding: const EdgeInsets.all(AppSpacing.s16),
                                decoration: BoxDecoration(
                                  color: AppSurfaces.primary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: tool.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(tool.icon, color: tool.color),
                                    ),
                                    AppSpacing.h16,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tool.title, style: AppTypography.headingMedium),
                                          AppSpacing.v4,
                                          Text(tool.subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIntentTag(String queryText, String label) {
    return GestureDetector(
      onTap: () {
        _showCategoryBottomSheet(queryText, label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium,
        ),
      ),
    );
  }
}
