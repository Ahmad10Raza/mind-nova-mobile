import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_insight_provider.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorColor = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistPatientInsightScreen extends ConsumerWidget {
  final String patientName;
  final String patientId;
  
  const TherapistPatientInsightScreen({super.key, required this.patientName, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(patientInsightProvider(patientId));

    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -50, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: insightAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: _primaryColor)),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: Center(child: Text('Error loading insights: $err', style: const TextStyle(color: _errorColor))),
                    ),
                    data: (insight) {
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildNovaSummary(insight.novaSummary),
                          const SizedBox(height: 24),
                          _buildRiskLevel(insight.cmhiRiskLevel),
                          const SizedBox(height: 24),
                          _buildMoodTrends(insight.moodTrends),
                          const SizedBox(height: 24),
                          _buildJournalThemes(insight.journalThemes),
                          const SizedBox(height: 48),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: _primaryColor), onPressed: () => context.pop()),
      title: Text('Patient Insights', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: _primaryColor.withValues(alpha: 0.2),
          child: Text(patientName.isNotEmpty ? patientName[0].toUpperCase() : '?', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: _primaryColor)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patientName, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: _secondaryColor),
                const SizedBox(width: 4),
                Text('Data shared by patient', style: GoogleFonts.inter(fontSize: 12, color: _secondaryColor)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNovaSummary(String summaryText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Nova AI Summary', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summaryText,
            style: GoogleFonts.inter(fontSize: 15, color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevel(String riskLevel) {
    bool isElevated = riskLevel.toLowerCase().contains('elevated') || riskLevel.toLowerCase().contains('high');
    Color levelColor = isElevated ? _errorColor : _secondaryColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CMHI Risk Level', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
              const SizedBox(height: 4),
              Text(riskLevel, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: levelColor)),
            ],
          ),
          Icon(isElevated ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: levelColor, size: 32),
        ],
      ),
    );
  }

  Widget _buildMoodTrends(List<double> trends) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood Trends (Last 7 Days)', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return _buildBar(labels[index], trends[index]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightRatio, {Color? color}) {
    final h = 100 * heightRatio;
    return Column(
      children: [
        Container(
          width: 20,
          height: h,
          decoration: BoxDecoration(color: color ?? _secondaryColor, borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
      ],
    );
  }

  Widget _buildJournalThemes(List<String> themes) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Journal Themes', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: themes.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _primaryColor.withValues(alpha: 0.3))),
              child: Text(t, style: GoogleFonts.inter(fontSize: 14, color: _primaryColor)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

