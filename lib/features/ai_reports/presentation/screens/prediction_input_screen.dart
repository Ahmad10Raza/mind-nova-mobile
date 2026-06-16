import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/colors/app_colors.dart';
import '../../../../core/design/surfaces/app_surfaces.dart';
import '../../../../core/design/typography/app_typography.dart';
import '../../providers/ai_prediction_provider.dart';
import 'prediction_result_screen.dart';

class PredictionInputScreen extends ConsumerStatefulWidget {
  final String modelType;
  final String title;
  final Color themeColor;

  const PredictionInputScreen({
    Key? key,
    required this.modelType,
    required this.title,
    required this.themeColor,
  }) : super(key: key);

  @override
  ConsumerState<PredictionInputScreen> createState() => _PredictionInputScreenState();
}

class _PredictionInputScreenState extends ConsumerState<PredictionInputScreen> {
  final Map<String, double> _formData = {};
  
  String _getValueDescription(String key, double value) {
    if (key == 'sleep_hours') {
      if (value < 5) return 'Severe Deprivation';
      if (value < 7) return 'Below Average';
      if (value <= 9) return 'Healthy Range';
      return 'Oversleeping';
    }
    if (key == 'work_hours') {
      if (value < 6) return 'Part-time / Light';
      if (value <= 8) return 'Standard Full-time';
      if (value <= 10) return 'Heavy Workload';
      return 'Extreme Overwork';
    }
    if (key == 'experience_years') {
      if (value < 2) return 'Entry Level';
      if (value < 5) return 'Mid Level';
      if (value < 10) return 'Senior Level';
      return 'Expert / Veteran';
    }
    if (key == 'break_frequency') {
      if (value < 2) return 'Rare / None';
      if (value <= 4) return 'Occasional';
      if (value <= 6) return 'Frequent';
      return 'Very Frequent';
    }
    if (key == 'screen_time') {
      if (value < 2) return 'Minimal';
      if (value <= 4) return 'Moderate';
      if (value <= 8) return 'High';
      return 'Excessive';
    }
    if (key == 'academic_performance') {
      if (value < 2.0) return 'Failing / Poor';
      if (value < 3.0) return 'Average';
      if (value < 3.5) return 'Good';
      return 'Excellent';
    }
    if (key == 'exercise_freq') {
      if (value < 1) return 'Sedentary';
      if (value <= 2) return 'Light Activity';
      if (value <= 4) return 'Active';
      return 'Highly Active';
    }
    
    // For 1-10 scales where High is GOOD (Mood, Satisfaction, Support, Activity)
    if ((key.contains('mood') && !key.contains('volatility')) || 
        key.contains('satisfaction') || 
        key.contains('support') || 
        key.contains('activity') || 
        key.contains('trend')) {
      if (value <= 3) return 'Very Poor / Low';
      if (value <= 5) return 'Below Average';
      if (value <= 7) return 'Good / Moderate';
      return 'Excellent / High';
    }
    
    // For scales where High is BAD (Stress, Workload, Swings, Scores)
    if (key.contains('stress') || key.contains('workload') || key.contains('volatility') || key.contains('escalation') || key.contains('score')) {
      if (value <= 3) return 'Minimal / Low';
      if (value <= 5) return 'Manageable';
      if (value <= 7) return 'High / Elevated';
      return 'Severe / Extreme';
    }
    
    return '';
  }
  // ... (rest of _getFields omitted for brevity in replacement, but I will include it as this is replace_file_content)

