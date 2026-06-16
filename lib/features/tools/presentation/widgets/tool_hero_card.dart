import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../scoring/providers/scoring_provider.dart';
import '../../../scoring/models/scoring_model.dart';

/// Dynamic hero card at the top of the Tools Tab.
/// Changes content, gradient, and CTA based on user state + time of day.
class ToolHeroCard extends ConsumerStatefulWidget {
  const ToolHeroCard({super.key});

  @override
  ConsumerState<ToolHeroCard> createState() => _ToolHeroCardState();
}

class _ToolHeroCardState extends ConsumerState<ToolHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cmhiAsync = ref.watch(latestCMHIProvider);

    return cmhiAsync.when(
      data: (score) => _buildHero(context, score),
      loading: () => _buildHero(context, null),
      error: (_, __) => _buildHero(context, null),
    );
  }

  Widget _buildHero(BuildContext context, CMHIScore? score) {
    final hero = _resolveHeroContent(score);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (context, _) {
          return GestureDetector(
            onTap: hero.onTap != null ? () => hero.onTap!(context) : null,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 190),
              decoration: BoxDecoration(
                gradient: hero.gradient,
                borderRadius: BorderRadius.circular(DashboardTheme.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: hero.glowColor.withOpacity(
                        0.12 + _glowCtrl.value.clamp(0.0, 1.0) * 0.08),
                    blurRadius: 24 + _glowCtrl.value.clamp(0.0, 1.0) * 10,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  // Right-side large ghost icon
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: Icon(
                      hero.icon,
                      size: 80,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            hero.chipLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          hero.title,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hero.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // CTA button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            hero.ctaLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _HeroContent _resolveHeroContent(CMHIScore? score) {
    final hour = DateTime.now().hour;
    final risk = score?.riskCategory;

    // Crisis state — highest priority
    if (risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      return _HeroContent(
        title: 'We\'re Here For You',
        subtitle: 'Access emergency support and crisis tools.',
        ctaLabel: 'Get Help Now',
        chipLabel: '🛡️ PRIORITY',
        gradient: const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFFEF5350),
        icon: Icons.emergency_rounded,
        onTap: (ctx) => ctx.push('/breathing'),
      );
    }

    // High anxiety / stress
    if (risk == RiskCategory.high || risk == RiskCategory.moderate) {
      return _HeroContent(
        title: 'Take a Deep Breath',
        subtitle: 'Your stress level is elevated. Try a calming exercise.',
        ctaLabel: 'Start Breathing',
        chipLabel: '😮‍💨 RECOMMENDED',
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF26A69A),
        icon: Icons.air_rounded,
        onTap: (ctx) => ctx.push('/breathing'),
      );
    }

    // Time-based fallbacks
    if (hour >= 21 || hour < 5) {
      return _HeroContent(
        title: 'Ready to Wind Down?',
        subtitle: 'Activate sleep mode for a better night\'s rest.',
        ctaLabel: 'Sleep Mode',
        chipLabel: '🌙 EVENING',
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF283593),
        icon: Icons.dark_mode_rounded,
        onTap: (ctx) => ctx.push('/sleep'),
      );
    }

    if (hour < 12) {
      return _HeroContent(
        title: 'Start Your Day Mindfully',
        subtitle: 'Log your mood and set a positive intention.',
        ctaLabel: 'Log Mood',
        chipLabel: '☀️ MORNING',
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFFFF9800),
        icon: Icons.wb_sunny_rounded,
        onTap: (ctx) => ctx.push('/mood-checkin'),
      );
    }

    // Default
    return _HeroContent(
      title: 'Explore Your Toolkit',
      subtitle: '40+ tools for your mental wellbeing.',
      ctaLabel: 'Browse All',
      chipLabel: '✨ WELLNESS HUB',
      gradient: DashboardTheme.primaryGradient,
      glowColor: DashboardTheme.primaryPurple,
      icon: Icons.explore_rounded,
      onTap: null,
    );
  }
}

class _HeroContent {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String chipLabel;
  final LinearGradient gradient;
  final Color glowColor;
  final IconData icon;
  final void Function(BuildContext)? onTap;

  const _HeroContent({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.chipLabel,
    required this.gradient,
    required this.glowColor,
    required this.icon,
    this.onTap,
  });
}
