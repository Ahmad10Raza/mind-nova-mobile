import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/surfaces/app_surfaces.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../providers/ai_prediction_provider.dart';
import '../../data/ai_prediction_service.dart';
import 'prediction_input_screen.dart';

class AiPredictionHubScreen extends ConsumerStatefulWidget {
  const AiPredictionHubScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiPredictionHubScreen> createState() => _AiPredictionHubScreenState();
}

class _AiPredictionHubScreenState extends ConsumerState<AiPredictionHubScreen> {
  @override
  void initState() {
    super.initState();
    // Proactively wake up the AI service when user enters the hub
    Future.microtask(() => ref.read(aiPredictionServiceProvider).wakeUp());
  }

  final List<Map<String, dynamic>> predictionModels = const [
    {
      'type': 'stress',
      'title': 'Acute Stress Profiler',
      'subtitle': 'Measure your current psychological stress load',
      'icon': Icons.flash_on,
      'color': Colors.amber,
    },
    {
      'type': 'burnout',
      'title': 'Burnout Detection',
      'subtitle': 'Analyze workplace exhaustion and engagement',
      'icon': Icons.work_off,
      'color': Colors.deepOrange,
    },
    {
      'type': 'anxiety',
      'title': 'Anxiety Screener',
      'subtitle': 'Detect early warning signs of GAD',
      'icon': Icons.monitor_heart,
      'color': Colors.blueAccent,
    },
    {
      'type': 'depression',
      'title': 'Depression Screener',
      'subtitle': 'Identify behavioral patterns of low mood',
      'icon': Icons.cloud_queue,
      'color': Colors.indigo,
    },
    {
      'type': 'deterioration',
      'title': '7-Day Escalation Forecast',
      'subtitle': 'Predict future trajectory based on history',
      'icon': Icons.timeline,
      'color': Colors.redAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text('Nova AI Hub', style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Predictive Engine',
              style: AppTypography.heroXL.copyWith(fontSize: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Our proprietary ML models analyze your behavioral data to forecast risks before they escalate.',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: predictionModels.length,
                itemBuilder: (context, index) {
                  final model = predictionModels[index];
                  return GestureDetector(
                    onTap: () {
                      // Reset the state for a fresh prediction session
                      ref.read(aiPredictionProvider.notifier).reset();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PredictionInputScreen(
                            modelType: model['type'],
                            title: model['title'],
                            themeColor: model['color'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171B28).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: model['color'].withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: model['color'].withOpacity(0.3)),
                              ),
                              child: Icon(model['icon'], color: model['color'], size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model['title'],
                                    style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    model['subtitle'],
                                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
