import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConstants {
  /// The Industry Best Practice: Use '--dart-define' to inject the URL at build time.
  /// 
  /// How to use:
  /// 1. For Local: Just run 'flutter run' (Uses the default value below)
  /// 2. For Production: 'flutter run --dart-define=BASE_URL=https://your-api.com'
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );

  /// Helper to check if we are in production mode based on the URL
  static bool get isProduction => baseUrl.contains('onrender.com');
}
