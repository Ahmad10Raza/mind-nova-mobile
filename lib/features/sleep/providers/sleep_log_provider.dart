import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_db_service.dart';
import '../../../core/network/api_client.dart';

class SleepLog {
  final int? localId;
  final String? syncId;
  final DateTime date;
  final String? bedtime;
  final String? wakeTime;
  final double durationHours;
  final double quality; // 1 to 5
  final int awakenings;
  final double? stressBefore;
  final double? morningMood;

  SleepLog({
    this.localId,
    this.syncId,
    required this.date,
    this.bedtime,
    this.wakeTime,
    required this.durationHours,
    required this.quality,
    this.awakenings = 0,
    this.stressBefore,
    this.morningMood,
  });

  /// Create from local SQLite row.
  factory SleepLog.fromDb(Map<String, dynamic> row) {
    return SleepLog(
      localId: int.tryParse(row['id']?.toString() ?? ''),
      syncId: row['sync_id']?.toString(),
      date: row['date'] != null ? DateTime.tryParse(row['date'].toString()) ?? DateTime.now() : DateTime.now(),
      bedtime: row['bedtime']?.toString(),
      wakeTime: row['wake_time']?.toString(),
      durationHours: double.tryParse(row['duration_hours']?.toString() ?? '') ?? 0.0,
      quality: double.tryParse(row['quality']?.toString() ?? '') ?? 3.0,
      awakenings: int.tryParse(row['awakenings']?.toString() ?? '') ?? 0,
      stressBefore: double.tryParse(row['stress_before']?.toString() ?? ''),
      morningMood: double.tryParse(row['morning_mood']?.toString() ?? ''),
    );
  }

  /// Convert to SQLite map for insert/update.
  Map<String, dynamic> toDbMap() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'bedtime': bedtime,
      'wake_time': wakeTime,
      'duration_hours': durationHours,
      'quality': quality,
      'awakenings': awakenings,
      'stress_before': stressBefore,
      'morning_mood': morningMood,
      'sync_status': 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

class SleepLogNotifier extends AsyncNotifier<List<SleepLog>> {
  @override
  Future<List<SleepLog>> build() async {
    return await _loadFromDb();
  }

  Future<List<SleepLog>> _loadFromDb() async {
    try {
      final db = ref.read(localDbProvider);
      final rows = await db.getSleepLogs(days: 7);
      return rows.map((r) => SleepLog.fromDb(r)).toList();
    } catch (e) {
      debugPrint('Failed to load sleep logs: $e');
      return [];
    }
  }

  /// Add a new sleep log (persists to local DB + attempts backend sync).
  /// [forDate] allows logging for a past day (e.g. missed days). Defaults to today.
  Future<void> addLog({
    required double durationHours,
    required double quality,
    String? bedtime,
    String? wakeTime,
    int awakenings = 0,
    double? stressBefore,
    double? morningMood,
    DateTime? forDate,
  }) async {
    final log = SleepLog(
      date: forDate ?? DateTime.now(),
      bedtime: bedtime,
      wakeTime: wakeTime,
      durationHours: durationHours,
      quality: quality,
      awakenings: awakenings,
      stressBefore: stressBefore,
      morningMood: morningMood,
    );

    // Optimistic Update for Realtime UI + Web Testing
    final currentLogs = state.value ?? [];
    state = AsyncValue.data([log, ...currentLogs]);

    // 1. Persist locally
    try {
      final db = ref.read(localDbProvider);
      await db.upsertSleepLog(log.toDbMap());
      
      final dbLogs = await _loadFromDb();
      if (dbLogs.isNotEmpty) {
        state = AsyncValue.data(dbLogs);
      }
    } catch (e) {
      debugPrint('Failed to save sleep log locally: $e');
    }

    // 2. Attempt backend sync (fire-and-forget)
    _syncToBackend(log).ignore();
  }

