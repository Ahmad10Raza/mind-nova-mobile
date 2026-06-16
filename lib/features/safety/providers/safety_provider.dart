import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../data/safety_service.dart';
import '../data/crisis_local_storage.dart';
import '../models/crisis_model.dart';

// ═══════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════

class SafetyState {
  final bool crisisDetected;
  final AppCrisisAnalysis? lastAnalysis;
  final List<EmergencyResource> resources;
  final SupportPlan? plan;
  final List<EmergencyContact> contacts;
  final bool sosActive;
  final bool recoveryMode;
  final bool isLoading;
  final String? error;

  SafetyState({
    this.crisisDetected = false,
    this.lastAnalysis,
    this.resources = const [],
    this.plan,
    this.contacts = const [],
    this.sosActive = false,
    this.recoveryMode = false,
    this.isLoading = false,
    this.error,
  });

  SafetyState copyWith({
    bool? crisisDetected,
    AppCrisisAnalysis? lastAnalysis,
    List<EmergencyResource>? resources,
    SupportPlan? plan,
    List<EmergencyContact>? contacts,
    bool? sosActive,
    bool? recoveryMode,
    bool? isLoading,
    String? error,
  }) {
    return SafetyState(
      crisisDetected: crisisDetected ?? this.crisisDetected,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
      resources: resources ?? this.resources,
      plan: plan ?? this.plan,
      contacts: contacts ?? this.contacts,
      sosActive: sosActive ?? this.sosActive,
      recoveryMode: recoveryMode ?? this.recoveryMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get the highest-priority contact for quick call
  EmergencyContact? get primaryContact {
    if (contacts.isEmpty) return null;
    // Favorites first, then by priority descending
    final sorted = [...contacts]..sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return b.priority.compareTo(a.priority);
    });
    return sorted.first;
  }

  /// Contacts that allow quick SMS
  List<EmergencyContact> get smsContacts =>
      contacts.where((c) => c.allowQuickSms).toList();
}

// ═══════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════

class SafetyNotifier extends Notifier<SafetyState> {
  late final SafetyService _service;
  late final CrisisLocalStorage _localStorage;

  @override
  SafetyState build() {
    _service = ref.read(safetyServiceProvider);
    _localStorage = ref.read(crisisLocalStorageProvider);
    // Load cached data on startup
    _loadOfflineData();
    return SafetyState();
  }

  /// Whether user is authenticated (has access token)
  Future<bool> get _isAuthenticated async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  // ─── Offline-First Data Loading ───────────────────────────

  Future<void> _loadOfflineData() async {
    try {
      // Always load local cache first (instant)
      final localPlan = await _localStorage.loadPlan();
      final localContacts = await _localStorage.loadContacts();

      state = state.copyWith(
        plan: localPlan,
        contacts: localContacts,
      );

      // Then try to sync from backend if authenticated
      if (await _isAuthenticated) {
        await _flushSyncQueue();
        await _syncFromBackend();
      }
    } catch (e) {
      debugPrint('⚠️ [SafetyNotifier] Offline data load failed: $e');
    }
  }

  Future<void> _syncFromBackend() async {
    try {
      final remotePlan = await _service.getPlan();
      final remoteContacts = await _service.getContacts();

      if (remotePlan != null) {
        final localPlan = state.plan;
        if (localPlan == null || localPlan.updatedAt == null || remotePlan.updatedAt == null || remotePlan.updatedAt!.isAfter(localPlan.updatedAt!)) {
          state = state.copyWith(plan: remotePlan);
          await _localStorage.savePlan(remotePlan);
        }
      }

      if (remoteContacts.isNotEmpty) {
        // Merge contacts: latest updatedAt wins
        final mergedContacts = <EmergencyContact>[];
        final localMap = {for (var c in state.contacts) c.id: c};
        
        for (final remote in remoteContacts) {
          if (remote.id != null && localMap.containsKey(remote.id)) {
            final local = localMap[remote.id]!;
            if (local.updatedAt != null && remote.updatedAt != null && local.updatedAt!.isAfter(remote.updatedAt!)) {
              mergedContacts.add(local); // Local is newer
            } else {
              mergedContacts.add(remote); // Remote is newer
            }
            localMap.remove(remote.id);
          } else {
            mergedContacts.add(remote); // New remote contact
          }
        }
        // Add remaining local contacts (might be pending sync)
        mergedContacts.addAll(localMap.values);

        state = state.copyWith(contacts: mergedContacts);
        await _localStorage.saveContacts(mergedContacts);
      }
    } catch (e) {
      // Offline or server down — local cache is fine
      debugPrint('⚠️ [SafetyNotifier] Backend sync failed, using local: $e');
    }
  }

