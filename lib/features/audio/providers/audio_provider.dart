import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/audio_service.dart';
import '../domain/audio_model.dart';

// ─── Service Provider ────────────────────────────────────────────────────────

final audioDataServiceProvider = Provider<AudioDataService>((ref) {
  final api = ref.watch(apiClientProvider);
  return AudioDataService(api);
});

// ─── Catalog Providers ───────────────────────────────────────────────────────

final audioCategoriesProvider = FutureProvider.autoDispose<List<AudioCategoryMeta>>((ref) async {
  return ref.watch(audioDataServiceProvider).getCategories();
});

final audioTracksProvider = FutureProvider.autoDispose.family<List<AudioTrack>, String?>((ref, category) async {
  return ref.watch(audioDataServiceProvider).getTracks(category: category);
});

final subCategoryAudioTracksProvider = FutureProvider.autoDispose.family<List<AudioTrack>, String>((ref, subCategory) async {
  return ref.watch(audioDataServiceProvider).getTracksBySubCategory(subCategory);
});

final recommendedAudioProvider = FutureProvider.autoDispose<List<AudioTrack>>((ref) async {
  return ref.watch(audioDataServiceProvider).getRecommended();
});

final audioHistoryProvider = FutureProvider.autoDispose<List<UserAudioHistory>>((ref) async {
  return ref.watch(audioDataServiceProvider).getHistory();
});

final audioFavoritesProvider = FutureProvider.autoDispose<List<UserAudioHistory>>((ref) async {
  return ref.watch(audioDataServiceProvider).getFavorites();
});

final audioDownloadsProvider = FutureProvider.autoDispose<List<DownloadedAudioTrack>>((ref) async {
  return ref.watch(audioDataServiceProvider).getDownloads();
});

// ─── Search Provider ─────────────────────────────────────────────────────────

final audioSearchProvider = FutureProvider.autoDispose.family<List<AudioTrack>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return ref.watch(audioDataServiceProvider).getTracks(search: query, limit: 30);
});
