import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  int remainingSeconds = 0;
  bool isPaused = false;
  Timer? timer;

  void updateNotification() {
    if (service is AndroidServiceInstance) {
      final duration = Duration(seconds: remainingSeconds);
      final timeStr = "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
      service.setForegroundNotificationInfo(
        title: isPaused ? "Focus Paused" : "Focusing deeply...",
        content: "Remaining: $timeStr",
      );
    }
  }

  service.on('startTimer').listen((event) {
    remainingSeconds = event?['seconds'] ?? 0;
    isPaused = false;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isPaused && remainingSeconds > 0) {
        remainingSeconds--;
        service.invoke('updateTimer', {
          'seconds': remainingSeconds,
          'isPaused': isPaused,
        });
        updateNotification();
      } else if (remainingSeconds == 0) {
        service.invoke('timerFinished');
        t.cancel();
      }
    });
    updateNotification();
  });

  service.on('pauseTimer').listen((event) {
    isPaused = true;
    updateNotification();
  });

  service.on('resumeTimer').listen((event) {
    isPaused = false;
    updateNotification();
  });

  service.on('stopService').listen((event) {
    timer?.cancel();
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) => service.setAsForegroundService());
    service.on('setAsBackground').listen((event) => service.setAsBackgroundService());
  }
}

class FocusBackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'mindnova_focus_timer',
        initialNotificationTitle: 'MindNova Focus',
        initialNotificationContent: 'Zen Mode Active',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }
}
