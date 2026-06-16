import 'package:dio/dio.dart';
import '../models/journal_model.dart';
import '../../../core/network/api_client.dart';

class JournalService {
  final ApiClient _apiClient;

  JournalService(this._apiClient);

  Future<JournalEntry> createEntry({
    String? title,
    String? content,
    String? moodState,
    String? journalType,
    List<String>? tags,
    bool isDraft = false,
  }) async {
    final response = await _apiClient.post('/journal/create', data: {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (moodState != null) 'moodState': moodState,
      if (journalType != null) 'journalType': journalType,
      if (tags != null) 'tags': tags,
      'isDraft': isDraft,
    });
    return JournalEntry.fromJson(response.data);
  }

  Future<JournalEntry> updateEntry(String id, {
    String? title,
    String? content,
    String? moodState,
    List<String>? tags,
    bool? isDraft,
    bool? isFavorite,
    bool? isPinned,
    bool? isLocked,
  }) async {
    final response = await _apiClient.put('/journal/update/$id', data: {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (moodState != null) 'moodState': moodState,
      if (tags != null) 'tags': tags,
      if (isDraft != null) 'isDraft': isDraft,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isPinned != null) 'isPinned': isPinned,
      if (isLocked != null) 'isLocked': isLocked,
    });
    return JournalEntry.fromJson(response.data);
  }

  Future<List<JournalEntry>> getHistory({
    int skip = 0,
    int take = 20,
    String? mood,
    String? type,
    String? query,
  }) async {
    final response = await _apiClient.get('/journal/history', queryParameters: {
      'skip': skip,
      'take': take,
      if (mood != null) 'mood': mood,
      if (type != null) 'type': type,
      if (query != null) 'q': query,
    });
    return (response.data as List).map((e) => JournalEntry.fromJson(e)).toList();
  }

  Future<JournalEntry> getEntryById(String id) async {
    final response = await _apiClient.get('/journal/entry/$id');
    return JournalEntry.fromJson(response.data);
  }

  Future<JournalAnalytics> getAnalytics() async {
    final response = await _apiClient.get('/journal/analytics');
    return JournalAnalytics.fromJson(response.data);
  }

  Future<void> deleteEntry(String id) async {
    await _apiClient.delete('/journal/delete/$id');
  }

  Future<JournalEntry?> getMemoryResurface() async {
    try {
      final response = await _apiClient.get('/journal/memory-resurface');
      if (response.data == null) return null;
      return JournalEntry.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getDailyPrompt() async {
    try {
      final response = await _apiClient.get('/journal/daily-prompt');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return {
        'prompt': 'What is one thing you appreciate about yourself today?',
        'context': 'Based on your recent patterns.',
        'detectedMood': 'Calm',
      };
    }
  }
}