  /// Sync a single log to the backend.
  Future<void> _syncToBackend(SleepLog log) async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post('/sleep/log', data: {
        'date': log.date.toIso8601String().split('T')[0],
        'bedtime': log.bedtime,
        'wakeTime': log.wakeTime,
        'durationHours': log.durationHours,
        'quality': log.quality,
        'awakenings': log.awakenings,
        'stressBefore': log.stressBefore,
        'morningMood': log.morningMood,
      });

      // Mark as synced in local DB
      if (response.statusCode == 200 || response.statusCode == 201) {
        final syncId = response.data['id']?.toString();
        if (syncId != null) {
          final db = ref.read(localDbProvider);
          final todayLog = await db.getTodaySleepLog();
          if (todayLog != null) {
            await db.markSleepLogSynced(todayLog['id'] as int, syncId);
          }
        }
      }
    } catch (e) {
      debugPrint('Sleep log backend sync failed (will retry later): $e');
    }
  }

  /// Sync all pending logs to backend (call on app start or connectivity restore).
  Future<void> syncPending() async {
    try {
      final db = ref.read(localDbProvider);
      final pending = await db.getPendingSleepLogs();
      final api = ref.read(apiClientProvider);

      for (final row in pending) {
        try {
          final response = await api.post('/sleep/log', data: {
            'date': row['date'],
            'bedtime': row['bedtime'],
            'wakeTime': row['wake_time'],
            'durationHours': row['duration_hours'],
            'quality': row['quality'],
            'awakenings': row['awakenings'],
            'stressBefore': row['stress_before'],
            'morningMood': row['morning_mood'],
          });

          if (response.statusCode == 200 || response.statusCode == 201) {
            final syncId = response.data['id']?.toString();
            if (syncId != null) {
              await db.markSleepLogSynced(row['id'] as int, syncId);
            }
          }
        } catch (e) {
          debugPrint('Sync failed for sleep log ${row['date']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Sleep sync batch failed: $e');
    }
  }
}

final sleepLogProvider = AsyncNotifierProvider<SleepLogNotifier, List<SleepLog>>(
  SleepLogNotifier.new,
);

/// Convenience provider: has the user logged sleep today?
final todaySleepLogProvider = FutureProvider.autoDispose<SleepLog?>((ref) async {
  try {
    final logs = await ref.watch(sleepLogProvider.future);
    final now = DateTime.now();
    try {
      return logs.firstWhere((log) => 
        log.date.year == now.year &&
        log.date.month == now.month &&
        log.date.day == now.day
      );
    } catch (_) {
      return null;
    }
  } catch (e) {
    return null;
  }
});

/// Average sleep hours from last 7 days (for dashboard metric card).
final sleepAverageProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final logs = await ref.watch(sleepLogProvider.future);

    if (logs.isEmpty) {
      return {'avg': 0.0, 'trend': 0.0, 'badge': 'No data', 'progress': 0.0};
    }

    final avg = logs.fold<double>(0, (s, l) => s + l.durationHours) / logs.length;

    // Trend: compare recent vs older half
    double trend = 0;
    if (logs.length >= 2) {
      final mid = logs.length ~/ 2;
      final recentAvg = logs.sublist(0, mid).fold<double>(0, (s, l) => s + l.durationHours) / mid;
      final olderAvg = logs.sublist(mid).fold<double>(0, (s, l) => s + l.durationHours) / (logs.length - mid);
      trend = double.parse((recentAvg - olderAvg).toStringAsFixed(1));
    }

    final avgQuality = logs.fold<double>(0, (s, l) => s + l.quality) / logs.length;
    String badge = 'Fair';
    if (avg >= 7 && avgQuality >= 3.5) {
      badge = 'Rested';
    } else if (avg >= 6 && avgQuality >= 2.5) {
      badge = 'Okay';
    } else if (avg < 5) {
      badge = 'Sleep Deprived';
    }

    return {
      'avg': double.parse(avg.toStringAsFixed(1)),
      'trend': trend,
      'badge': badge,
      'progress': (avg / 10.0).clamp(0.0, 1.0),
    };
  } catch (e) {
    return {'avg': 0.0, 'trend': 0.0, 'badge': 'No data', 'progress': 0.0};
  }
});

