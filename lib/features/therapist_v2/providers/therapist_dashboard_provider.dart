import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../therapist/providers/therapist_provider.dart';

class TherapistDashboardState {
  final List<dynamic> pendingRequests;
  final List<dynamic> upcomingSessions;
  final List<dynamic> completedSessions;
  final List<dynamic> pendingMessages;
  final bool isLoading;
  final String? error;

  TherapistDashboardState({
    required this.pendingRequests,
    required this.upcomingSessions,
    required this.completedSessions,
    required this.pendingMessages,
    this.isLoading = false,
    this.error,
  });

  TherapistDashboardState copyWith({
    List<dynamic>? pendingRequests,
    List<dynamic>? upcomingSessions,
    List<dynamic>? completedSessions,
    List<dynamic>? pendingMessages,
    bool? isLoading,
    String? error,
  }) {
    return TherapistDashboardState(
      pendingRequests: pendingRequests ?? this.pendingRequests,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      pendingMessages: pendingMessages ?? this.pendingMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TherapistDashboardNotifier extends AsyncNotifier<TherapistDashboardState> {
  @override
  FutureOr<TherapistDashboardState> build() async {
    return _loadDashboardData();
  }

  Future<TherapistDashboardState> _loadDashboardData() async {
    try {
      final therapistService = ref.read(therapistProvider.notifier);
      
      final results = await Future.wait([
        therapistService.getPanelRequests(),
        therapistService.getPanelBookings(),
        therapistService.getPanelCompletedBookings(),
        therapistService.getPanelMessages(),
      ]);

      return TherapistDashboardState(
        pendingRequests: results[0],
        upcomingSessions: results[1],
        completedSessions: results[2],
        pendingMessages: results[3],
        isLoading: false,
      );
    } catch (e) {
      return TherapistDashboardState(
        pendingRequests: [],
        upcomingSessions: [],
        completedSessions: [],
        pendingMessages: [],
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadDashboardData());
  }

  Future<bool> acceptRequest(String appointmentId) async {
    try {
      final success = await ref.read(therapistProvider.notifier).acceptBooking(appointmentId);
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> declineRequest(String appointmentId) async {
    try {
      final success = await ref.read(therapistProvider.notifier).declineBooking(appointmentId);
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final therapistDashboardProvider = AsyncNotifierProvider<TherapistDashboardNotifier, TherapistDashboardState>(() {
  return TherapistDashboardNotifier();
});
