import 'package:dio/dio.dart';
import '../models/gratitude_model.dart';
import '../../../core/network/api_client.dart';

class GratitudeService {
  final ApiClient _apiClient;

  GratitudeService(this._apiClient);

  Future<GratitudeEntry> createEntry({
    String? content,
    String? category,
    List<String>? tags,
    String? moodState,
  }) async {
    final response = await _apiClient.post('/gratitude/create', data: {
      'content': content,
      'category': category,
      'tags': tags ?? [],
      'moodState': moodState,
    });
    return GratitudeEntry.fromJson(response.data);
  }

  Future<List<GratitudeEntry>> getHistory({int skip = 0, int take = 20}) async {
    final response = await _apiClient.get('/gratitude/history', queryParameters: {
      'skip': skip,
      'take': take,
    });
    return (response.data as List).map((e) => GratitudeEntry.fromJson(e)).toList();
  }

  Future<GratitudeAnalytics> getAnalytics() async {
    final response = await _apiClient.get('/gratitude/analytics');
    return GratitudeAnalytics.fromJson(response.data);
  }

  Future<List<GratitudeCategoryStat>> getCategories() async {
    final response = await _apiClient.get('/gratitude/categories');
    return (response.data as List).map((e) => GratitudeCategoryStat.fromJson(e)).toList();
  }

  Future<List<GratitudeMemory>> getMemoryVault() async {
    final response = await _apiClient.get('/gratitude/memory-vault');
    return (response.data as List).map((e) => GratitudeMemory.fromJson(e)).toList();
  }

  Future<GratitudeEntry> toggleFavorite(String id) async {
    final response = await _apiClient.post('/gratitude/$id/favorite');
    return GratitudeEntry.fromJson(response.data);
  }
}