/// Dynamic Sleep Score & Metrics Provider
final sleepMetricsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final logs = await ref.watch(sleepLogProvider.future);

    if (logs.isEmpty) {
      return {
        'score': 0.0,
        'quality': 'N/A',
        'consistency': 0.0,
        'avgHours': 0.0,
        'stressLevel': 'Low',
        'streak': 0,
      };
    }

    final latest = logs.first; // Latest log

    // 1. Calculate Score (0.0 to 1.0)
    // Duration (40%): Target 8 hours
    double durationScore = (latest.durationHours / 8.0).clamp(0.0, 1.0) * 0.40;
    
    // Quality (30%): Range 1-5
    double qualityScore = (latest.quality / 5.0).clamp(0.0, 1.0) * 0.30;
    
    // Awakenings (15%): 0 is perfect, 5+ is poor
    double awakeningScore = (1.0 - (latest.awakenings / 5.0).clamp(0.0, 1.0)) * 0.15;
    
    // Morning Mood & Stress (15%)
    double stressFactor = 1.0 - ((latest.stressBefore ?? 5.0) / 10.0);
    double moodFactor = (latest.morningMood ?? 5.0) / 10.0;
    double psychologicalScore = ((stressFactor + moodFactor) / 2.0).clamp(0.0, 1.0) * 0.15;

    double totalScore = durationScore + qualityScore + awakeningScore + psychologicalScore;

    // 2. Consistency (0.0 to 1.0)
    // How much the duration varies across the logs
    double consistency = 1.0;
    if (logs.length > 1) {
      final avg = logs.fold<double>(0, (s, l) => s + l.durationHours) / logs.length;
      final variance = logs.fold<double>(0, (s, l) => s + pow(l.durationHours - avg, 2)) / logs.length;
      final stdDev = sqrt(variance);
      // If stdDev is 0, consistency is 1.0. If stdDev is 2h, consistency drops.
      consistency = (1.0 - (stdDev / 2.0)).clamp(0.0, 1.0);
    }

    // 3. Quality Badge
    String qualityBadge = 'Poor';
    if (totalScore >= 0.85) qualityBadge = 'Excellent';
    else if (totalScore >= 0.70) qualityBadge = 'Good';
    else if (totalScore >= 0.50) qualityBadge = 'Fair';

    final avgHours = logs.fold<double>(0, (s, l) => s + l.durationHours) / logs.length;

    // 4. Stress level text
    String stressLevel = 'Low';
    double lastStress = latest.stressBefore ?? 5.0;
    if (lastStress > 7) stressLevel = 'High';
    else if (lastStress > 4) stressLevel = 'Med';

    // 5. Calculate Streak
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // We need to fetch more logs to calculate a longer streak if needed, but for now check the 7 days we have
    for (int i = 0; i < 7; i++) {
      final dateStr = checkDate.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      final hasLog = logs.any((l) => l.date.toIso8601String().split('T')[0] == dateStr);
      if (hasLog) {
        streak++;
      } else if (i > 0) {
        // If we miss today (i=0) it's okay, but if we miss yesterday the streak is broken
        break;
      }
    }

    return {
      'score': totalScore,
      'quality': qualityBadge,
      'consistency': consistency,
      'avgHours': avgHours,
      'stressLevel': stressLevel,
      'streak': streak,
    };
  } catch (e) {
    debugPrint('Error calculating sleep metrics: $e');
    return {
      'score': 0.0,
      'quality': 'Error',
      'consistency': 0.0,
      'avgHours': 0.0,
      'stressLevel': 'Low',
      'streak': 0,
    };
  }
});
