import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../therapist_v2/providers/therapist_dashboard_provider.dart';
import '../../../../core/network/api_client.dart';

class SidebarDrawer extends ConsumerStatefulWidget {
  const SidebarDrawer({super.key});

  @override
  ConsumerState<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends ConsumerState<SidebarDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDiscoveryMinimized = ref.watch(discoveryMinimizedProvider);
    final userName = authState.displayName ?? 'User';
    final userEmail = authState.email ?? 'No email';
    final currentRoute = GoRouterState.of(context).matchedLocation;

    // Fetch upcoming sessions for therapist quick-join
    List upcomingSessions = [];
    if (authState.hasTherapistProfile) {
      upcomingSessions = ref.watch(therapistDashboardProvider).maybeWhen(
        data: (data) => data.upcomingSessions,
        orElse: () => [],
      );
    }

    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // ─── Header with Animated Hide Button ─────────────
          _buildHeader(userName, userEmail, authState.avatarUrl, context),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // ─── Main Navigation ────────────────────────
                _buildSectionHeader('Navigation'),
                _buildMenuItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  label: 'Home Dashboard',
                  isActive: currentRoute == '/',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.explore_rounded,
                  label: 'Wellness Toolkit',
                  isActive: currentRoute == '/tools',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/tools');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.bubble_chart_rounded,
                  label: 'Emotional Analytics',
                  isActive: currentRoute == '/mood-analytics',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/mood-analytics');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Nova AI Chat',
                  isActive: currentRoute == '/chat',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/chat');
                  },
                ),
                
                const Divider(height: 40, thickness: 1, indent: 8, endIndent: 8),
                
                // ─── Insights & Reports ─────────────────────
                _buildSectionHeader('Insights'),
                _buildMenuItem(
                  context,
                  icon: Icons.insights_rounded,
                  label: 'Weekly Analysis',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/weekly-history');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.hub_rounded,
                  label: 'Nova AI Prediction Hub',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/ai-hub');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_rounded,
                  label: 'Clinical CMHI Score',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/cmhi-info');
                  },
                ),
                
                const Divider(height: 40, thickness: 1, indent: 8, endIndent: 8),
                
                // ─── Specialized Tools ──────────────────────
                _buildSectionHeader('Specialized'),
                if (!authState.hasTherapistProfile)
                  _buildMenuItem(
                    context,
                    icon: Icons.medical_services_rounded,
                    label: 'My Therapy Sessions',
                    isActive: currentRoute.startsWith('/therapist') && !authState.hasTherapistProfile,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/therapist');
                    },
                  ),
                _buildMenuItem(
                  context,
                  icon: Icons.history_rounded,
                  label: 'Journal History',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/journal/history');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.self_improvement_rounded,
                  label: 'Meditation Archive',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/meditation/history');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.contact_support_rounded,
                  label: 'Emergency Support',
                  color: DashboardTheme.crisisRed,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/support-plan');
                  },
                ),
                
                const Divider(height: 40, thickness: 1, indent: 8, endIndent: 8),
                
                // ─── Therapist Tools (Conditional) ──────────────────
                if (authState.hasTherapistProfile) ...[
                  _buildSectionHeader('Professional Panel'),
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_customize_rounded,
                    label: 'Therapist Dashboard',
                    isActive: currentRoute == '/therapist/portal',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/therapist/portal');
                    },
                  ),
                  if (upcomingSessions.isNotEmpty)
                    _buildMenuItem(
                      context,
                      icon: Icons.video_call_rounded,
                      label: 'Join Upcoming Call',
                      color: AppColors.novaPurpleLight,
                      onTap: () {
                        Navigator.of(context).pop();
                        final nextSession = upcomingSessions.first;
                        final patientName = nextSession['patient'] != null ? nextSession['patient']['name'] : 'Patient';
                        final patientId = nextSession['patientId'] ?? (nextSession['patient'] != null ? nextSession['patient']['id'] : 'unknown');
                        final therapistId = nextSession['therapistId'] ?? (nextSession['therapist'] != null ? nextSession['therapist']['id'] : 'unknown');
                        final roomId = 'room_${patientId}_${therapistId}';
                        context.push('/therapist/session/live', extra: {
                          'isTherapistRole': true,
                          'remoteName': patientName,
                          'roomId': roomId,
                        });
                      },
                    ),
                  _buildMenuItem(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Client Messages',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/therapist/portal');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.event_available_rounded,
                    label: 'Manage Availability',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/therapist/portal');
                    },
                  ),
                  const Divider(height: 40, thickness: 1, indent: 8, endIndent: 8),
                ],
                
                // ─── Account ────────────────────────────────
                _buildSectionHeader('Account'),
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile Settings',
                  isActive: currentRoute == '/profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  color: DashboardTheme.crisisRed,
                  onTap: () {
                    final auth = ref.read(authProvider.notifier);
                    Navigator.of(context).pop();
                    auth.logout();
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'MindNova v2.0.5',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String email, String? avatarUrl, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      decoration: BoxDecoration(
        gradient: DashboardTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl.startsWith('http')
                              ? avatarUrl
                              : '${ref.read(apiClientProvider).baseUrl}${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackInitial(name),
                        )
                      : _buildFallbackInitial(name),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Creative Hide Button instead of X
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await _arrowController.forward();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: MouseRegion(
                onEnter: (_) => _arrowController.repeat(reverse: true),
                onExit: (_) => _arrowController.reverse(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hide',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: _arrowController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(-4 * _arrowController.value, 0),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.novaPurpleLight.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isActive ? AppColors.novaPurpleLight : (color ?? AppColors.textPrimary), 
          size: 22
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? AppColors.novaPurpleLight : (color ?? AppColors.textPrimary),
          ),
        ),
        trailing: isActive ? Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.novaPurpleLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }

}