  // Define required fields based on the model type
  List<Map<String, dynamic>> _getFields() {
    switch (widget.modelType) {
      case 'stress':
        return [
          {'key': 'mood_current', 'label': 'Current Mood (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'sleep_hours', 'label': 'Sleep Hours', 'min': 0.0, 'max': 14.0, 'default': 7.0},
          {'key': 'workload_level', 'label': 'Perceived Workload (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'work_hours', 'label': 'Hours Worked Today', 'min': 0.0, 'max': 16.0, 'default': 8.0},
          {'key': 'experience_years', 'label': 'Years of Experience', 'min': 0.0, 'max': 40.0, 'default': 5.0},
          {'key': 'job_satisfaction', 'label': 'Job Satisfaction (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'academic_stress', 'label': 'Academic/Life Stress (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'financial_stress', 'label': 'Financial Stress (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'social_support', 'label': 'Social Support Level (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
        ];
      case 'burnout':
        return [
          {'key': 'work_hours', 'label': 'Average Daily Work Hours', 'min': 4.0, 'max': 16.0, 'default': 8.0},
          {'key': 'sleep_hours', 'label': 'Average Sleep Hours', 'min': 2.0, 'max': 12.0, 'default': 7.0},
          {'key': 'stress_level', 'label': 'General Stress Level (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'experience_years', 'label': 'Years of Experience', 'min': 0.0, 'max': 40.0, 'default': 5.0},
          {'key': 'job_satisfaction', 'label': 'Job Satisfaction (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'social_support', 'label': 'Social Support Level (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'break_frequency', 'label': 'Breaks per day', 'min': 0.0, 'max': 10.0, 'default': 3.0},
          {'key': 'screen_time', 'label': 'Screen Time outside work (hrs)', 'min': 0.0, 'max': 12.0, 'default': 4.0},
        ];
      case 'deterioration':
        return [
          {'key': 'sleep_trend', 'label': 'Sleep Trend (1=Dropping, 10=Improving)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'mood_volatility', 'label': 'Mood Swings (1=Stable, 10=Erratic)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'workload_escalation', 'label': 'Workload Increase (1=None, 10=Extreme)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
        ];
      default:
        return [
          {'key': 'gad2_score', 'label': 'Clinical Anxiety Marker (GAD-2) (0-10)', 'min': 0.0, 'max': 10.0, 'default': 2.0},
          {'key': 'phq2_score', 'label': 'Clinical Depression Marker (PHQ-2) (0-10)', 'min': 0.0, 'max': 10.0, 'default': 2.0},
          {'key': 'sleep_hours', 'label': 'Sleep Hours', 'min': 0.0, 'max': 12.0, 'default': 7.0},
          {'key': 'social_activity', 'label': 'Social Activity Level (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'social_support', 'label': 'Social Support Level (1-10)', 'min': 1.0, 'max': 10.0, 'default': 7.0},
          {'key': 'academic_performance', 'label': 'Academic Performance (GPA)', 'min': 1.0, 'max': 4.0, 'default': 3.0},
          {'key': 'financial_stress', 'label': 'Financial Stress (1-10)', 'min': 1.0, 'max': 10.0, 'default': 5.0},
          {'key': 'exercise_freq', 'label': 'Exercise Days per Week', 'min': 0.0, 'max': 7.0, 'default': 3.0},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    for (var field in _getFields()) {
      _formData[field['key']] = field['default'];
    }
  }

  void _submitForm() async {
    final notifier = ref.read(aiPredictionProvider.notifier);
    
    Map<String, dynamic> payload = {};
    if (widget.modelType == 'deterioration') {
      double sT = _formData['sleep_trend']!;
      double mV = _formData['mood_volatility']!;
      double wE = _formData['workload_escalation']!;
      List<Map<String, dynamic>> history = [];
      for(int i=0; i<7; i++) {
        history.add({
          "day": i,
          "mood": 8.0 - (mV/2.0)*(i/6.0),
          "sleep": 8.0 - (sT < 5 ? 2.0 : 0.0)*(i/6.0), 
          "workload": 5.0 + (wE/2.0)*(i/6.0)
        });
      }
      payload = {"history": history};
    } else {
      payload = Map<String, dynamic>.from(_formData);
    }

    await notifier.predict(widget.modelType, payload);
    
    // Refresh state after await
    final state = ref.read(aiPredictionProvider);
    
    if (state.error == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(
            title: widget.title,
            themeColor: widget.themeColor,
            result: state.lastResult!,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _getFields();
    final state = ref.watch(aiPredictionProvider);

    return Scaffold(
      backgroundColor: AppSurfaces.primary,
      appBar: AppBar(
        title: Text(widget.title, style: AppTypography.headingLarge.copyWith(color: widget.themeColor)),
        backgroundColor: widget.themeColor.withOpacity(0.1),
        foregroundColor: widget.themeColor,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.themeColor),
      ),
      body: state.isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: widget.themeColor),
                const SizedBox(height: 16),
                Text("Running ML Inference Pipeline...", style: AppTypography.body.copyWith(color: AppColors.textMuted))
              ],
            ),
          )
        : SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Provide Contextual Data",
              style: AppTypography.heroXL.copyWith(fontSize: 22, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              "Adjust the sliders below to provide the necessary input vector for the ${widget.title} model.",
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            ...fields.map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          field['label'],
                          style: AppTypography.headingMedium.copyWith(fontSize: 16, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_formData[field['key']]!.toStringAsFixed(1)}',
                        style: AppTypography.headingLarge.copyWith(color: widget.themeColor, fontSize: 16),
                      ),
                    ],
                  ),
                  Slider(
                    value: _formData[field['key']]!,
                    min: field['min'],
                    max: field['max'],
                    divisions: 20,
                    activeColor: widget.themeColor,
                    onChanged: (val) {
                      setState(() {
                        _formData[field['key']] = val;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${field['min'].toInt()}', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 12)),
                        Expanded(
                          child: Text(
                            _getValueDescription(field['key'], _formData[field['key']]!),
                            style: AppTypography.headingSmall.copyWith(color: widget.themeColor, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('${field['max'].toInt()}', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submitForm,
                child: Text('Execute Prediction', style: AppTypography.headingLarge.copyWith(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
