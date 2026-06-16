import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/colors/app_colors.dart';
import '../../therapist/providers/therapist_provider.dart';
import '../../therapist/models/therapist_model.dart';

// HTML Design Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _novaPurple = Color(0xFFCABEFF);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

// Category Images
const _categoryImages = {
  'Anxiety': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAQEjoCJ5-Thi4Y_WOu-lW36YfMxjzyQ5xvGO6kQQ9gJ6wFGNN6YvG24G9fKBnmuyvvtAfx2fprYz2SkDkiX-HsSg0lfTPOrbaNSjJLEpzfzx_C5wb2Ljkdr9ryuH5u_Ae-QYjbu_Fj0aLanRg_WICFYCf5xhG0iPYdizMkGz6QdDJ4qIEUF4cuAp3TjCXa9tynyj8AQ4SfAec58iRuzob9AOQ5kjATYBmfIgHjP31Z5ageZaPRcvp9Z8rk-VaU5mz1MnA0wkDXHsi2',
  'Sleep': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBG_0K2iJ66c5Z17WK_wQuokWMA4bwTrMumCkjfE9rkPCIP32JCAQV8pYwezhLiHtfL9MIx6vGXTJl7SsDu2TszTq2THjgE8YpWIvqKaZQGyUK9_V7XR3Pr8fYqs236Z5OozPkt5ZdyEApTsWmvepMp3o4RTd43vIT512YPlT4OxANhm7U3unc02UnkXdCLkZ90tSSHMW6Uxz2uNqjarc3ytJnpg0KA265neHggah2qVBV9m0aeBOHsmrR4G0UDvGm6_BQucg2izlTv',
  'Burnout': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSY5OgX9QeqZvBjqmLc2oM_gOwXnY-rjegb9Q3ptO_BrpxabRuqugqdkFkrP94pfjah0H22mJ-x5y1V4l3Iqi5bcb_HfRxaukhu5_2YLnoASmtMFgXdkKT80poyzz_aOA-ZFSmy36hjYi1FdZWSJKajhh7iJRpFVTWAw4Qkf4GF9TYS7JwZQLigsvzqEDT4J9nTSAKmXkau1HMWWTRdm1AN-fB55ddnBvQbE6P46Xy7ShpAjSSStSsnfHak9T2_7vFygEdzfD-eY8t',
  'Mindfulness': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCWQ0bVIvwJcba4ttEzGSk5GJlr26NkdfpBf3SNT15sNy2uqSzCOiVsQESMRqNun8_VodOumdvfEaRPExX8sl2EtSXCKoJylUIRoR3Dpxp9HWNFaUqt0gEia9GmLYLik9HKXqMnZHzjLD7nzmGAUTJos3IM1P1TSA-orzY41opgDk1rhoJVg4dW6z2VhN05ImcmHFlTt4u0o9aq1Eq_pgqSbUhx3uk9OYPitBhFufw3wWbJh_xms8pseNJaC_W7rM72teNg15s_5jjz',
};

class TherapistHomeScreenV2 extends ConsumerStatefulWidget {
  const TherapistHomeScreenV2({super.key});

  @override
  ConsumerState<TherapistHomeScreenV2> createState() => _TherapistHomeScreenV2State();
}

