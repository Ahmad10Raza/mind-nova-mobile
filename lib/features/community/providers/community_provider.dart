import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/community_service.dart';
import '../models/room_model.dart';

final communityServiceProvider = Provider<CommunityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityService(apiClient);
});

final liveRoomsProvider = FutureProvider.autoDispose<List<CommunityRoom>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getLiveRooms();
});

final upcomingRoomsProvider = FutureProvider.autoDispose<List<CommunityRoom>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getUpcomingRooms();
});

final roomDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, roomId) async {
  final service = ref.watch(communityServiceProvider);
  return service.getRoomDetails(roomId);
});

final roomSeriesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(communityServiceProvider);
  return service.getRoomSeries();
});
