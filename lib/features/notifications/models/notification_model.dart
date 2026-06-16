class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String category;
  final String priority;
  final String? deepLink;
  final DateTime scheduledAt;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    this.deepLink,
    required this.scheduledAt,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String? ?? 'MEDIUM',
      deepLink: json['deepLink'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationPreference {
  final bool moodReminders;
  final bool sleepReminders;
  final bool assessmentReminders;
  final bool weeklyReportAlerts;
  final bool streakAlerts;
  final bool therapyReminders;
  final bool meditationReminders;
  final bool journalReminders;
  final bool communityAlerts;
  final bool marketingAlerts;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String timezone;
  final String moodReminderTime;
  final String sleepReminderTime;

  NotificationPreference({
    this.moodReminders = true,
    this.sleepReminders = true,
    this.assessmentReminders = true,
    this.weeklyReportAlerts = true,
    this.streakAlerts = true,
    this.therapyReminders = true,
    this.meditationReminders = false,
    this.journalReminders = false,
    this.communityAlerts = true,
    this.marketingAlerts = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.timezone = 'UTC',
    this.moodReminderTime = '20:00',
    this.sleepReminderTime = '22:30',
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      moodReminders: json['moodReminders'] as bool? ?? true,
      sleepReminders: json['sleepReminders'] as bool? ?? true,
      assessmentReminders: json['assessmentReminders'] as bool? ?? true,
      weeklyReportAlerts: json['weeklyReportAlerts'] as bool? ?? true,
      streakAlerts: json['streakAlerts'] as bool? ?? true,
      therapyReminders: json['therapyReminders'] as bool? ?? true,
      meditationReminders: json['meditationReminders'] as bool? ?? false,
      journalReminders: json['journalReminders'] as bool? ?? false,
      communityAlerts: json['communityAlerts'] as bool? ?? true,
      marketingAlerts: json['marketingAlerts'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      moodReminderTime: json['moodReminderTime'] as String? ?? '20:00',
      sleepReminderTime: json['sleepReminderTime'] as String? ?? '22:30',
    );
  }

  Map<String, dynamic> toJson() => {
    'moodReminders': moodReminders,
    'sleepReminders': sleepReminders,
    'assessmentReminders': assessmentReminders,
    'weeklyReportAlerts': weeklyReportAlerts,
    'streakAlerts': streakAlerts,
    'therapyReminders': therapyReminders,
    'meditationReminders': meditationReminders,
    'journalReminders': journalReminders,
    'communityAlerts': communityAlerts,
    'marketingAlerts': marketingAlerts,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
    'timezone': timezone,
    'moodReminderTime': moodReminderTime,
    'sleepReminderTime': sleepReminderTime,
  };
}
