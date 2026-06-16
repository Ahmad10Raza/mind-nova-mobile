import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../providers/dashboard_provider.dart';

class TodayFocusCard extends ConsumerStatefulWidget {
  const TodayFocusCard({super.key});

  @override
  ConsumerState<TodayFocusCard> createState() => _TodayFocusCardState();
}

class _TodayFocusCardState extends ConsumerState<TodayFocusCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusAsync = ref.watch(todayFocusProvider);

    return focusAsync.when(
      data: (focus) => _buildCard(context, focus),
      loading: () => const SizedBox(height: 120), // Placeholder height
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, TodayFocus focus) {
    // Only apply pulse animation if it's a high-priority action (e.g. breathing/SOS)
    final bool isHighPriority = focus.type == FocusActionType.breathe || focus.type == FocusActionType.grounding;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (focus.route.isNotEmpty && focus.route != '/') {
          context.push(focus.route);
        } else if (focus.route == '/') {
           // Scroll down or indicate action
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DashboardTheme.cardWhite,
                borderRadius: BorderRadius.circular(DashboardTheme.radiusL),
                boxShadow: isHighPriority 
                  ? [
                      BoxShadow(
                        color: DashboardTheme.primaryPurple.withValues(alpha: 0.15 + (_pulseController.value * 0.1)),
                        blurRadius: 20 + (_pulseController.value * 10),
                        spreadRadius: 2 + (_pulseController.value * 4),
                      )
                    ]
                  : DashboardTheme.softShadow(DashboardTheme.primaryPurple),
                border: Border.all(
                  color: DashboardTheme.primaryPurple.withValues(
                    alpha: isHighPriority ? 0.3 + (_pulseController.value * 0.2) : 0.1
                  ),
                  width: isHighPriority ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: DashboardTheme.primaryPurple.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TODAY FOCUS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: DashboardTheme.primaryPurple.withValues(alpha: 0.7),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          focus.title,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: DashboardTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          focus.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: DashboardTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: DashboardTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: DashboardTheme.glowShadow(DashboardTheme.primaryPurple),
                    ),
                    child: Text(
                      focus.ctaLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
