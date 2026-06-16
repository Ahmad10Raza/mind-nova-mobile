import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/dashboard_theme.dart';
import '../providers/scoring_provider.dart';
import '../models/scoring_model.dart';

class CMHIInfoScreen extends ConsumerWidget {
  const CMHIInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cmhiAsync = ref.watch(latestCMHIProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ─── Header AppBar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: DashboardTheme.primaryPurple,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Understanding CMHI',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5E4B8B), Color(0xFF9C27B0)],
                  ),
                ),
                child: Opacity(
                  opacity: 0.1,
                  child: Center(
                    child: Icon(Icons.analytics_rounded, size: 200, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // ─── Main Content ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Current Status Section
                  cmhiAsync.when(
                    data: (score) => _buildStatusSection(score),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 40),

                  // 2. What is CMHI?
                  _buildSectionHeader('What is CMHI?'),
                  const SizedBox(height: 12),
                  _buildIntroCard(),

                  const SizedBox(height: 40),

                  // 3. Risk Categorization (Creative Scale)
                  _buildSectionHeader('Clinical Risk Spectrum'),
                  const SizedBox(height: 12),
                  _buildRiskScaleSection(),

                  const SizedBox(height: 40),

                  // 4. The 5 Dimensions
                  _buildSectionHeader('Multi-Dimensional Analysis'),
                  const SizedBox(height: 12),
                  ...CMHIDimensionInfo.all.map((dim) => _buildDimensionCard(dim)),

                  const SizedBox(height: 40),

                  // 5. Algorithm Transparency
                  _buildSectionHeader('Dynamic Weighting Engine'),
                  const SizedBox(height: 12),
                  _buildAlgorithmCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScaleSection() {
    return Column(
      children: RiskCategory.values.map((cat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cat.color.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: cat.color.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                   cat.rangeText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: cat.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.label,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cat.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF636366),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1C1C1E),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatusSection(CMHIScore? score) {
    final currentScore = score?.cmhi ?? 0;
    final category = score?.riskCategory ?? RiskCategory.minimal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Current Position',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Spectrum Gauge
          _buildSpectrumGauge(currentScore),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                category.label,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF3A3A3C),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumGauge(double score) {
    final categories = RiskCategory.values;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: categories.map((c) => c.color).toList(),
                    ),
                  ),
                ),
                // Indicator
                Positioned(
                  left: ((score / 100).clamp(0.0, 1.0) * constraints.maxWidth) - 16,
                  top: -10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        score.toInt().toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Minimal', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
            Text('Crisis', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Text(
        'The Composite Mental Health Index (CMHI) is a proprietary, real-time metric that analyzes your internal data across multiple categories. Unlike static tools, it maps your "mental architecture" to identify risks before they manifest as crisis points.',
        style: GoogleFonts.inter(
          fontSize: 15,
          height: 1.6,
          color: const Color(0xFF3A3A3C),
        ),
      ),
    );
  }

  Widget _buildDimensionCard(CMHIDimensionInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DashboardTheme.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: DashboardTheme.primaryPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF8E8E93),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI-Driven Weighting',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The engine intelligently shifts focus during high-stress periods. If a physical "sleep crisis" is detected, the algorithm automatically increases the weight of Physiological markers from 20% to 40% to ensure the most critical risk is reflected in your daily score.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
