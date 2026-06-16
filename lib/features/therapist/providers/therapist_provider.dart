import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/therapist_model.dart';
import '../data/therapist_socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TherapistNotifier extends AsyncNotifier<List<TherapistProfile>> {
  late final ApiClient _apiClient;

  @override
  FutureOr<List<TherapistProfile>> build() async {
    _apiClient = ref.read(apiClientProvider);
    _initPresenceSync();
    return _loadAllTherapists();
  }

  void _initPresenceSync() async {
    final socket = ref.read(therapistSocketProvider);
    final authState = ref.read(authProvider);
    final myUserId = authState.userId ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? 'dummy_token';
    
    socket.connect(myUserId, token);
    socket.onGlobalPresence.listen((data) {
      final userId = data['userId'];
      final status = data['status'];
      if (state.hasValue) {
        final list = state.value!;
        final index = list.indexWhere((p) => p.userId == userId);
        if (index != -1) {
          final updatedList = List<TherapistProfile>.from(list);
          updatedList[index] = updatedList[index].copyWith(onlineStatus: status);
          state = AsyncValue.data(updatedList);
        }
      }
    });

    socket.onScheduleUpdate.listen((data) {
      final tid = data['therapistId'];
      ref.invalidate(therapistScheduleProvider(tid));
    });
  }

  Future<List<TherapistProfile>> _loadAllTherapists() async {
    final response = await _apiClient.get('/therapists');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => TherapistProfile.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load therapists');
    }
  }

  Future<String> getTherapistId() async {
    final authUserId = ref.read(authProvider).userId;
    if (authUserId == null) return '';
    final profiles = await _loadAllTherapists();
    final match = profiles.where((p) => p.userId == authUserId).toList();
    return match.isNotEmpty ? match.first.id : '';
  }

  Future<List<TherapistProfile>> loadFeaturedTherapists() async {
    final response = await _apiClient.get('/therapists/featured');
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((e) => TherapistProfile.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load featured therapists');
    }
  }

  Future<List<Map<String, dynamic>>> getPricingTiers() async {
    final response = await _apiClient.get('/therapists/pricing');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception('Failed to load pricing tiers');
    }
  }

  Future<List<TherapistProfile>> matchTherapists(Map<String, dynamic> quizData) async {
    try {
      final response = await _apiClient.post('/therapists/match', data: quizData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        final matched = data.map((e) => TherapistProfile.fromJson(e)).toList();
        state = AsyncValue.data(matched); // Update state to show matched results first
        return matched;
      } else {
        throw Exception('Failed to match therapists');
      }
    } catch (e) {
      throw Exception('Network error during matching: $e');
    }
  }

  // ─── Search + Filter + Sort ──────────────────────────────────────

  Future<List<TherapistProfile>> searchTherapists({
    String? query,
    String? specialty,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (specialty != null && specialty.isNotEmpty) queryParams['specialty'] = specialty;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final uri = Uri(path: '/therapists/search', queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await _apiClient.get(uri.toString());

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => TherapistProfile.fromJson(e)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // ─── Schedule ────────────────────────────────────────────────────

  Future<List<TherapistAvailabilitySlot>> getTherapistSchedule(String therapistId) async {
    try {
      final response = await _apiClient.get('/therapists/$therapistId/schedule');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => TherapistAvailabilitySlot.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      throw Exception('Schedule error: $e');
    }
  }

  // ─── Booking ─────────────────────────────────────────────────────

  Future<bool> bookSession({
    required String patientId,
    required String therapistId,
    required int durationMin,
    required String type,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    String? notes,
    String? preferredSlot,
    String? guestName,
    String? guestPhone,
    String? guestEmail,
    String? aiSummary,
  }) async {
    try {
      final response = await _apiClient.post('/therapists/book', data: {
        'patientId': patientId,
        'therapistId': therapistId,
        'durationMin': durationMin,
        'type': type,
        'scheduledStartTime': scheduledStartTime?.toIso8601String(),
        'scheduledEndTime': scheduledEndTime?.toIso8601String(),
        'notes': notes,
        'preferredSlot': preferredSlot,
        'guestName': guestName,
        'guestPhone': guestPhone,
        'guestEmail': guestEmail,
        'aiSummary': aiSummary,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots(String therapistId, String date, {String? timezone}) async {
    try {
      final query = '?date=$date${timezone != null ? '&timezone=$timezone' : ''}';
      final response = await _apiClient.get('/therapists/$therapistId/available-slots$query');
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> cancelSession(String appointmentId, {String cancelledBy = 'USER'}) async {
    try {
      final response = await _apiClient.post('/therapists/cancel', data: {
        'appointmentId': appointmentId,
        'cancelledBy': cancelledBy,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rescheduleSession(String appointmentId, DateTime newStartTime, DateTime newEndTime) async {
    try {
      final response = await _apiClient.post('/therapists/reschedule', data: {
        'appointmentId': appointmentId,
        'newStartTime': newStartTime.toIso8601String(),
        'newEndTime': newEndTime.toIso8601String(),
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitReview({
    required String userId,
    required String therapistId,
    required int rating,
    String? comment,
    String? appointmentId,
  }) async {
    try {
      final response = await _apiClient.post('/therapists/review', data: {
        'userId': userId,
        'therapistId': therapistId,
        'rating': rating,
        'comment': comment,
        'appointmentId': appointmentId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSlaMetrics(String therapistId) async {
    try {
      final response = await _apiClient.get('/therapists/sla/$therapistId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── AI Assistant Layer ──────────────────────────────────────────

  Future<String?> generatePreSessionSummary(String appointmentId) async {
    try {
      final response = await _apiClient.post('/therapists/ai/pre-session/$appointmentId');
      if (response.statusCode == 200) {
        return response.data['aiSummary'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> generatePostSessionNotes(String appointmentId, String rawNotes) async {
    try {
      final response = await _apiClient.post(
        '/therapists/ai/post-session/$appointmentId',
        data: {'rawNotes': rawNotes},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Messaging ───────────────────────────────────────────────────

  Future<Map<String, dynamic>?> sendMessage({
    required String userId,
    required String therapistId,
    required String content,
    String? category,
    String? subject,
  }) async {
    try {
      final response = await _apiClient.post('/therapists/message', data: {
        'userId': userId,
        'therapistId': therapistId,
        'content': content,
        'category': category,
        'subject': subject,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<MessageThread>> getMessageThreads(String userId) async {
    try {
      final response = await _apiClient.get('/therapists/messages/$userId');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => MessageThread.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getThreadMessages(String threadId) async {
    try {
      final response = await _apiClient.get('/therapists/messages/thread/$threadId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Sessions ────────────────────────────────────────────────────

  Future<Map<String, List<UserSession>>> getUserSessions(String userId) async {
    try {
      final response = await _apiClient.get('/therapists/my-sessions/$userId');
      if (response.statusCode == 200) {
        final data = response.data;
        final upcoming = (data['upcoming'] as List?)
                ?.map((e) => UserSession.fromJson(e))
                .toList() ??
            [];
        final past = (data['past'] as List?)
                ?.map((e) => UserSession.fromJson(e))
                .toList() ??
            [];
        return {'upcoming': upcoming, 'past': past};
      }
      return {'upcoming': [], 'past': []};
    } catch (e) {
      return {'upcoming': [], 'past': []};
    }
  }

  // ─── Q&A + Waitlist ──────────────────────────────────────────────

  Future<bool> askQuestion({
    required String patientId,
    required String therapistId,
    required String question,
    required bool isAnonymous,
  }) async {
    try {
      final response = await _apiClient.post('/therapists/ask', data: {
        'patientId': patientId,
        'therapistId': therapistId,
        'question': question,
        'isAnonymous': isAnonymous,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinWaitlist(String patientId, String therapistId) async {
    try {
      final response = await _apiClient.post('/therapists/waitlist', data: {
        'patientId': patientId,
        'therapistId': therapistId,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── Panel Operations (Therapist Admin) ───────────────────────

  String _cachedTherapistId = '';

  Future<String> _getTherapistId() async {
    if (_cachedTherapistId.isNotEmpty) return _cachedTherapistId;
    // Try to resolve from current user's therapist profile
    try {
      final userId = ref.read(authProvider).userId;
      if (userId == null || userId.isEmpty) return '';
      final response = await _apiClient.get('/therapist-panel/profile-by-user/$userId');
      if (response.statusCode == 200) {
        _cachedTherapistId = response.data['id'] ?? '';
      }
    } catch (_) {}
    return _cachedTherapistId;
  }

  Future<List<dynamic>> getPanelRequests() async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/pending/$tid');
      if (response.statusCode == 200) return List<dynamic>.from(response.data);
      return [];
    } catch (e) { return []; }
  }

  Future<bool> updateOnlineStatus(String status) async {
    try {
      final tid = await _getTherapistId();
      if (tid.isEmpty) return false;
      final response = await _apiClient.post('/therapist-panel/status', data: {
        'therapistId': tid,
        'status': status,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> getPanelBookings() async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/active/$tid');
      if (response.statusCode == 200) return List<dynamic>.from(response.data);
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> getPanelCompletedBookings() async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/completed/$tid');
      if (response.statusCode == 200) return List<dynamic>.from(response.data);
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> getPanelMessages() async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/messages/$tid');
      if (response.statusCode == 200) return List<dynamic>.from(response.data);
      return [];
    } catch (e) { return []; }
  }

  Future<bool> acceptBooking(String appointmentId) async {
    try {
      final response = await _apiClient.post('/therapist-panel/accept', data: {'appointmentId': appointmentId});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> declineBooking(String appointmentId) async {
    try {
      final response = await _apiClient.post('/therapist-panel/decline', data: {'appointmentId': appointmentId});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<bool> completeSession(String appointmentId) async {
    try {
      final response = await _apiClient.post('/therapist-panel/complete', data: {'appointmentId': appointmentId});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  // ─── Panel Reply ──────────────────────────────────────────────────

  Future<bool> replyToMessage(String threadId, String content) async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.post('/therapist-panel/reply', data: {
        'threadId': threadId,
        'therapistId': tid,
        'content': content,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  // ─── Availability Management ──────────────────────────────────────

  Future<List<TherapistAvailabilitySlot>> getMySchedule() async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/schedule/$tid');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => TherapistAvailabilitySlot.fromJson(e)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> updateMyAvailability(List<Map<String, String>> slots) async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.post('/therapist-panel/update-slots', data: {
        'therapistId': tid,
        'slots': slots,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  // ─── Role Check ───────────────────────────────────────────────────

  Future<bool> checkIsTherapist() async {
    try {
      final tid = await _getTherapistId();
      return tid.isNotEmpty;
    } catch (e) { return false; }
  }
  Future<Map<String, dynamic>> fetchPatientInsights(String patientId) async {
    try {
      final tid = await _getTherapistId();
      final response = await _apiClient.get('/therapist-panel/patient-insights/$tid/$patientId');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch patient insights');
    }
  }
}

final therapistProvider = AsyncNotifierProvider<TherapistNotifier, List<TherapistProfile>>(() {
  return TherapistNotifier();
});

final therapistSocketProvider = Provider<TherapistSocketService>((ref) {
  final service = TherapistSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final therapistScheduleProvider = FutureProvider.family<List<TherapistAvailabilitySlot>, String>((ref, therapistId) async {
  return ref.read(therapistProvider.notifier).getTherapistSchedule(therapistId);
});

final userSessionsProvider = FutureProvider<Map<String, List<UserSession>>>((ref) async {
  final userId = ref.watch(authProvider).userId;
  if (userId == null) return {'upcoming': [], 'past': []};
  return ref.read(therapistProvider.notifier).getUserSessions(userId);
});

final featuredTherapistsProvider = FutureProvider<List<TherapistProfile>>((ref) async {
  return ref.read(therapistProvider.notifier).loadFeaturedTherapists();
});
