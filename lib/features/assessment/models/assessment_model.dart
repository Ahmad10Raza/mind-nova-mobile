class Questionnaire {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final List<Question> questions;

  Questionnaire({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    required this.questions,
  });

  Questionnaire copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    List<Question>? questions,
  }) {
    return Questionnaire(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
    );
  }

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String text;
  final String category;
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    required this.category,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      category: json['category'],
      options: (json['options'] as List? ?? [])
          .map((o) => Option.fromJson(o))
          .toList(),
    );
  }
}

class Option {
  final String text;
  final int score;
  final String? branchTo;

  Option({
    required this.text,
    required this.score,
    this.branchTo,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'],
      score: json['score'],
      branchTo: json['branchTo'],
    );
  }
}

class AssessmentResult {
  final String id;
  final int totalScore;
  final String severityLevel;
  final String? insight;
  final Map<String, dynamic>? metadata; // Category scores
  final Map<String, double> categoryScores; // Mapped percentages for Radar Chart
  final DateTime createdAt;
  
  // Phase 5: Multi-Dimensional Risk Sub-Indices
  final double? anxietyRisk;
  final double? depressionRisk;
  final double? burnoutRisk;
  final double? crisisRisk;
  final String? topFactor;
  final String? assessmentTitle;
  final String? assessmentSlug;

  AssessmentResult({
    required this.id,
    required this.totalScore,
    required this.severityLevel,
    this.insight,
    this.metadata,
    required this.categoryScores,
    required this.createdAt,
    this.anxietyRisk,
    this.depressionRisk,
    this.burnoutRisk,
    this.crisisRisk,
    this.topFactor,
    this.assessmentTitle,
    this.assessmentSlug,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final insight = json['insight'] as String? ?? 
                    json['explanation']?['insightText'] as String? ??
                    metadata?['ai_insight'] as String?;
    
    // Extract category-based scores for Radar Chart
    final mappedScores = <String, double>{};
    
    // Check if this is a Phase 5 MultiDimensionalScore (has emotional, cognitive, etc.)
    if (json.containsKey('emotional')) {
      mappedScores['Emotional'] = (json['emotional'] as num).toDouble();
      mappedScores['Cognitive'] = (json['cognitive'] as num).toDouble();
      mappedScores['Behavioral'] = (json['behavioral'] as num).toDouble();
      mappedScores['Physiological'] = (json['physiological'] as num).toDouble();
      mappedScores['Temporal'] = (json['temporal'] as num).toDouble();
    } 
    // Fallback to legacy metadata mapping
    else if (metadata != null) {
      metadata.forEach((key, value) {
        if (value is Map && value.containsKey('total') && value.containsKey('max')) {
          final total = (value['total'] as num).toDouble();
          final max = (value['max'] as num).toDouble();
          mappedScores[key] = (total / max) * 100;
        }
      });
    }

    return AssessmentResult(
      id: json['id'],
      totalScore: (json['cmhi'] as num? ?? json['totalScore'] as num).toInt(),
      severityLevel: json['riskCategory'] ?? json['severityLevel'] ?? 'UNKNOWN',
      insight: insight,
      metadata: metadata,
      categoryScores: mappedScores,
      createdAt: DateTime.parse(json['calculatedAt'] ?? json['createdAt']),
      anxietyRisk: (json['anxietyRisk'] as num?)?.toDouble(),
      depressionRisk: (json['depressionRisk'] as num?)?.toDouble(),
      burnoutRisk: (json['burnoutRisk'] as num?)?.toDouble(),
      crisisRisk: (json['crisisRisk'] as num?)?.toDouble(),
      topFactor: json['explanation']?['topFactor'],
      assessmentTitle: json['assessment']?['title'],
      assessmentSlug: json['assessment']?['slug'],
    );
  }
}

class AssessmentSession {
  final String userId;
  final String assessmentId;
  final String slug;
  final Map<String, int> answers;
  final int currentIndex;
  final List<String> shuffledQuestionIds;
  final String depth;
  final DateTime updatedAt;

  AssessmentSession({
    required this.userId,
    required this.assessmentId,
    required this.slug,
    required this.answers,
    required this.currentIndex,
    required this.shuffledQuestionIds,
    required this.depth,
    required this.updatedAt,
  });

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      userId: json['userId'],
      assessmentId: json['assessmentId'],
      slug: json['slug'],
      answers: Map<String, int>.from(json['answers'] ?? {}),
      currentIndex: json['currentIndex'] ?? 0,
      shuffledQuestionIds: List<String>.from(json['shuffledQuestionIds'] ?? []),
      depth: json['depth'] ?? 'standard',
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
