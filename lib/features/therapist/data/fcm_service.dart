import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  debugPrint("Handling a background message: ${message.messageId}");
}

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  Future<void> initialize(BuildContext context) async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // Get token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _registerTokenOnBackend(token);
      }

      // Handle token refresh
      _fcm.onTokenRefresh.listen(_registerTokenOnBackend);

      // Local notifications setup for foreground messages
      const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initIOS = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(android: initAndroid, iOS: initIOS);
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          _handleNotificationTap(context, details.payload);
        }
      );

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'mindnova_high_importance',
                'High Importance Notifications',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails()
            ),
            payload: message.data['appointmentId'] ?? message.data['threadId'],
          );
        }
      });

      // Background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // App opened from background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleDeepLink(context, message.data);
      });

      // App opened from terminated state via notification
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        // Delay to allow routing to initialize
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(context, initialMessage.data);
        });
      }
    }
  }

  Future<void> _registerTokenOnBackend(String token) async {
    try {
      await _apiClient.post('/notifications/device-tokens', data: {
        'token': token,
        'platform': 'MOBILE', // or detect platform properly
      });
      debugPrint('FCM Token registered');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  void _handleDeepLink(BuildContext context, Map<String, dynamic> data) {
    if (data.containsKey('appointmentId')) {
      // Go to specific therapy appointment or video call
      // context.push('/therapist/call/${data['appointmentId']}');
    } else if (data.containsKey('threadId')) {
      // Go to chat
      // context.push('/therapist/chat/${data['threadId']}');
    }
  }

  void _handleNotificationTap(BuildContext context, String? payload) {
    if (payload != null) {
      // Handle navigation based on payload
      // Simple routing for now
    }
  }
}
