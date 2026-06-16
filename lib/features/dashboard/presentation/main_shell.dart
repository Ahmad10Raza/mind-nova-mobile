import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/colors/app_colors.dart';
import '../../audio/widgets/audio_mini_player.dart';
import '../../audio/providers/audio_player_provider.dart';
import 'widgets/sidebar_drawer.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final isMiniPlayerVisible = ref.watch(audioPlayerProvider.select((s) => s.isMiniPlayerVisible));

    return Scaffold(
      extendBody: true, // Crucial for glassmorphism over content
      drawer: const SidebarDrawer(),
      body: child,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Persistent mini audio player
            if (isMiniPlayerVisible)
              const AudioMiniPlayer(),
            // Bottom nav bar
            Container(
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E4B8B).withValues(alpha: 0.12), // Subtle purple glow
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Deeper blur
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary.withValues(alpha: 0.6), // Dark translucent for glass effect
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1), // Subtle edge definition
                        width: 1.0,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              context,
                              index: 0,
                              currentIndex: currentIndex,
                              icon: Icons.grid_view_rounded,
                              label: 'Zen Garden',
                              onTap: () => context.go('/'),
                            ),
                            _buildNavItem(
                              context,
                              index: 1,
                              currentIndex: currentIndex,
                              icon: Icons.bubble_chart_rounded,
                              label: 'Mood',
                              onTap: () => context.go('/mood-analytics'),
                            ),
                            _buildNavItem(
                              context,
                              index: 2,
                              currentIndex: currentIndex,
                              icon: Icons.explore_rounded,
                              label: 'Explore',
                              onTap: () => context.go('/tools'),
                            ),
                            _buildNavItem(
                              context,
                              index: 3,
                              currentIndex: currentIndex,
                              icon: Icons.auto_awesome_rounded,
                              label: 'Nova',
                              onTap: () => context.go('/chat'),
                            ),
                            _buildNavItem(
                              context,
                              index: 4,
                              currentIndex: currentIndex,
                              icon: Icons.person_rounded,
                              label: 'Me',
                              onTap: () => context.go('/profile'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive 
                    ? const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Deeper cosmic purple
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: const Color(0xFF4A00E0).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.novaPurpleLight : AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    try {
      final String location = GoRouterState.of(context).matchedLocation;
      if (location == '/' || location.startsWith('/weekly-insight') || location.startsWith('/ai-suggestions')) return 0;
      if (location.startsWith('/mood-analytics') || location == '/mood-checkin') return 1;
      if (location.startsWith('/tools') || location.startsWith('/breathing') || location.startsWith('/sleep')) return 2;
      if (location.startsWith('/chat')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    } catch (_) {
      return 0; // Fallback during transition
    }
  }
}
