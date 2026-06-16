import 'package:flutter/material.dart';

enum RiskCategory {
  minimal,
  mild,
  moderate,
  high,
  severe,
  emergency;

  static RiskCategory fromString(String category) {
    switch (category.toUpperCase()) {
      case 'MINIMAL': return RiskCategory.minimal;
      case 'MILD': return RiskCategory.mild;
      case 'MODERATE': return RiskCategory.moderate;
      case 'HIGH': return RiskCategory.high;
      case 'SEVERE': return RiskCategory.severe;
      case 'EMERGENCY': return RiskCategory.emergency;
      default: return RiskCategory.minimal;
    }
  }

  String get description {
    switch (this) {
      case RiskCategory.minimal: return 'You are in an optimal state of wellness. Continue your current self-care routines.';
      case RiskCategory.mild: return 'Minor fluctuations detected. Focus on mindfulness and stress management.';
      case RiskCategory.moderate: return 'Significant distress patterns. Consider reaching out to your support network or a professional.';
      case RiskCategory.high: return 'High clinical risk detected. We recommend scheduled check-ins and clinical consultation.';
      case RiskCategory.severe: return 'Severe distress requiring immediate attention. Please use our emergency resources if needed.';
      case RiskCategory.emergency: return 'Crisis state detected. Please contact professional help or use the emergency dialer immediately.';
    }
  }

  String get rangeText {
    switch (this) {
      case RiskCategory.minimal: return '0-20';
      case RiskCategory.mild: return '21-40';
      case RiskCategory.moderate: return '41-60';
      case RiskCategory.high: return '61-80';
      case RiskCategory.severe: return '81-100';
      case RiskCategory.emergency: return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case RiskCategory.minimal: return const Color(0xFF4CAF50);
      case RiskCategory.mild: return const Color(0xFF8BC34A);
      case RiskCategory.moderate: return const Color(0xFFFFC107);
      case RiskCategory.high: return const Color(0xFFFF9800);
      case RiskCategory.severe: return const Color(0xFFFF5722);
      case RiskCategory.emergency: return const Color(0xFFE91E63);
    }
  }

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class CMHIDimensionInfo {
  final String label;
  final String description;
  final IconData icon;

  const CMHIDimensionInfo({
    required this.label,
    required this.description,
    required this.icon,
  });

  static const List<CMHIDimensionInfo> all = [
    CMHIDimensionInfo(
      label: 'Emotional',
      description: 'Measures your raw mood stability, affect, and presence of emotional distress markers.',
      icon: Icons.favorite_rounded,
    ),
    CMHIDimensionInfo(
      label: 'Cognitive',
      description: 'Reflects your clarity of thought, concentration levels, and frequency of rumination.',
      icon: Icons.psychology_rounded,
    ),
    CMHIDimensionInfo(
      label: 'Behavioral',
      description: 'Tracks your social interaction patterns, habit adherence, and physical activity levels.',
      icon: Icons.groups_rounded,
    ),
    CMHIDimensionInfo(
      label: 'Physiological',
      description: 'Monitors your sleep quality, body tension, and somatic expressions of stress.',
      icon: Icons.bedtime_rounded,
    ),
    CMHIDimensionInfo(
      label: 'Temporal',
      description: 'Analyzes the pace of internal changes and identifies sudden mood crashes or instability.',
      icon: Icons.speed_rounded,
    ),
  ];
}

class DimensionalProfile {
  final double emotional;
  final double cognitive;
  final double behavioral;
  final double physiological;
  final double temporal;

  const DimensionalProfile({
    required this.emotional,
    required this.cognitive,
    required this.behavioral,
    required this.physiological,
    required this.temporal,
  });

  factory DimensionalProfile.fromJson(Map<String, dynamic> json) {
    return DimensionalProfile(
      emotional: (json['emotional'] as num?)?.toDouble() ?? 0.0,
      cognitive: (json['cognitive'] as num?)?.toDouble() ?? 0.0,
      behavioral: (json['behavioral'] as num?)?.toDouble() ?? 0.0,
      physiological: (json['physiological'] as num?)?.toDouble() ?? 0.0,
      temporal: (json['temporal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CMHIScore {
  final String id;
  final double cmhi;
  final RiskCategory riskCategory;
  final DateTime calculatedAt;
  final DimensionalProfile dimensions;
  final ScoreExplanation? explanation;

  const CMHIScore({
    required this.id,
    required this.cmhi,
    required this.riskCategory,
    required this.calculatedAt,
    required this.dimensions,
    this.explanation,
  });

  factory CMHIScore.fromJson(Map<String, dynamic> json) {
    return CMHIScore(
      id: json['id'] as String,
      cmhi: (json['cmhi'] as num?)?.toDouble() ?? 0.0,
      riskCategory: RiskCategory.fromString(json['riskCategory'] as String? ?? 'MINIMAL'),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      dimensions: DimensionalProfile(
        emotional: (json['emotional'] as num?)?.toDouble() ?? 0.0,
        cognitive: (json['cognitive'] as num?)?.toDouble() ?? 0.0,
        behavioral: (json['behavioral'] as num?)?.toDouble() ?? 0.0,
        physiological: (json['physiological'] as num?)?.toDouble() ?? 0.0,
        temporal: (json['temporal'] as num?)?.toDouble() ?? 0.0,
      ),
      explanation: json['explanation'] != null 
          ? ScoreExplanation.fromJson(json['explanation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ScoreExplanation {
  final String insightText;
  final String? topFactor;
  final String? improvementText;
  final List<String> recommendations;

  const ScoreExplanation({
    required this.insightText,
    this.topFactor,
    this.improvementText,
    this.recommendations = const [],
  });

  factory ScoreExplanation.fromJson(Map<String, dynamic> json) {
    return ScoreExplanation(
      insightText: json['insightText'] as String? ?? '',
      topFactor: json['topFactor'] as String?,
      improvementText: json['improvementText'] as String?,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : [],
    );
  }
}
