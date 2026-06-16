enum GroundingExerciseType {
  sensory54321,
  panicReset,
  touchHold,
  bodyScan,
  colorBreathing,
  safePlace,
}

extension GroundingExerciseTypeExt on GroundingExerciseType {
  String get id {
    switch (this) {
      case GroundingExerciseType.sensory54321: return 'SENSORY_54321';
      case GroundingExerciseType.panicReset: return 'PANIC_RESET';
      case GroundingExerciseType.touchHold: return 'TOUCH_HOLD';
      case GroundingExerciseType.bodyScan: return 'BODY_SCAN';
      case GroundingExerciseType.colorBreathing: return 'COLOR_BREATHING';
      case GroundingExerciseType.safePlace: return 'SAFE_PLACE';
    }
  }

  String get label {
    switch (this) {
      case GroundingExerciseType.sensory54321: return '5-4-3-2-1 Sensory';
      case GroundingExerciseType.panicReset: return 'Panic Reset';
      case GroundingExerciseType.touchHold: return 'Touch & Hold';
      case GroundingExerciseType.bodyScan: return 'Body Scan';
      case GroundingExerciseType.colorBreathing: return 'Color Breathing';
      case GroundingExerciseType.safePlace: return 'Safe Place';
    }
  }

  static GroundingExerciseType fromString(String value) {
    switch (value) {
      case 'PANIC_RESET': return GroundingExerciseType.panicReset;
      case 'TOUCH_HOLD': return GroundingExerciseType.touchHold;
      case 'BODY_SCAN': return GroundingExerciseType.bodyScan;
      case 'COLOR_BREATHING': return GroundingExerciseType.colorBreathing;
      case 'SAFE_PLACE': return GroundingExerciseType.safePlace;
      default: return GroundingExerciseType.sensory54321;
    }
  }
}

enum SafePlaceEnvironment {
  beach,
  forest,
  rainRoom,
  mountain,
  fireplace,
  nightSky,
  garden,
  cozyBedroom,
}

extension SafePlaceEnvironmentExt on SafePlaceEnvironment {
  String get id {
    switch (this) {
      case SafePlaceEnvironment.beach: return 'BEACH';
      case SafePlaceEnvironment.forest: return 'FOREST';
      case SafePlaceEnvironment.rainRoom: return 'RAIN_ROOM';
      case SafePlaceEnvironment.mountain: return 'MOUNTAIN';
      case SafePlaceEnvironment.fireplace: return 'FIREPLACE';
      case SafePlaceEnvironment.nightSky: return 'NIGHT_SKY';
      case SafePlaceEnvironment.garden: return 'GARDEN';
      case SafePlaceEnvironment.cozyBedroom: return 'COZY_BEDROOM';
    }
  }

  String get label {
    switch (this) {
      case SafePlaceEnvironment.beach: return 'Beach';
      case SafePlaceEnvironment.forest: return 'Forest';
      case SafePlaceEnvironment.rainRoom: return 'Rainy Room';
      case SafePlaceEnvironment.mountain: return 'Mountain';
      case SafePlaceEnvironment.fireplace: return 'Fireplace';
      case SafePlaceEnvironment.nightSky: return 'Night Sky';
      case SafePlaceEnvironment.garden: return 'Garden';
      case SafePlaceEnvironment.cozyBedroom: return 'Cozy Bedroom';
    }
  }

  String get emoji {
    switch (this) {
      case SafePlaceEnvironment.beach: return '🏖️';
      case SafePlaceEnvironment.forest: return '🌲';
      case SafePlaceEnvironment.rainRoom: return '🌧️';
      case SafePlaceEnvironment.mountain: return '⛰️';
      case SafePlaceEnvironment.fireplace: return '🔥';
      case SafePlaceEnvironment.nightSky: return '🌌';
      case SafePlaceEnvironment.garden: return '🌸';
      case SafePlaceEnvironment.cozyBedroom: return '🛏️';
    }
  }
}

class GroundingSession {
  final String id;
  final String userId;
  final GroundingExerciseType exerciseType;
  final SafePlaceEnvironment? environment;
  final int durationSecs;
  final int? calmBefore;
  final int? calmAfter;
  final bool? wouldRepeat;
  final bool completedFull;
  final DateTime completedAt;

  GroundingSession({
    required this.id,
    required this.userId,
    required this.exerciseType,
    this.environment,
    required this.durationSecs,
    this.calmBefore,
    this.calmAfter,
    this.wouldRepeat,
    this.completedFull = true,
    required this.completedAt,
  });

  factory GroundingSession.fromJson(Map<String, dynamic> json) {
    return GroundingSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      exerciseType: GroundingExerciseTypeExt.fromString(json['exerciseType'] ?? ''),
      durationSecs: json['durationSecs'] ?? 0,
      calmBefore: json['calmBefore'],
      calmAfter: json['calmAfter'],
      wouldRepeat: json['wouldRepeat'],
      completedFull: json['completedFull'] ?? true,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : DateTime.now(),
    );
  }
}

class GroundingDashboard {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalMinutes;
  final List<String> badges;
  final String? mostUsedExercise;
  final String? mostEffectiveExercise;
  final double averageCalmRating;
  final String? favoriteEnvironment;
  final List<GroundingSession> recentSessions;

  GroundingDashboard({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.badges = const [],
    this.mostUsedExercise,
    this.mostEffectiveExercise,
    this.averageCalmRating = 0,
    this.favoriteEnvironment,
    this.recentSessions = const [],
  });

  factory GroundingDashboard.fromJson(Map<String, dynamic> json) {
    return GroundingDashboard(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      mostUsedExercise: json['mostUsedExercise'],
      mostEffectiveExercise: json['mostEffectiveExercise'],
      averageCalmRating: (json['averageCalmRating'] ?? 0).toDouble(),
      favoriteEnvironment: json['favoriteEnvironment'],
      recentSessions: (json['recentSessions'] as List? ?? [])
          .map((e) => GroundingSession.fromJson(e))
          .toList(),
    );
  }
}

class GroundingAnalyticsModel {
  final String? mostUsedExercise;
  final String? mostEffectiveExercise;
  final double averageCalmRating;
  final int totalMinutes;
  final int weeklySessions;
  final String? favoriteEnvironment;
  final List<String> insights;

  GroundingAnalyticsModel({
    this.mostUsedExercise,
    this.mostEffectiveExercise,
    this.averageCalmRating = 0,
    this.totalMinutes = 0,
    this.weeklySessions = 0,
    this.favoriteEnvironment,
    this.insights = const [],
  });

  factory GroundingAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return GroundingAnalyticsModel(
      mostUsedExercise: json['mostUsedExercise'],
      mostEffectiveExercise: json['mostEffectiveExercise'],
      averageCalmRating: (json['averageCalmRating'] ?? 0).toDouble(),
      totalMinutes: json['totalMinutes'] ?? 0,
      weeklySessions: json['weeklySessions'] ?? 0,
      favoriteEnvironment: json['favoriteEnvironment'],
      insights: List<String>.from(json['insights'] ?? []),
    );
  }
}
