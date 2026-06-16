import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/sleep_colors.dart';
import 'widgets/night_sky_background.dart';

/// Emergency calm-down screen for night anxiety, panic, and overthinking.
class SleepEmergencyScreen extends StatefulWidget {
  const SleepEmergencyScreen({super.key});

  @override
  State<SleepEmergencyScreen> createState() => _SleepEmergencyScreenState();
}

class _SleepEmergencyScreenState extends State<SleepEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int _affirmationIndex = 0;

  final List<String> _affirmations = [
    'You are safe.',
    'You do not need to solve\neverything tonight.',
    'Your mind can rest now.',
    'Tomorrow is a new day.',
    'This feeling will pass.',
    'You are doing enough.',
    'Let go of what you\ncannot control tonight.',
    'You deserve peace and rest.',
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.midnightBlack,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return NightSkyBackground(
            animationValue: _bgController.value,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          // ─── Header ─────────────────────────────
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: SleepColors.textSecondary),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Text(
                                'Calm Down',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: SleepColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 48),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ─── Affirmation Card ───────────────────
                          _buildAffirmationCard(),

                          const SizedBox(height: 32),

                          // ─── 5-4-3-2-1 Grounding ────────────────
                          _buildGroundingSection(),

                          const SizedBox(height: 32),

                          // ─── Quick Actions ──────────────────────
                          _buildQuickActions(context),

                          const Spacer(),

                          // ─── SOS Contact ────────────────────────
                          _buildSOSButton(),

                          const SizedBox(height: 32),
                        ],
                      ),
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

  Widget _buildAffirmationCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _affirmationIndex = (_affirmationIndex + 1) % _affirmations.length;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey(_affirmationIndex),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: SleepColors.glassCardWithGlow(SleepColors.lavenderGlow),
          child: Column(
            children: [
              const Icon(Icons.shield_moon_rounded, color: SleepColors.lavenderGlow, size: 32),
              const SizedBox(height: 20),
              Text(
                _affirmations[_affirmationIndex],
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: SleepColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap for next affirmation',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: SleepColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroundingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SleepColors.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.landscape_rounded, color: SleepColors.moonGold, size: 20),
              const SizedBox(width: 8),
              Text(
                '5-4-3-2-1 Grounding',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SleepColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGroundingStep('5', 'things you can see'),
          _buildGroundingStep('4', 'things you can touch'),
          _buildGroundingStep('3', 'things you can hear'),
          _buildGroundingStep('2', 'things you can smell'),
          _buildGroundingStep('1', 'thing you can taste'),
        ],
      ),
    );
  }

  Widget _buildGroundingStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: SleepColors.moonGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: SleepColors.moonGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            instruction,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SleepColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Moon Breathing',
            Icons.air_rounded,
            SleepColors.calmTeal,
            () => context.push('/sleep/breathing'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Talk to AI',
            Icons.auto_awesome_rounded,
            SleepColors.lavenderGlow,
            () => context.go('/chat'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: SleepColors.emergencyRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SleepColors.emergencyRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sos_rounded, color: SleepColors.emergencyRed, size: 20),
          const SizedBox(width: 10),
          Text(
            'Contact Safe Person',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SleepColors.emergencyRed,
            ),
          ),
        ],
      ),
    );
  }
}
