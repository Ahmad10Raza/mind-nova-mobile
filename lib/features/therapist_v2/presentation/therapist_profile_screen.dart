import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../therapist/models/therapist_model.dart';

// HTML Design Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _novaPurple = Color(0xFFCABEFF);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistProfileScreen extends StatefulWidget {
  final TherapistProfile profile;

  const TherapistProfileScreen({super.key, required this.profile});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  int _selectedDateIndex = 0;
  int _selectedModeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: 200, left: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: 200, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          
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
                    _buildProfileHero(),
                    const SizedBox(height: 32),
                    _buildAboutSection(),
                    const SizedBox(height: 32),
                    _buildAiReadinessCard(),
                    const SizedBox(height: 32),
                    _buildAvailabilitySelection(),
                    const SizedBox(height: 140), // Space for bottom CTA
                  ]),
                ),
              ),
            ],
          ),
          
          // Bottom CTA Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomCTA(),
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
      title: Text('Profile', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
      actions: [
        IconButton(icon: const Icon(Icons.share, color: _primaryColor), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(color: _novaPurple.withValues(alpha: 0.2), shape: BoxShape.circle, boxShadow: [BoxShadow(color: _novaPurple.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 10)]),
            ),
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_primaryColor, _secondaryColor], begin: Alignment.topRight, end: Alignment.bottomLeft),
                boxShadow: [BoxShadow(color: _secondaryColor.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    widget.profile.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(color: _primaryColor),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _secondaryColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00201C), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('Available Today', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00201C))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(widget.profile.name, style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFFDFE2F3))),
        const SizedBox(height: 4),
        Text('${widget.profile.title} • ${widget.profile.experienceYrs}+ Years Exp.', style: GoogleFonts.inter(fontSize: 18, color: _primaryColor)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statCard('EXPERIENCE', '${widget.profile.experienceYrs}+ Years'),
            const SizedBox(width: 16),
            _statCard('LANGUAGES', widget.profile.languages.map((l) => l.substring(0,2).toUpperCase()).join(', ')),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: const Color(0xFFC9C4D0))),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFDFE2F3))),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
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
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _primaryColor),
              const SizedBox(width: 8),
              Text('About ${widget.profile.name.split(' ').firstWhere((e) => !e.contains('.'), orElse: () => widget.profile.name)}', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.profile.bio, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0), height: 1.6)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.profile.styleTags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), border: Border.all(color: _primaryColor.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(20)),
              child: Text(tag, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryColor)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiReadinessCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B1F2C), Color(0xFF111155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF00C3AF), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.psychology, color: Color(0xFF004A42)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Emotional Readiness', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: _secondaryColor)),
                      Text('Prepared by Nova AI', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFC9C4D0))),
                    ],
                  ),
                ],
              ),
              Switch(value: true, onChanged: (v) {}, activeColor: _secondaryColor),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radar, color: _secondaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text('Identified Focus Areas', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _focusAreaItem(Icons.warning, const Color(0xFFFFB4AB), 'Elevated Anxiety (7-day trend)'),
                    const SizedBox(height: 8),
                    _focusAreaItem(Icons.bedtime, _primaryColor, 'Disrupted Sleep Cycles'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.forum, color: _secondaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text('Suggested Starters', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _starterItem('"How can I manage the physical tension I feel before work?"'),
                    const SizedBox(height: 8),
                    _starterItem('"I\'ve noticed a pattern in my evening ruminations..."'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _focusAreaItem(IconData icon, Color iconColor, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _backgroundDeep.withValues(alpha: 0.4), border: Border.all(color: const Color(0xFF353946).withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0)))),
        ],
      ),
    );
  }

  Widget _starterItem(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.05), border: Border.all(color: _primaryColor, width: 2), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontStyle: FontStyle.italic, color: const Color(0xFFC9C4D0))),
    );
  }

  Widget _buildAvailabilitySelection() {
    final now = DateTime.now();
    final dates = List.generate(6, (i) => now.add(Duration(days: i)));
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Your Session', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final d = dates[i];
              final isSelected = i == _selectedDateIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDateIndex = i),
                child: Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _novaPurple : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? _primaryColor : _glassBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(i == 0 ? 'TODAY' : days[d.weekday % 7], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF32285E) : const Color(0xFFC9C4D0))),
                      Text('${d.day}', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: isSelected ? const Color(0xFF32285E) : Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _modeButton(0, Icons.videocam, 'Video')),
            const SizedBox(width: 12),
            Expanded(child: _modeButton(1, Icons.mic, 'Voice')),
            const SizedBox(width: 12),
            Expanded(child: _modeButton(2, Icons.chat, 'Text')),
          ],
        ),
      ],
    );
  }

  Widget _modeButton(int index, IconData icon, String label) {
    final isSelected = index == _selectedModeIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedModeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _secondaryColor : _glassBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? _secondaryColor : const Color(0xFFC9C4D0)),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? _secondaryColor : const Color(0xFFC9C4D0))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('60 MIN SESSION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, color: const Color(0xFFC9C4D0))),
                    Text('\$${widget.profile.hourlyRate.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: _primaryColor)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/therapist/profile/chat', extra: widget.profile),
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/therapist/profile/booking', extra: widget.profile);
                    },
                    icon: const Icon(Icons.calendar_today, size: 20),
                    label: const Text('Book Session'),
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
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER & PARTICLES (Reused from Home)
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
    _particles = List.generate(40, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 3 + 1,
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
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      final double driftX = sin(time * pi * 2 + p['offset']) * 20;
      final double y = (p['y'] * size.height) - (time * 100 * p['speed']);
      paint.color = Colors.white.withValues(alpha: 0.3);
      canvas.drawCircle(Offset((p['x'] * size.width) + driftX, y % size.height), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
