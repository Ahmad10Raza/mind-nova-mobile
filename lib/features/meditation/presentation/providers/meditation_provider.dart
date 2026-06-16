import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/meditation_service.dart';
import '../../domain/meditation_model.dart';

final meditationServiceProvider = Provider<MeditationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MeditationService(apiClient);
});

final meditationDashboardProvider = FutureProvider.autoDispose<MeditationDashboardStats>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getDashboardStats();
});

final meditationCatalogProvider = FutureProvider.autoDispose.family<List<MeditationContent>, String?>((ref, category) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getMasterCatalog(category: category);
});

final recommendedMeditationProvider = FutureProvider.autoDispose<List<MeditationContent>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getRecommended();
});

final meditationCategoriesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getCategories();
});

final recentSessionsProvider = FutureProvider.autoDispose<List<MeditationSession>>((ref) async {
  final service = ref.watch(meditationServiceProvider);
  return service.getRecentSessions(limit: 30);
});