class _TherapistHomeScreenV2State extends ConsumerState<TherapistHomeScreenV2> {

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredTherapistsProvider);

    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -100, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          Positioned(bottom: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()))),
          
          // Cosmic Particles
          const Positioned.fill(child: _ParticleBackground()),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeroSection(),
                    const SizedBox(height: 64),
                    _buildSmartMatchSection(),
                    const SizedBox(height: 64),
                    
                    // Featured Specialist
                    featuredAsync.when(
                      data: (therapists) {
                        if (therapists.isEmpty) return const SizedBox.shrink();
                        // Find Dr. Sarah Jenkins or fallback to first
                        final sarah = therapists.firstWhere((t) => t.name.contains('Sarah Jenkins'), orElse: () => therapists.first);
                        return _buildTopRecommendation(sarah);
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_,__) => const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 64),
                    _buildCategoriesGrid(),
                    const SizedBox(height: 64),
                    
                    // Other Specialists
                    featuredAsync.when(
                      data: (therapists) {
                        if (therapists.length <= 1) return const SizedBox.shrink();
                        final others = therapists.where((t) => !t.name.contains('Sarah Jenkins')).toList();
                        return _buildMoreSpecialists(others);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_,__) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 64),
                    _buildFooter(),
                  ]),
                ),
              ),
            ],
          ),
          
          // Crisis FAB
          Positioned(
            bottom: 32, right: 32,
            child: _buildCrisisFAB(),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Text('MindNova', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: _backgroundDeep.withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))))))),
      actions: [
        IconButton(icon: const Icon(Icons.settings, color: _primaryColor), onPressed: () {}),
        Container(
          margin: const EdgeInsets.only(right: 24, left: 8),
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuCB5RcqW_mkRfM3rrncaJo8q-2WwclxBBHPN9wq7bbsZRoBtyMGOR9y4BuohLp0sIOQXNSCmyPJyhW_7Vi_6M9RD_xSkwPPMbPp5Exqi4cZw1_xYZxa6GGhmXBw1S3Dnxaq2xRHq-YMNFvZInR5BJYFUwQrV5NvvVUh5KnJVhrveQy77243jilKC0s0-GzTLD1Esm-vQAbTFl2T0ivnzj37FjiIxMRpy0P4BTavU3FeuiaIKEj1qHWsp6zPF6a5NMRbvF0LYn-kLPTm', fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Professional Support\n', style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1)),
        Text('When You Need It', style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, color: _primaryColor, height: 0.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _glassBorder),
            boxShadow: [BoxShadow(color: _novaPurple.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: -10)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, color: _primaryColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOVA INSIGHT', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1, color: _primaryColor)),
                    const SizedBox(height: 8),
                    Text('"Recent reflections suggest elevated anxiety during late-night sessions. I\'ve curated a list of specialists who focus on nocturnal cognitive patterns and CBT."', 
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16, runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/therapist/match'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: const Color(0xFF32285E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Find Support'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _secondaryColor,
                side: const BorderSide(color: _secondaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Talk to Nova First'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Care Plan Banner
        GestureDetector(
          onTap: () => context.push('/therapist/care-plan'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _secondaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.favorite_outline, color: _secondaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Care Plan', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('View your therapy journey', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartMatchSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.2)])))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('AI Smart Match', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, color: _primaryColor))),
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent])))),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            _smartMatchCard(Icons.psychology, _primaryColor, 'Anxiety Themes', 'We identified recurring verbal patterns related to professional performance and social fatigue in your recent logs.'),
            const SizedBox(height: 24),
            _smartMatchCard(Icons.bedtime, _secondaryColor, 'Night-time Patterns', 'Your 2:00 AM interactions suggest a need for specialized sleep-hygiene protocols alongside traditional therapy.'),
            const SizedBox(height: 24),
            _smartMatchCard(Icons.self_improvement, const Color(0xFFF6E389), 'CBT Approach', 'Nova recommends Cognitive Behavioral Therapy (CBT) as it aligns best with your structured problem-solving style.'),
          ],
        ),
      ],
    );
  }

  Widget _smartMatchCard(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.inter(fontSize: 16, color: Colors.white.withValues(alpha: 0.7), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTopRecommendation(TherapistProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: Image.network(profile.imageUrl ?? '', height: 320, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 320, color: _primaryColor)),
              ),
              Positioned(
                top: 24, left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: _primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xFF32285E)),
                      const SizedBox(width: 8),
                      Text('92% Match', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF32285E))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOP RECOMMENDATION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2, color: _secondaryColor)),
                const SizedBox(height: 8),
                Text(profile.name, style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${profile.specialty} • ${profile.experienceYrs} years experience', style: GoogleFonts.inter(fontSize: 18, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 24),
                Text('"${profile.bio}"', style: GoogleFonts.inter(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white, height: 1.5)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: (profile.styleTags.isNotEmpty ? profile.styleTags : ['Cognitive Behavioral Therapy', 'Panic Disorders'])
                    .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    )).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/therapist/profile', extra: profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: const Color(0xFF32285E),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Book Initial Consultation'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Browse Categories', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: _categoryImages.entries.map((e) => _categoryCard(e.key, e.value)).toList(),
        ),
      ],
    );
  }

  Widget _categoryCard(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.4)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, _backgroundDeep.withValues(alpha: 0.8)]),
            ),
          ),
          Positioned(
            bottom: 24, left: 24,
            child: Text(title, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreSpecialists(List<TherapistProfile> therapists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Discover More\nSpecialists', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2)),
        const SizedBox(height: 32),
        ...therapists.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(t.imageUrl ?? '', width: 128, height: 128, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 128, height: 128, color: _primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.name, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('\$${t.hourlyRate ~/ 10}/hr', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('88% Match • ${t.title}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _secondaryColor)),
                const SizedBox(height: 16),
                Text(t.bio, style: GoogleFonts.inter(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.verified, color: _novaPurple, size: 16),
                    const SizedBox(width: 8),
                    Text('Top Rated • ${t.experienceYrs} years exp.', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/therapist/profile', extra: t),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 48),
        Text('Your Privacy is Sacred', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: _primaryColor)),
        const SizedBox(height: 8),
        Text('MindNova uses end-to-end encryption for all sessions and data logs.', style: GoogleFonts.inter(fontSize: 16, color: Colors.white.withValues(alpha: 0.7)), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24, runSpacing: 16,
          children: [
            _footerBadge(Icons.lock, 'HIPAA Compliant'),
            _footerBadge(Icons.shield, '256-bit AES'),
            _footerBadge(Icons.fingerprint, 'Biometric Login'),
          ],
        ),
        const SizedBox(height: 48),
        Text('© 2024 MindNova Intelligence. All connections are encrypted.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }

  Widget _footerBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _secondaryColor, size: 20),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    );
  }

  Widget _buildCrisisFAB() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF93000A), // error-container
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFB4AB).withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: Color(0xFF93000A), blurRadius: 20)],
      ),
      child: const Center(child: Icon(Icons.emergency, color: Color(0xFFFFDAD6), size: 32)),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER & PARTICLES
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
    _particles = List.generate(30, (i) => {
      'x': rng.nextDouble(),
      'y': rng.nextDouble(),
      'size': rng.nextDouble() * 4 + 1,
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
    final paint = Paint()..color = _novaPurple;
    for (var p in particles) {
      final double driftX = sin(time * pi * 2 + p['offset']) * 50;
      final double y = (p['y'] * size.height) - (time * 100 * p['speed']);
      paint.color = _novaPurple.withValues(alpha: 0.2);
      canvas.drawCircle(Offset((p['x'] * size.width) + driftX, y % size.height), p['size'], paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
