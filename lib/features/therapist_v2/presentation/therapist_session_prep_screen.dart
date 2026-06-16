import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../therapist/models/therapist_model.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorCrisis = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistSessionPrepScreen extends StatefulWidget {
  final TherapistProfile profile;

  const TherapistSessionPrepScreen({super.key, required this.profile});

  @override
  State<TherapistSessionPrepScreen> createState() => _TherapistSessionPrepScreenState();
}

class _TherapistSessionPrepScreenState extends State<TherapistSessionPrepScreen> {
  // Checklist State
  bool _chk1 = false;
  bool _chk2 = false;
  bool _chk3 = false;

  // Mood State
  String _selectedMood = 'Reflective';

  // Toggle State
  bool _shareCmhi = true;
  bool _shareMoodFlow = true;
  bool _shareJournal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: 100, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          
          // Cosmic Particles
          const Positioned.fill(child: _ParticleBackground()),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 32),
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    _buildChecklist(),
                    const SizedBox(height: 24),
                    _buildJournalSynthesis(),
                    const SizedBox(height: 24),
                    _buildMoodCheckIn(),
                    const SizedBox(height: 24),
                    _buildInsightSharing(),
                    const SizedBox(height: 120), // Bottom padding
                  ]),
                ),
              ),
            ],
          ),

          // Crisis FAB
          Positioned(
            bottom: 24, right: 24,
            child: _buildCrisisFab(),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primaryColor),
        onPressed: () => context.pop(),
      ),
      title: Text('Session Preparation', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), border: Border.all(color: _secondaryColor.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(20)),
            child: Text('Upcoming Session', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _secondaryColor)),
          ),
          const SizedBox(height: 16),
          Text('Prepare for your session with ${widget.profile.name}', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: _primaryColor)),
          const SizedBox(height: 16),
          Text('Review your progress, collect your thoughts, and choose what you\'d like to explore in your time together today.', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: _secondaryColor),
              const SizedBox(width: 12),
              Text('Pre-Session Checklist', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 24),
          _checklistItem(
            value: _chk1,
            onChanged: (v) => setState(() => _chk1 = v ?? false),
            title: 'What is the most significant event that happened since last week?',
            subtitle: 'Think about feelings, reactions, or shifts in mood.',
          ),
          const SizedBox(height: 12),
          _checklistItem(
            value: _chk2,
            onChanged: (v) => setState(() => _chk2 = v ?? false),
            title: 'How did you navigate your primary challenge this week?',
            subtitle: 'Did you use any of the tools we discussed?',
          ),
          const SizedBox(height: 12),
          _checklistItem(
            value: _chk3,
            onChanged: (v) => setState(() => _chk3 = v ?? false),
            title: 'Is there a specific topic you feel anxious or hesitant to bring up?',
            subtitle: 'Acknowledging this now can make it easier to start later.',
          ),
        ],
      ),
    );
  }

  Widget _checklistItem({required bool value, required ValueChanged<bool?> onChanged, required String title, required String subtitle}) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24, width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: _secondaryColor,
                checkColor: const Color(0xFF00201C),
                side: BorderSide(color: const Color(0xFF938F9A), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, color: value ? _primaryColor : const Color(0xFFDFE2F3))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, fontStyle: FontStyle.italic, color: const Color(0xFFC9C4D0))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalSynthesis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: _primaryColor),
                  const SizedBox(width: 12),
                  Text('Journal Synthesis', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF353946))),
                child: Text('Generated by Nova', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFC9C4D0))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(border: Border(left: BorderSide(color: _primaryColor.withValues(alpha: 0.4), width: 4))),
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                _synthesisItem(
                  color: _primaryColor,
                  title: '"You\'ve mentioned feeling a sense of \'restless anticipation\' in three entries this week, particularly in the evenings."',
                  subtitle: 'Recommended focus: Exploring the transition between work and home life.',
                ),
                const SizedBox(height: 16),
                _synthesisItem(
                  color: _secondaryColor,
                  title: '"Your resilience score increased after Tuesday\'s challenging meeting."',
                  subtitle: 'Recommended focus: Celebrating the win and identifying why your strategy worked.',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _synthesisItem({required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), border: Border.all(color: color.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFDFE2F3))),
          const SizedBox(height: 8),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
        ],
      ),
    );
  }

  Widget _buildMoodCheckIn() {
    final moods = ['Calm', 'Reflective', 'Energetic', 'Tired'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current State', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: moods.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _secondaryColor.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(color: isSelected ? _secondaryColor : const Color(0xFF353946)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(mood, style: GoogleFonts.inter(color: isSelected ? _secondaryColor : const Color(0xFFC9C4D0), fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            height: 4, width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF303442), borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Expanded(flex: 65, child: Container(decoration: BoxDecoration(color: _secondaryColor, borderRadius: BorderRadius.circular(4)))),
                Expanded(flex: 35, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Mood Equilibrium: Stable', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFC9C4D0))),
        ],
      ),
    );
  }

  Widget _buildInsightSharing() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: _primaryColor),
              const SizedBox(width: 12),
              Text('Insight Sharing', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Control what ${widget.profile.name} sees during the session. All data is encrypted and only visible for the next 60 minutes.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
          const SizedBox(height: 24),
          _toggleItem('CMHI Score', 'Monthly wellbeing index', _shareCmhi, (v) => setState(() => _shareCmhi = v)),
          const SizedBox(height: 16),
          _toggleItem('Mood Flow', 'Daily emotional trends', _shareMoodFlow, (v) => setState(() => _shareMoodFlow = v)),
          const SizedBox(height: 16),
          _toggleItem('Journal Summaries', 'AI-generated weekly themes', _shareJournal, (v) => setState(() => _shareJournal = v)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the post-session reflection screen for testing the flow
                context.push('/therapist/post-session');
              },
              icon: const Text('Share Insights with Therapist'),
              label: const Icon(Icons.send, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: const Color(0xFF32285E),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFDFE2F3))),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _secondaryColor,
          activeTrackColor: _secondaryColor.withValues(alpha: 0.5),
          inactiveTrackColor: const Color(0xFF303442),
        ),
      ],
    );
  }

  Widget _buildCrisisFab() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _errorCrisis.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)]),
      child: FloatingActionButton(
        onPressed: () => context.push('/sos-mode'),
        backgroundColor: _errorCrisis,
        child: const Icon(Icons.emergency, color: Color(0xFF690005)),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER & PARTICLES (Reused)
// ────────────────────────────────────────────────────────────────────────────
class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();
  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground> with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(20, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 2 + 1,
      'speed': rng.nextDouble() * 0.5 + 0.5,
      'offset': rng.nextDouble() * pi * 2,
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double time;
  _ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primaryColor;
    for (var p in particles) {
      final double driftX = sin(time * pi * 2 + p['offset']) * 20;
      final double y = (p['y'] * size.height) - (time * 100 * p['speed']);
      paint.color = _primaryColor.withValues(alpha: 0.3);
      canvas.drawCircle(Offset((p['x'] * size.width) + driftX, y % size.height), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
