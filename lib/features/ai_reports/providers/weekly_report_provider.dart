import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mood/providers/mood_log_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/weekly_report_model.dart';

/// Fetches the latest weekly report (or starter report for new users).
final weeklyReportProvider = FutureProvider<WeeklyReport?>((ref) async {
  ref.watch(authProvider);
  final moodService = ref.watch(moodServiceProvider);
  return moodService.fetchLatestWeeklyReport();
});

/// Fetches paginated weekly report history (last 12 weeks).
final weeklyReportHistoryProvider = FutureProvider<List<WeeklyReport>>((ref) async {
  ref.watch(authProvider);
  final moodService = ref.watch(moodServiceProvider);
  return moodService.fetchWeeklyReportHistory();
});

/// Triggers manual weekly report generation with rate limiting.
final triggerWeeklyReportProvider = FutureProvider.family<Map<String, dynamic>, void>((ref, _) async {
  final moodService = ref.watch(moodServiceProvider);
  return moodService.triggerWeeklyReport();
});
