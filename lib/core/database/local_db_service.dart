import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mindnova_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // FFI is required for desktop platforms (Linux/Windows)
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_logs_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT,
        date TEXT NOT NULL,
        score INTEGER NOT NULL,
        note TEXT,
        stress INTEGER,
        anxiety INTEGER,
        sleep_hours REAL,
        tags TEXT,
        sync_status INTEGER NOT NULL DEFAULT 0 
      )
    ''');

    await _createSleepTable(db);
    
    // 0 = pending sync, 1 = synced
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSleepTable(db);
    }
  }

  Future<void> _createSleepTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sleep_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT,
        date TEXT NOT NULL UNIQUE,
        bedtime TEXT,
        wake_time TEXT,
        duration_hours REAL NOT NULL,
        quality REAL NOT NULL,
        awakenings INTEGER DEFAULT 0,
        stress_before REAL,
        morning_mood REAL,
        sync_status INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ─── Mood Log CRUD ─────────────────────────────────────────────────────────

  // Insert a new local log
  Future<int> insertMoodLog(Map<String, dynamic> logData) async {
    final db = await database;
    return await db.insert('mood_logs_local', logData);
  }

  // Fetch pending records for background sync
  Future<List<Map<String, dynamic>>> getPendingLogs() async {
    final db = await database;
    return await db.query(
      'mood_logs_local',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
  }

  // Delete records older than 30 days that are ALREADY synced
  Future<void> purgeOldSyncedLogs() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    await db.delete(
      'mood_logs_local',
      where: 'sync_status = ? AND date < ?',
      whereArgs: [1, thirtyDaysAgo],
    );
  }
  
  // Mark specific local record as synced
  Future<void> markAsSynced(int localId, String syncId) async {
    final db = await database;
    await db.update(
      'mood_logs_local',
      {'sync_status': 1, 'sync_id': syncId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ─── Sleep Log CRUD ─────────────────────────────────────────────────────────

  /// Insert or replace a sleep log for a given date.
  Future<int> upsertSleepLog(Map<String, dynamic> logData) async {
    final db = await database;
    // Try update first
    final date = logData['date'];
    final existing = await db.query(
      'sleep_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'sleep_logs',
        logData,
        where: 'date = ?',
        whereArgs: [date],
      );
      return existing.first['id'] as int;
    }
    return await db.insert('sleep_logs', logData);
  }

  /// Get sleep logs for the last [days] days, ordered newest first.
  Future<List<Map<String, dynamic>>> getSleepLogs({int days = 7}) async {
    final db = await database;
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String().split('T')[0];
    return await db.query(
      'sleep_logs',
      where: 'date >= ?',
      whereArgs: [since],
      orderBy: 'date DESC',
    );
  }

  /// Get today's sleep log, or null if not logged.
  Future<Map<String, dynamic>?> getTodaySleepLog() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final results = await db.query(
      'sleep_logs',
      where: 'date = ?',
      whereArgs: [today],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get pending (unsynced) sleep logs.
  Future<List<Map<String, dynamic>>> getPendingSleepLogs() async {
    final db = await database;
    return await db.query(
      'sleep_logs',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
  }

  /// Mark a sleep log as synced with backend ID.
  Future<void> markSleepLogSynced(int localId, String syncId) async {
    final db = await database;
    await db.update(
      'sleep_logs',
      {'sync_status': 1, 'sync_id': syncId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}

final localDbProvider = Provider<LocalDbService>((ref) => LocalDbService());

