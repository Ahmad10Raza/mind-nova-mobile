import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
}
