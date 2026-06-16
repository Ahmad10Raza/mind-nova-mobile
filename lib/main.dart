import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/router_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/sleep/services/sleep_audio_handler.dart';
import 'features/focus/services/focus_background_service.dart';

import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'core/services/local_notification_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
    JustAudioMediaKit.ensureInitialized();
  }

  await LocalNotificationService.initialize();
  
  try {
    if (kIsWeb || (!Platform.isLinux && !Platform.isWindows)) {
      await Firebase.initializeApp();
    } else {
      debugPrint("Firebase is not supported natively on this platform yet. Skipping initialization.");
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  try {
    audioHandler = await AudioService.init(
      builder: () => SleepAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mindnova.sleep.channel.audio',
        androidNotificationChannelName: 'MindNova Sleep Mode',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e) {
    debugPrint("AudioService init error: $e");
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await FocusBackgroundService.initialize();
    } catch (e) {
      debugPrint("FocusBackgroundService init error: $e");
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MindNovaApp(),
    ),
  );
}

class MindNovaApp extends ConsumerWidget {
  const MindNovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MindNova',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
