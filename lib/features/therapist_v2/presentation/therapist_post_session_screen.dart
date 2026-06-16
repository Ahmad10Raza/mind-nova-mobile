import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorCrisis = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistPostSessionScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const TherapistPostSessionScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<TherapistPostSessionScreen> createState() => _TherapistPostSessionScreenState();
}

class _TherapistPostSessionScreenState extends ConsumerState<TherapistPostSessionScreen> {
  int _selectedMoodIndex = 2; // Centered by default
  final TextEditingController _takeawaysController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Drained'},
    {'icon': Icons.sentiment_neutral, 'label': 'Still'},
    {'icon': Icons.spa, 'label': 'Centered'},
    {'icon': Icons.auto_awesome, 'label': 'Inspired'},
    {'icon': Icons.rocket_launch, 'label': 'Ready'},
  ];

  @override
  void dispose() {
    _takeawaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -50, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
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
                    _buildCurrentResonance(),
                    const SizedBox(height: 24),
                    _buildKeyTakeaways(),
                    const SizedBox(height: 24),
                    _buildNovaAssistant(),
                    const SizedBox(height: 24),
                    _buildRecoveryMetrics(),
                    const SizedBox(height: 48),
                    _buildActionBar(context),
                    const SizedBox(height: 120), // Bottom padding
                  ]),
                ),
              ),
            ],
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
      title: Text('MindNova', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
      actions: [
        IconButton(icon: const Icon(Icons.settings, color: Color(0xFFC9C4D0)), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How was your session today?', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, color: _primaryColor)),
        const SizedBox(height: 16),
        Text('Take a moment to ground yourself. Your journey flourishes in the space between action and reflection.', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0), height: 1.5)),
      ],
    );
  }

  Widget _buildCurrentResonance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _glassBorder),
        boxShadow: [BoxShadow(color: _primaryColor.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: -10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Resonance', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (index) {
              final isSelected = index == _selectedMoodIndex;
              final item = _moods[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = index),
                child: Column(
                  children: [
                    Container(
                      width: isSelected ? 64 : 56,
                      height: isSelected ? 64 : 56,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFCABEFF) : const Color(0xFF353946).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [BoxShadow(color: _primaryColor.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)] : null,
                      ),
                      child: Icon(item['icon'], color: isSelected ? const Color(0xFF1C1148) : const Color(0xFFC9C4D0), size: isSelected ? 32 : 28),
                    ),
                    const SizedBox(height: 12),
                    Text(item['label'], style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? _primaryColor : const Color(0xFFC9C4D0).withValues(alpha: 0.6))),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeaways() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: _secondaryColor),
              const SizedBox(width: 12),
              Text('Key Takeaways', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 24),
          Text('What did you learn today?', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFC9C4D0))),
          const SizedBox(height: 16),
          TextField(
            controller: _takeawaysController,
            maxLines: 5,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Reflect on your breakthroughs, insights, or even small shifts in perspective...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFFC9C4D0).withValues(alpha: 0.3)),
              filled: true,
              fillColor: const Color(0xFF171B28).withValues(alpha: 0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _secondaryColor.withValues(alpha: 0.5))),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Self-Compassion', 'Boundaries', 'Mindfulness'].map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.1), border: Border.all(color: _secondaryColor.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(20)),
              child: Text(tag, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _secondaryColor)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNovaAssistant() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _glassBorder),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.2), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: const SizedBox()))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF32285E), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nova Assistant', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: _primaryColor)),
                      Text('Personalized Insight', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 18, color: Colors.white, height: 1.5),
                  children: [
                    const TextSpan(text: '"Nova noticed you discussed '),
                    TextSpan(text: 'boundaries', style: GoogleFonts.inter(color: _secondaryColor, fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' today. Would you like a guided practice on this to reinforce your growth?"'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle, size: 24),
                  label: const Text('Start Guided Practice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: const Color(0xFF32285E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    backgroundColor: const Color(0xFF353946).withValues(alpha: 0.3),
                    side: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Save for later'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryMetrics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24), border: Border.all(color: _glassBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recovery Metrics', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
          const SizedBox(height: 24),
          _metricBar('Resilience', '+12% growth', _secondaryColor, 0.78),
          const SizedBox(height: 24),
          _metricBar('Inner Light', 'Stable', _primaryColor, 0.64),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.visibility, size: 16, color: Color(0xFFC9C4D0)),
              label: Text('Detailed Analytics', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBar(String label, String value, Color color, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10, width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF353946).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Expanded(flex: (progress * 100).toInt(), child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)))),
              Expanded(flex: ((1 - progress) * 100).toInt(), child: const SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency, color: _errorCrisis),
            const SizedBox(width: 12),
            Text('Crisis Support Available 24/7', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _errorCrisis)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF353946).withValues(alpha: 0.3),
                  side: const BorderSide(color: Color(0xFF353946)),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('Discard'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final dio = ref.read(apiClientProvider).dio;
                    final rawNotes = 'Patient Reflection: Mood: ${_moods[_selectedMoodIndex]['label']}\nTakeaways: ${_takeawaysController.text}';
                    
                    // Post to patient's latest session id placeholder
                    await dio.post('/therapists/ai/post-session/${widget.appointmentId}', data: {
                      'rawNotes': rawNotes,
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reflection Saved!')));
                      context.pop(); // navigate to home
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  disabledBackgroundColor: const Color(0xFF353946),
                  foregroundColor: const Color(0xFF32285E),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF32285E)))
                    : const Text('Save Reflection'),
              ),
            ),
          ],
        ),
      ],
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
    _particles = List.generate(15, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 3 + 1,
      'speed': rng.nextDouble() * 0.3 + 0.2, // slower
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
      final double y = (p['y'] * size.height) - (time * 50 * p['speed']); // drift slower
      paint.color = _primaryColor.withValues(alpha: 0.15);
      canvas.drawCircle(Offset((p['x'] * size.width) + driftX, y % size.height), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