  Future<void> _flushSyncQueue() async {
    try {
      final queue = await _localStorage.getSyncQueue();
      if (queue.isEmpty) return;

      for (final item in queue) {
        try {
          final type = item['type'] as String;
          final payload = item['payload'] as Map<String, dynamic>;

          if (type == 'PLAN_UPDATE') {
            await _service.savePlan(SupportPlan.fromJson(payload));
          } else if (type == 'CONTACT_ADD') {
            await _service.addContact(EmergencyContact.fromJson(payload));
          } else if (type == 'CONTACT_UPDATE') {
            await _service.updateContact(EmergencyContact.fromJson(payload));
          } else if (type == 'CONTACT_DELETE') {
            await _service.deleteContact(payload['id']);
          }

          // Remove if successful
          await _localStorage.removeSyncAction(item['id']);
        } catch (e) {
          debugPrint('⚠️ [SafetyNotifier] Sync queue item failed, will retry: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [SafetyNotifier] Failed to flush sync queue: $e');
    }
  }

  // ─── Emergency Resources ──────────────────────────────────

  Future<void> fetchResources({String? country}) async {
    state = state.copyWith(isLoading: true);
    final resources = await _service.getResources(country: country);
    state = state.copyWith(resources: resources, isLoading: false);
  }

  // ─── Crisis Detection ─────────────────────────────────────

  void triggerCrisis(AppCrisisAnalysis analysis) {
    if (analysis.triggerScreen) {
      state = state.copyWith(
        crisisDetected: true,
        lastAnalysis: analysis,
      );
    }
  }

  // ─── Support Plan ─────────────────────────────────────────

  Future<void> loadPlan() async {
    state = state.copyWith(isLoading: true);
    try {
      // Local first
      final localPlan = await _localStorage.loadPlan();
      if (localPlan != null) {
        state = state.copyWith(plan: localPlan, isLoading: false);
      }

      // Try remote sync
      if (await _isAuthenticated) {
        final remotePlan = await _service.getPlan();
        if (remotePlan != null) {
          state = state.copyWith(plan: remotePlan, isLoading: false);
          await _localStorage.savePlan(remotePlan);
          return;
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> savePlan(SupportPlan plan) async {
    // Save locally immediately (offline-first)
    await _localStorage.savePlan(plan);
    state = state.copyWith(plan: plan);

    // Sync to backend if authenticated (fire-and-forget)
    if (await _isAuthenticated) {
      _service.savePlan(plan).then((remote) {
        if (remote != null) {
          _localStorage.savePlan(remote);
          state = state.copyWith(plan: remote);
        }
      }).catchError((_) {
        _localStorage.enqueueSyncAction('PLAN_UPDATE', plan.toJson());
      });
    } else {
      _localStorage.enqueueSyncAction('PLAN_UPDATE', plan.toJson());
    }

    // Log event
    _logEventSilent('PLAN_UPDATED', 'User updated support plan');
  }

  // ─── Contacts ─────────────────────────────────────────────

  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final localContacts = await _localStorage.loadContacts();
      state = state.copyWith(contacts: localContacts);

      if (await _isAuthenticated) {
        final remoteContacts = await _service.getContacts();
        if (remoteContacts.isNotEmpty) {
          state = state.copyWith(contacts: remoteContacts);
          await _localStorage.saveContacts(remoteContacts);
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    // Optimistic local add
    final updated = [...state.contacts, contact];
    state = state.copyWith(contacts: updated);
    await _localStorage.saveContacts(updated);

    // Sync to backend
    if (await _isAuthenticated) {
      try {
        final remote = await _service.addContact(contact);
        if (remote != null) {
          final synced = state.contacts.map((c) =>
              c.phoneNumber == contact.phoneNumber && c.id == null ? remote : c
          ).toList();
          state = state.copyWith(contacts: synced);
          await _localStorage.saveContacts(synced);
        }
      } catch (_) {
        _localStorage.enqueueSyncAction('CONTACT_ADD', contact.toJson());
      }
    } else {
      _localStorage.enqueueSyncAction('CONTACT_ADD', contact.toJson());
    }

    _logEventSilent('CONTACT_ADDED', 'Added: ${contact.name}');
  }

  Future<void> updateContact(EmergencyContact contact) async {
    final updated = state.contacts.map((c) => c.id == contact.id ? contact : c).toList();
    state = state.copyWith(contacts: updated);
    await _localStorage.saveContacts(updated);

    if (await _isAuthenticated && contact.id != null) {
      _service.updateContact(contact).catchError((_) {
        _localStorage.enqueueSyncAction('CONTACT_UPDATE', contact.toJson());
      });
    } else if (contact.id != null) {
      _localStorage.enqueueSyncAction('CONTACT_UPDATE', contact.toJson());
    }
  }

  Future<void> updateAllContacts(List<EmergencyContact> updatedContacts) async {
    state = state.copyWith(contacts: updatedContacts);
    await _localStorage.saveContacts(updatedContacts);

    // Sync individual changes (or ideally batch them, but doing individual for now)
    if (await _isAuthenticated) {
      for (final contact in updatedContacts) {
        if (contact.id != null) {
           _service.updateContact(contact).catchError((_) {
             _localStorage.enqueueSyncAction('CONTACT_UPDATE', contact.toJson());
           });
        }
      }
    }
  }

  Future<void> deleteContact(String contactId) async {
    final updated = state.contacts.where((c) => c.id != contactId).toList();
    state = state.copyWith(contacts: updated);
    await _localStorage.saveContacts(updated);

    if (await _isAuthenticated) {
      _service.deleteContact(contactId).catchError((_) {
        _localStorage.enqueueSyncAction('CONTACT_DELETE', {'id': contactId});
        return false;
      });
    } else {
      _localStorage.enqueueSyncAction('CONTACT_DELETE', {'id': contactId});
    }

    _logEventSilent('CONTACT_REMOVED', 'Contact deleted');
  }

  void markContactUsed(String contactId) {
    _isAuthenticated.then((auth) {
      if (auth) _service.markContactUsed(contactId);
    });
    _localStorage.logSosEvent('CONTACT_USED:$contactId');
  }

  // ─── SOS Mode ─────────────────────────────────────────────

  Future<void> triggerSos() async {
    state = state.copyWith(sosActive: true);
    _localStorage.logSosEvent('SOS_TRIGGERED');

    if (await _isAuthenticated) {
      _service.triggerSos().catchError((_) {});
    }

    _logEventSilent('SOS_TRIGGERED', 'User activated quick help mode');
  }

  void deactivateSos() {
    state = state.copyWith(sosActive: false);
    _localStorage.logSosEvent('SOS_DEACTIVATED');
  }

  // ─── Recovery Flow ("I'm Feeling Safer") ──────────────────

  void enterRecoveryMode() {
    state = state.copyWith(recoveryMode: true, sosActive: false);
    _logEventSilent('RECOVERY_STARTED', 'User entered recovery flow');
  }

  Future<void> resolveCrisis() async {
    state = state.copyWith(isLoading: true);
    try {
      if (await _isAuthenticated) {
        await _service.markSafe();
      }
      state = state.copyWith(
        crisisDetected: false,
        lastAnalysis: null,
        sosActive: false,
        recoveryMode: false,
        isLoading: false,
      );
      _logEventSilent('MARKED_SAFE', 'User confirmed feeling safer');
    } catch (e) {
      // Even if API fails, still resolve locally
      state = state.copyWith(
        crisisDetected: false,
        lastAnalysis: null,
        sosActive: false,
        recoveryMode: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ─── Event Logging (fire-and-forget) ──────────────────────

  void _logEventSilent(String source, String action) {
    _localStorage.logSosEvent('$source:$action');
    _isAuthenticated.then((auth) {
      if (auth) _service.logEvent(source: source, action: action);
    });
  }

  /// Public logging for screen-level analytics
  void logAction(String action) {
    _logEventSilent('UI_ACTION', action);
  }
}

// ═══════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════

final crisisLocalStorageProvider = Provider<CrisisLocalStorage>((ref) {
  return CrisisLocalStorage();
});

final safetyServiceProvider = Provider<SafetyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SafetyService(apiClient);
});

final safetyProvider = NotifierProvider<SafetyNotifier, SafetyState>(() {
  return SafetyNotifier();
});
