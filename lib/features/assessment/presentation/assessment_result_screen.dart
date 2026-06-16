import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/assessment_model.dart';

class AssessmentResultScreen extends StatelessWidget {
  final AssessmentResult result;
  
  const AssessmentResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Clinical Insights', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildScoreOrb(context),
            const SizedBox(height: 32),
            _buildRadarSection(context),
            const SizedBox(height: 32),
            _buildRiskBreakdown(context),
            const SizedBox(height: 32),
            _buildAIExplanation(context),
            const SizedBox(height: 32),
            _buildInsightsCard(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreOrb(BuildContext context) {
    final severityColor = _getSeverityColor(result.severityLevel);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4,
                color: Colors.white10,
              ),
            ),
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: result.totalScore / 100,
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                color: severityColor,
              ),
            ),
            Column(
              children: [
                Text(
                  '${result.totalScore}',
                  style: GoogleFonts.outfit(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'CMHI SCORE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: severityColor.withOpacity(0.5)),
          ),
          child: Text(
            result.severityLevel.toUpperCase(),
            style: GoogleFonts.inter(
              color: severityColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  // ─── RISK BREAKDOWN SECTION ───
  Widget _buildRiskBreakdown(BuildContext context) {
    final risks = <_RiskItem>[
      _RiskItem('Anxiety Risk', result.anxietyRisk ?? 0, Icons.psychology_outlined, const Color(0xFFE040FB)),
      _RiskItem('Depression Risk', result.depressionRisk ?? 0, Icons.cloud_outlined, const Color(0xFF448AFF)),
      _RiskItem('Burnout Risk', result.burnoutRisk ?? 0, Icons.local_fire_department_outlined, const Color(0xFFFF6E40)),
      _RiskItem('Crisis Risk', result.crisisRisk ?? 0, Icons.warning_amber_rounded, const Color(0xFFFF1744)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Sub-Indices',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Computed from your dimensional scores using clinical weighting formulas.',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 20),
        ...risks.map((r) => _buildRiskTile(r)),
      ],
    );
  }

  Widget _buildRiskTile(_RiskItem risk) {
    final riskLevel = risk.value > 80 ? 'SEVERE' : risk.value > 60 ? 'HIGH' : risk.value > 40 ? 'MODERATE' : risk.value > 20 ? 'MILD' : 'MINIMAL';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: risk.color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(risk.icon, color: risk.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  risk.label,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: risk.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk.value.toStringAsFixed(1),
                  style: GoogleFonts.outfit(color: risk.color, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                riskLevel,
                style: GoogleFonts.inter(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: risk.value / 100,
              backgroundColor: Colors.white10,
              color: risk.color,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI EXPLANATION SECTION ───
  Widget _buildAIExplanation(BuildContext context) {
    final topFactor = result.topFactor ?? 'EMOTIONAL';
    final cmhi = result.totalScore;
    
    // Dynamic weight explanation
    String weightExplanation = '';
    if (result.categoryScores.containsKey('Physiological') && (result.categoryScores['Physiological'] ?? 0) > 80) {
      weightExplanation = '⚡ Dynamic Weight Shift: Physiological score (${result.categoryScores['Physiological']?.toStringAsFixed(0)}) exceeded 80-point threshold. Engine increased physiological weight 0.20 → 0.40 to prioritize sleep/somatic recovery.';
    } else if (result.categoryScores.containsKey('Cognitive') && (result.categoryScores['Cognitive'] ?? 0) > 80) {
      weightExplanation = '⚡ Dynamic Weight Shift: Cognitive score (${result.categoryScores['Cognitive']?.toStringAsFixed(0)}) exceeded 80-point threshold. Engine boosted cognitive weight 0.20 → 0.35 to flag rumination.';
    } else if (result.categoryScores.containsKey('Temporal') && (result.categoryScores['Temporal'] ?? 0) > 75) {
      weightExplanation = '⚡ Dynamic Weight Shift: Temporal volatility (${result.categoryScores['Temporal']?.toStringAsFixed(0)}) indicates sudden crash. Weight increased 0.15 → 0.30.';
    } else {
      weightExplanation = '✓ Standard Weights Applied: E=0.25, C=0.20, B=0.20, P=0.20, T=0.15. No acute crisis triggers detected.';
    }
    
    // Find the highest risk
    final riskMap = {
      'Anxiety': result.anxietyRisk ?? 0,
      'Depression': result.depressionRisk ?? 0,
      'Burnout': result.burnoutRisk ?? 0,
      'Crisis': result.crisisRisk ?? 0,
    };
    final highestRisk = riskMap.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9147FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9147FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF9147FF), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Scoring Analysis',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // CMHI Summary
          _buildAnalysisRow(
            'CMHI',
            'Composite Mental Health Index = $cmhi (${result.severityLevel})',
            const Color(0xFF9147FF),
          ),
          const SizedBox(height: 12),
          
          // Top Factor
          _buildAnalysisRow(
            'TOP FACTOR',
            '${topFactor[0].toUpperCase()}${topFactor.substring(1).toLowerCase()} — identified as the primary driver of your current distress.',
            const Color(0xFFFF6E40),
          ),
          const SizedBox(height: 12),
          
          // Highest Risk
          _buildAnalysisRow(
            'HIGHEST RISK',
            '${highestRisk.key} Risk at ${highestRisk.value.toStringAsFixed(1)} — ${highestRisk.value > 60 ? 'above clinical threshold, intervention recommended.' : 'within manageable range.'}',
            highestRisk.value > 60 ? const Color(0xFFFF1744) : const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          
          // Dynamic Weighting Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              weightExplanation,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarSection(BuildContext context) {
    final categories = result.categoryScores.keys.toList();
    if (categories.length < 3) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dimensional Matrix',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _buildLegendItem('You', const Color(0xFF9147FF)),
                const SizedBox(width: 12),
                _buildLegendItem('Baseline', Colors.white38),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        AspectRatio(
          aspectRatio: 1.3,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: Colors.white.withOpacity(0.05),
                  borderColor: Colors.white24,
                  entryRadius: 0,
                  dataEntries: categories.map((_) => const RadarEntry(value: 50)).toList(),
                ),
                RadarDataSet(
                  fillColor: const Color(0xFF5E4B8B).withOpacity(0.3),
                  borderColor: const Color(0xFF9147FF),
                  entryRadius: 4,
                  dataEntries: categories.map((cat) {
                    return RadarEntry(value: result.categoryScores[cat] ?? 0);
                  }).toList(),
                ),
              ],
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              getTitle: (index, angle) {
                if (index >= 0 && index < categories.length) {
                  return RadarChartTitle(
                    text: categories[index].toUpperCase(),
                    angle: angle,
                  );
                }
                return const RadarChartTitle(text: '');
              },
              titleTextStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
              gridBorderData: const BorderSide(color: Colors.white10, width: 1),
              tickBorderData: const BorderSide(color: Colors.white10, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF9147FF)),
              const SizedBox(width: 12),
              Text(
                'Clinical Narrative',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.insight ?? 'Your data patterns suggest a state of moderate cognitive fatigue. We recommend short mindfulness intervals every 4 hours.',
            style: GoogleFonts.inter(height: 1.6, color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E4B8B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ios_share_rounded, size: 20),
          label: const Text('Share Clinical Report'),
          style: TextButton.styleFrom(foregroundColor: Colors.white38),
        ),
      ],
    );
  }

  Color _getSeverityColor(String level) {
    switch (level.toLowerCase()) {
      case 'minimal': return const Color(0xFF4CAF50);
      case 'mild': return const Color(0xFF8BC34A);
      case 'moderate': return const Color(0xFFFFC107);
      case 'high': return const Color(0xFFFF9800);
      case 'severe': return const Color(0xFFF44336);
      case 'emergency': return const Color(0xFFD50000);
      default: return const Color(0xFF9147FF);
    }
  }
}

class _RiskItem {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  
  _RiskItem(this.label, this.value, this.icon, this.color);
}
