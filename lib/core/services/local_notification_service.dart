import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showStressNudge() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'recovery_nudge',
      'Recovery Nudges',
      channelDescription: 'Alerts when stress levels are elevated',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF26A69A),
    );
    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails();

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      100,
      'Stress Spike Detected 🚨',
      'Your stress level seems elevated. Take 2 minutes to reset your mind with a recovery session.',
      platformChannelSpecifics,
      payload: 'recovery_session',
    );
  }

  static Future<void> scheduleWeeklyReportNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weekly_reports',
      'Weekly Insights',
      channelDescription: 'Your personalized AI weekly insight report',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF9C27B0),
    );
    const LinuxNotificationDetails linuxPlatformChannelSpecifics = LinuxNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );

    // Schedule for Friday at 8:00 PM (20:00)
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);

    // If today is not Friday, or if it is Friday but past 8:00 PM, find the next Friday
    while (scheduledDate.weekday != DateTime.friday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      101,
      'Your Weekly MindNova Insight is Ready ✨',
      'Tap to review your activity, mood trends, and AI personalized recommendations for the week.',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_insight',
    );
  }
}
