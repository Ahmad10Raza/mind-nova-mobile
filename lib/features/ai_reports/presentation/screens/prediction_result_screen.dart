import 'package:flutter/material.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/surfaces/app_surfaces.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../../../shared/widgets/ai_insight_card.dart';

class PredictionResultScreen extends StatelessWidget {
  final String title;
  final Color themeColor;
  final Map<String, dynamic> result;

  const PredictionResultScreen({
    Key? key,
    required this.title,
    required this.themeColor,
    required this.result,
  }) : super(key: key);

  Color _getRiskColor(String riskString) {
    if (riskString == 'SEVERE' || riskString == 'CRITICAL' || riskString == 'RED') return Colors.red;
    if (riskString == 'HIGH' || riskString == 'ORANGE') return Colors.orange;
    if (riskString == 'MODERATE' || riskString == 'YELLOW') return Colors.yellow.shade700;
    if (riskString == 'MILD') return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if prediction was successful
    final bool success = result['success'] ?? false;
    
    // Fallback/Error state
    if (!success) {
      return Scaffold(
        backgroundColor: AppSurfaces.primary,
        appBar: AppBar(
          title: Text('Inference Results', style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 80, color: AppColors.textDisabled),
                const SizedBox(height: 24),
                Text(
                  result['title'] ?? 'Service Unavailable',
                  style: AppTypography.headingLarge.copyWith(fontSize: 24, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  result['summary'] ?? result['message'] ?? 'Unable to connect to the prediction engine.',
                  style: AppTypography.body.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again Later'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    // Success State - Map Phase F Contract
    final riskLevel = result['riskLevel'] ?? 'MINIMAL';
    final riskColor = _getRiskColor(riskLevel);
    final score = (result['score'] as num?)?.toInt() ?? 0;
    final confidence = result['confidence']?.toString() ?? 'Unknown';
    final completeness = (result['inputCompleteness'] as num?)?.toInt() ?? 0;
    final aiAvailable = result['aiAvailable'] ?? false;
    
    final headline = result['title'] ?? '$title Analysis';
    final summary = result['summary'] ?? '';
    final actions = List<String>.from(result['actions'] ?? []);
    final contributors = List<String>.from(result['contributors'] ?? []);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        title: Text('Inference Results', style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.heroXL.copyWith(fontSize: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 32),
            
            // Score Ring
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: score / 100.0,
                      strokeWidth: 20,
                      backgroundColor: riskColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: AppTypography.heroXL.copyWith(
                          fontSize: 56,
                          color: riskColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          riskLevel,
                          style: AppTypography.headingMedium.copyWith(
                            fontSize: 16,
                            color: riskColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Confidence Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildMetricColumn('Confidence', confidence, Icons.psychology_outlined)),
                Expanded(child: _buildMetricColumn('Completeness', '$completeness%', Icons.data_usage)),
                Expanded(child: _buildMetricColumn('AI Mode', aiAvailable ? 'Active' : 'Fallback', aiAvailable ? Icons.auto_awesome : Icons.rule_folder)),
              ],
            ),
            
            const SizedBox(height: 32),

            // AI Insight Card (Direct Rendering)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171B28).withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      headline,
                      style: AppTypography.headingLarge.copyWith(fontSize: 22, color: AppColors.textPrimary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      summary,
                      style: AppTypography.body.copyWith(fontSize: 15, height: 1.5, color: AppColors.textMuted),
                    ),
                  ),
                    const SizedBox(height: 16),
                    
                    // Detailed "Why" Section
                    if (result['why'] != null && result['why'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeColor.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.psychology_outlined, color: themeColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Detailed Insight',
                                    style: AppTypography.headingMedium.copyWith(fontSize: 14, color: themeColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result['why'],
                                style: AppTypography.body.copyWith(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    if (actions.isNotEmpty) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recommended Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 12),
                            ...actions.map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle_outline, color: themeColor, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(a, style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textPrimary))),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ],
                    
                    // Safety Disclaimer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                      ),
                      child: Text(
                        'Nova AI provides guidance, not medical diagnosis. If you are in crisis, please seek immediate professional help.',
                        style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Technical Drivers
            if (contributors.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF171B28).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: themeColor),
                        const SizedBox(width: 8),
                        Text(
                          'Primary Drivers',
                          style: AppTypography.headingLarge.copyWith(fontSize: 18, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...contributors.map((driver) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_right, color: themeColor.withOpacity(0.7), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                driver,
                                style: AppTypography.body.copyWith(fontSize: 15, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 24),
        const SizedBox(height: 8),
        Text(
          value, 
          style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          label, 
          style: AppTypography.caption.copyWith(fontSize: 12, color: AppColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
