import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/crisis_model.dart';

/// Encrypted offline storage for sensitive crisis support data.
/// Works for both guest users and as a cache for authenticated users.
class CrisisLocalStorage {
  static const _planKey = 'mindnova_support_plan';
  static const _contactsKey = 'mindnova_emergency_contacts';
  static const _sosHistoryKey = 'mindnova_sos_history';
  static const _syncQueueKey = 'mindnova_sync_queue';

  final FlutterSecureStorage _storage;

  CrisisLocalStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              lOptions: LinuxOptions(),
            );

  // ─── Support Plan ─────────────────────────────────────────

  Future<SupportPlan?> loadPlan() async {
    try {
      final raw = await _storage.read(key: _planKey);
      if (raw == null || raw.isEmpty) return null;
      return SupportPlan.fromJsonString(raw);
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to load plan: $e');
      return null;
    }
  }

  Future<void> savePlan(SupportPlan plan) async {
    try {
      await _storage.write(key: _planKey, value: plan.toJsonString());
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to save plan: $e');
    }
  }

  Future<void> clearPlan() async {
    try {
      await _storage.delete(key: _planKey);
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to clear plan: $e');
    }
  }

  // ─── Emergency Contacts ───────────────────────────────────

  Future<List<EmergencyContact>> loadContacts() async {
    try {
      final raw = await _storage.read(key: _contactsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => EmergencyContact.fromJson(e)).toList();
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to load contacts: $e');
      return [];
    }
  }

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    try {
      final json = jsonEncode(contacts.map((c) => c.toJson()).toList());
      await _storage.write(key: _contactsKey, value: json);
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to save contacts: $e');
    }
  }

  Future<void> clearContacts() async {
    try {
      await _storage.delete(key: _contactsKey);
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to clear contacts: $e');
    }
  }

  // ─── SOS Event History (anonymous analytics) ──────────────

  Future<void> logSosEvent(String action) async {
    try {
      final raw = await _storage.read(key: _sosHistoryKey);
      final events = raw != null ? List<Map<String, dynamic>>.from(jsonDecode(raw)) : <Map<String, dynamic>>[];
      events.add({
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      });
      // Keep last 50 events only
      final trimmed = events.length > 50 ? events.sublist(events.length - 50) : events;
      await _storage.write(key: _sosHistoryKey, value: jsonEncode(trimmed));
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to log SOS event: $e');
    }
  }

  // ─── Sync Queue (Offline-First) ───────────────────────────

  Future<void> enqueueSyncAction(String type, Map<String, dynamic> payload) async {
    try {
      final raw = await _storage.read(key: _syncQueueKey);
      final queue = raw != null ? List<Map<String, dynamic>>.from(jsonDecode(raw)) : <Map<String, dynamic>>[];
      
      // If it's a PLAN update, we can overwrite existing PLAN updates in the queue
      // to avoid sending multiple redundant updates.
      if (type == 'PLAN_UPDATE') {
        queue.removeWhere((item) => item['type'] == 'PLAN_UPDATE');
      }

      queue.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'payload': payload,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _storage.write(key: _syncQueueKey, value: jsonEncode(queue));
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to enqueue sync action: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    try {
      final raw = await _storage.read(key: _syncQueueKey);
      if (raw == null || raw.isEmpty) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to get sync queue: $e');
      return [];
    }
  }

  Future<void> removeSyncAction(String id) async {
    try {
      final raw = await _storage.read(key: _syncQueueKey);
      if (raw == null || raw.isEmpty) return;
      final queue = List<Map<String, dynamic>>.from(jsonDecode(raw));
      queue.removeWhere((item) => item['id'] == id);
      await _storage.write(key: _syncQueueKey, value: jsonEncode(queue));
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to remove sync action: $e');
    }
  }

  Future<void> clearSyncQueue() async {
    try {
      await _storage.delete(key: _syncQueueKey);
    } catch (e) {
      debugPrint('⚠️ [CrisisLocal] Failed to clear sync queue: $e');
    }
  }

  /// Clear all crisis data (for logout)
  Future<void> clearAll() async {
    await Future.wait([
      clearPlan(),
      clearContacts(),
      clearSyncQueue(),
      _storage.delete(key: _sosHistoryKey),
    ]);
  }
}
