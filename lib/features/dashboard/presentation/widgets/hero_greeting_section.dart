import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../scoring/models/scoring_model.dart';
import '../../../notifications/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/network/network_constants.dart';

class HeroGreetingSection extends ConsumerWidget {
  final String userName;
  final RiskCategory? riskLevel;
  final int streakDays;

  const HeroGreetingSection({
    super.key,
    required this.userName,
    this.riskLevel,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    const isNight = true; // Header is now always in "Deep Theme" for maximum contrast
    final greeting = _getGreeting(hour);
    final insight = _getInsight(riskLevel, streakDays);
    
    final authState = ref.watch(authProvider);
    final avatarUrl = authState.avatarUrl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: DashboardTheme.currentHeroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ─── Dreamscape Background Animation ────────────────────────
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: DreamscapeBackground(),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Greeting + Bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: _buildMenuButton(isNight),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isNight ? Colors.white60 : DashboardTheme.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isNight ? Colors.white : DashboardTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: _buildNotificationBell(ref, isNight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Insight + Mascot row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Profile Photo / Mascot
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: isNight ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            boxShadow: DashboardTheme.glowShadow(isNight ? Colors.white : DashboardTheme.primaryPurple),
                          ),
                          child: ClipOval(
                            child: avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('file://')
                              ? Image.network(
                                  avatarUrl.startsWith('http') 
                                    ? avatarUrl 
                                    : '${NetworkConstants.baseUrl}${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildFallbackAvatar(userName),
                                )
                              : _buildFallbackAvatar(userName),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Right: Insight text + streak
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isNight ? Colors.white70 : DashboardTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (streakDays > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isNight
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : DashboardTheme.primaryPurple.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isNight
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : DashboardTheme.primaryPurple.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$streakDays day streak',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(WidgetRef ref, bool isNight) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isNight
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isNight ? null : DashboardTheme.softShadow(Colors.black),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.notifications_none_rounded,
              color: isNight ? Colors.white70 : DashboardTheme.primaryPurple,
              size: 24,
            ),
          ),
          ref.watch(unreadCountProvider).when(
            data: (count) => count > 0
                ? Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: DashboardTheme.crisisRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(bool isNight) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isNight
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isNight ? null : DashboardTheme.softShadow(Colors.black),
      ),
      child: Center(
        child: Icon(
          Icons.menu_rounded,
          color: isNight ? Colors.white70 : DashboardTheme.primaryPurple,
          size: 24,
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 20) return 'Good Evening 🌅';
    return 'Good Night 🌙';
  }

  String _getInsight(RiskCategory? risk, int streakDays) {
    if (risk == null) return 'Track your mood to unlock personalized insights.';
    
    // 1. Encouraging (Consistency)
    if (streakDays >= 3 && (risk == RiskCategory.minimal || risk == RiskCategory.mild)) {
      return "You've been consistent for $streakDays days. Keep it up!";
    }
    
    // 2. Reflective (Recovery / showing up after a hard time)
    if (streakDays > 0 && (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.moderate)) {
      return "Things have been tough, but you showed up again. That takes strength.";
    }
    
    // 3. Motivating (General push)
    return "Let's tackle today and take it one step at a time.";
  }

  String _getIllustration(RiskCategory? risk, int hour) {
    if (risk == RiskCategory.high || risk == RiskCategory.severe || risk == RiskCategory.emergency) {
      return 'assets/illustrations/Confuse_Broken_Heart.png';
    }
    if (risk == RiskCategory.minimal || risk == RiskCategory.mild) {
      return 'assets/illustrations/FlowerOnMind.png';
    }
    if (hour >= 20 || hour < 6) {
      return 'assets/illustrations/Meditation.png';
    }
    return 'assets/illustrations/FlowerOnMind.png';
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: DashboardTheme.primaryPurple.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
// ─── Dreamscape Background Widget ─────────────────────────────
class DreamscapeBackground extends StatefulWidget {
  const DreamscapeBackground({super.key});

  @override
  State<DreamscapeBackground> createState() => _DreamscapeBackgroundState();
}

class _DreamscapeBackgroundState extends State<DreamscapeBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Floating Doodle 1: Roller of Emotion
              _buildFloatingDoodle(
                asset: 'assets/illustrations/Roller_Of_Mix_Emotion.png',
                top: 20 + math.sin(_controller.value * 2 * math.pi) * 10,
                right: -20 + math.cos(_controller.value * 2 * math.pi) * 5,
                size: 140,
                rotation: _controller.value * 2 * math.pi * 0.2,
                opacity: 0.28, // Increased for visibility
              ),

              // Floating Doodle 2: Balance
              _buildFloatingDoodle(
                asset: 'assets/illustrations/Balance_Of_Two_Mood.png',
                bottom: -30 + math.cos(_controller.value * 2 * math.pi) * 8,
                left: -40 + math.sin(_controller.value * 2 * math.pi) * 12,
                size: 180,
                rotation: -_controller.value * 2 * math.pi * 0.1,
                opacity: 0.22, // Increased for visibility
              ),

              // Floating Doodle 3: Mind Flower
              _buildFloatingDoodle(
                asset: 'assets/illustrations/FlowerOnMind.png',
                top: 60 + math.cos(_controller.value * 2 * math.pi + 1) * 15,
                left: 100 + math.sin(_controller.value * 2 * math.pi + 1) * 20,
                size: 80,
                rotation: _controller.value * 2 * math.pi * 0.3,
                opacity: 0.25, // Increased for visibility
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingDoodle({
    required String asset,
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double rotation,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

}
