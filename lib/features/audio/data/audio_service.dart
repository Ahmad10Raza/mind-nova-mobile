import '../../../core/network/api_client.dart';
import '../domain/audio_model.dart';

class AudioDataService {
  final ApiClient _api;
  AudioDataService(this._api);

  Future<List<AudioCategoryMeta>> getCategories() async {
    try {
      final res = await _api.get('/audio/categories');
      return (res.data as List).map((e) => AudioCategoryMeta.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AudioTrack>> getTracks({String? category, String? subCategory, String? search, int limit = 30}) async {
    try {
      final res = await _api.get('/audio/tracks', queryParameters: {
        if (category != null) 'category': category,
        if (subCategory != null) 'subCategory': subCategory,
        if (search != null) 'search': search,
        'limit': limit.toString(),
      });
      return (res.data as List).map((e) => AudioTrack.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AudioTrack>> getTracksByCategory(String category, {int limit = 30}) async {
    try {
      final res = await _api.get('/audio/categories/$category/tracks', queryParameters: {'limit': limit.toString()});
      return (res.data as List).map((e) => AudioTrack.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AudioTrack>> getTracksBySubCategory(String subcategory, {int limit = 30}) async {
    try {
      final res = await _api.get('/audio/subcategory/$subcategory/tracks', queryParameters: {'limit': limit.toString()});
      return (res.data as List).map((e) => AudioTrack.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getBucketFolders(String bucket) async {
    try {
      final res = await _api.get('/audio/bucket/$bucket/folders');
      return res.data as List;
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getFilesInFolder(String bucket, String folder) async {
    try {
      final res = await _api.get('/audio/folder/$folder/files', queryParameters: {'bucket': bucket});
      return res.data as List;
    } catch (_) {
      return [];
    }
  }

  Future<AudioTrack?> getTrack(String id) async {
    try {
      final res = await _api.get('/audio/tracks/$id');
      return AudioTrack.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  Future<List<AudioTrack>> getRecommended() async {
    try {
      final res = await _api.get('/audio/recommended');
      return (res.data as List).map((e) => AudioTrack.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<UserAudioHistory>> getHistory({int limit = 20}) async {
    try {
      final res = await _api.get('/audio/history', queryParameters: {'limit': limit.toString()});
      return (res.data as List).map((e) => UserAudioHistory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<UserAudioHistory>> getFavorites() async {
    try {
      final res = await _api.get('/audio/favorites');
      return (res.data as List).map((e) => UserAudioHistory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<DownloadedAudioTrack>> getDownloads() async {
    try {
      final res = await _api.get('/audio/downloads');
      return (res.data as List).map((e) => DownloadedAudioTrack.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markPlayed(String trackId, {int? progress}) async {
    try {
      await _api.post('/audio/play/$trackId', data: {
        if (progress != null) 'progress': progress,
      });
    } catch (_) {}
  }

  Future<bool> toggleFavorite(String trackId) async {
    try {
      final res = await _api.post('/audio/favorite/$trackId');
      return res.data['isFavorite'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> registerDownload(String trackId, {required String localPath, int? fileSize}) async {
    try {
      await _api.post('/audio/download/$trackId', data: {
        'localPath': localPath,
        if (fileSize != null) 'fileSize': fileSize,
      });
    } catch (_) {}
  }
}
