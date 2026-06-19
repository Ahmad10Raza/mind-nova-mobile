import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../../../core/theme/tools_theme.dart';
import '../providers/safety_provider.dart';
import '../models/crisis_model.dart';

/// Full-screen SOS / Quick Help overlay.
/// Triggered from Crisis Support section → "Quick Help"
class SosModeScreen extends ConsumerStatefulWidget {
  const SosModeScreen({super.key});

  @override
  ConsumerState<SosModeScreen> createState() => _SosModeScreenState();
}

class _SosModeScreenState extends ConsumerState<SosModeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _fadeCtrl;
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    // Pulse animation for the hero circle
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    )..forward();

    // Check offline status
    Connectivity().checkConnectivity().then((results) {
      if (mounted) setState(() => _isOffline = results.contains(ConnectivityResult.none));
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) setState(() => _isOffline = results.contains(ConnectivityResult.none));
    });

    // Trigger SOS on the provider
    Future.microtask(() {
      HapticFeedback.heavyImpact();
      ref.read(safetyProvider.notifier).triggerSos();
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyProvider);
    final primary = state.primaryContact;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Top bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(safetyProvider.notifier).deactivateSos();
                        context.go('/tools');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white70, size: 22),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(safetyProvider.notifier).deactivateSos();
                        context.go('/');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text('Quick Exit'),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: ToolsTheme.crisisRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: ToolsTheme.crisisRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: ToolsTheme.crisisRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('SOS Active',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: ToolsTheme.crisisRed,
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline mode active. Your support tools still work. We\'ll sync changes later.',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ─── Pulsing Hero ────────────────────────────────
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ToolsTheme.crisisRed.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.health_and_safety_rounded,
                              color: Colors.white, size: 52),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text('You are not alone',
                        style: GoogleFonts.outfit(
                          fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Take a slow breath. Help is right here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15, color: Colors.white60, height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ─── Crisis Call Options ───────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            // 1. Primary Saved Contact (if exists)
                            if (primary != null)
                              _buildPrimaryContactCard(primary),
                            
                            if (primary != null) const SizedBox(height: 12),

                            // 2. 988 Lifeline (Always show as primary or secondary)
                            _buildLifelineCard(),
                            
                            // Quick SMS (If user has contacts with allowQuickSms)
                            if (state.smsContacts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildQuickSmsCard(state.smsContacts),
                            ],
                            
                            // 3. Other contacts
                            if (state.contacts.length > 1) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Other Trusted Contacts',
                                  style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54,
                                  )),
                              ),
                              const SizedBox(height: 12),
                              ...state.contacts
                                  .where((c) => c.id != primary?.id)
                                  .map((c) => _buildContactCard(c)),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Quick Actions Grid ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _quickAction(
                        icon: Icons.air_rounded,
                        label: 'Breathe',
                        color: const Color(0xFF26A69A),
                        onTap: () {
                          ref.read(safetyProvider.notifier).logAction('SOS_BREATHE');
                          context.go('/breathing');
                        },
                      ),
                      _quickAction(
                        icon: Icons.landscape_rounded,
                        label: 'Ground',
                        color: const Color(0xFF8D6E63),
                        onTap: () {
                          ref.read(safetyProvider.notifier).logAction('SOS_GROUND');
                          context.go('/grounding');
                        },
                      ),
                      _quickAction(
                        icon: Icons.text_fields_rounded,
                        label: 'Text 741741',
                        color: const Color(0xFF1E88E5),
                        onTap: () {
                          launchUrl(Uri.parse('sms:741741?body=${Uri.encodeComponent("HOME")}'));
                        },
                      ),
                      _quickAction(
                        icon: Icons.self_improvement_rounded,
                        label: 'Meditate',
                        color: const Color(0xFFFFA726),
                        onTap: () {
                          ref.read(safetyProvider.notifier).logAction('SOS_MEDITATE');
                          context.go('/meditation');
                        },
                      ),
                    ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── "I'm Feeling Safer" ────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading ? null : () async {
                              HapticFeedback.mediumImpact();
                              await ref.read(safetyProvider.notifier).resolveCrisis();
                              if (context.mounted) {
                                context.go('/recovery');
                              }
                            },
                            icon: const Icon(Icons.favorite_rounded, size: 20),
                            label: Text(
                              state.isLoading ? 'Saving...' : 'I\'m Feeling Safer',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.white.withOpacity(0.15)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifelineCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        launchUrl(Uri.parse('tel:102'));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Call 102 Helpline',
                  style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
                Text('Free, 24/7, Confidential',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSmsCard(List<EmergencyContact> smsContacts) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        ref.read(safetyProvider.notifier).logAction('SOS_QUICK_SMS');
        
        final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
        final separator = isIOS ? ',' : ';';
        final numbers = smsContacts.map((c) => c.phoneNumber).join(separator);
        
        const msg = "SOS: I am having a difficult time and need support. Please reach out to me.";
        launchUrl(Uri.parse('sms:$numbers?body=${Uri.encodeComponent(msg)}'));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.message_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alert Trusted Contacts',
                    style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                  Text('Send SMS to ${smsContacts.length} people',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.send_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryContactCard(EmergencyContact c) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        if (c.id != null) {
          ref.read(safetyProvider.notifier).markContactUsed(c.id!);
        }
        launchUrl(Uri.parse('tel:${c.phoneNumber}'));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)], // Darker Green for personal contact
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Call ${c.name}',
                  style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
                Text(c.relation ?? 'Trusted Contact',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.phone_enabled_rounded, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: color,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          if (c.id != null) {
            ref.read(safetyProvider.notifier).markContactUsed(c.id!);
          }
          launchUrl(Uri.parse('tel:${c.phoneNumber}'));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                      style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
                      )),
                    if (c.relation != null)
                      Text(c.relation!,
                        style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white38,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.call_rounded, color: Color(0xFF43A047), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
