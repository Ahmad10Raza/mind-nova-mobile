enum FocusMode {
  calmStart,
  deepWork,
  studySprint,
  flowState,
  rescueMode,
  examMode,
  custom,
}

extension FocusModeExtension on FocusMode {
  String get displayName {
    switch (this) {
      case FocusMode.calmStart: return 'Calm Start';
      case FocusMode.deepWork: return 'Deep Work';
      case FocusMode.studySprint: return 'Study Sprint';
      case FocusMode.flowState: return 'Flow State';
      case FocusMode.rescueMode: return 'Rescue Mode';
      case FocusMode.examMode: return 'Exam Mode';
      case FocusMode.custom: return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case FocusMode.calmStart: return '1 min breathing + Focus';
      case FocusMode.deepWork: return 'Uninterrupted deep work';
      case FocusMode.studySprint: return '25 min Focus + 5 min break';
      case FocusMode.flowState: return 'Immersive flow with ambient audio';
      case FocusMode.rescueMode: return 'Beat procrastination with tiny steps';
      case FocusMode.examMode: return '50 min Focus + 10 min break';
      case FocusMode.custom: return 'Your own focus rhythm';
    }
  }

  String toJson() {
    switch (this) {
      case FocusMode.calmStart: return 'CALM_START';
      case FocusMode.deepWork: return 'DEEP_WORK';
      case FocusMode.studySprint: return 'STUDY_SPRINT';
      case FocusMode.flowState: return 'FLOW_STATE';
      case FocusMode.rescueMode: return 'RESCUE_MODE';
      case FocusMode.examMode: return 'EXAM_MODE';
      case FocusMode.custom: return 'CUSTOM';
    }
  }
  
  static FocusMode fromJson(String json) {
    switch (json) {
      case 'CALM_START': return FocusMode.calmStart;
      case 'DEEP_WORK': return FocusMode.deepWork;
      case 'STUDY_SPRINT': return FocusMode.studySprint;
      case 'FLOW_STATE': return FocusMode.flowState;
      case 'RESCUE_MODE': return FocusMode.rescueMode;
      case 'EXAM_MODE': return FocusMode.examMode;
      case 'CUSTOM': return FocusMode.custom;
      default: return FocusMode.deepWork;
    }
  }
}

class FocusSession {
  final String id;
  final FocusMode mode;
  final int durationMinutes;
  final int actualDurationSec;
  final bool completed;
  final double completedPercent;
  final int interruptions;
  final int deviceInterrupted;
  final String? goal;
  final String? moodBefore;
  final String? moodAfter;
  final String? selectedAudio;
  final DateTime startedAt;
  final DateTime? endedAt;

  FocusSession({
    required this.id,
    required this.mode,
    required this.durationMinutes,
    this.actualDurationSec = 0,
    this.completed = false,
    this.completedPercent = 0.0,
    this.interruptions = 0,
    this.deviceInterrupted = 0,
    this.goal,
    this.moodBefore,
    this.moodAfter,
    this.selectedAudio,
    required this.startedAt,
    this.endedAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      mode: FocusModeExtension.fromJson(json['mode']),
      durationMinutes: json['durationMinutes'],
      actualDurationSec: json['actualDurationSec'] ?? 0,
      completed: json['completed'] ?? false,
      completedPercent: (json['completedPercent'] ?? 0.0).toDouble(),
      interruptions: json['interruptions'] ?? 0,
      deviceInterrupted: json['deviceInterrupted'] ?? 0,
      goal: json['goal'],
      moodBefore: json['moodBefore'],
      moodAfter: json['moodAfter'],
      selectedAudio: json['selectedAudio'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actualDurationSec': actualDurationSec,
      'completedPercent': completedPercent,
      'interruptions': interruptions,
      'deviceInterrupted': deviceInterrupted,
      'moodAfter': moodAfter,
    };
  }
}

class FocusStats {
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final int weeklyMinutes;
  final String humanMinutes;

  FocusStats({
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyMinutes,
    required this.humanMinutes,
  });

  factory FocusStats.fromJson(Map<String, dynamic> json) {
    return FocusStats(
      totalMinutes: json['totalMinutes'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      weeklyMinutes: json['weeklyMinutes'] ?? 0,
      humanMinutes: json['humanMinutes'] ?? 'Keep going!',
    );
  }
}
