// ─── Audio Track (server-side) ───────────────────────────────────────────────

class AudioTrack {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? subCategory;
  final String? bucketName;
  final String? folderName;
  final String? fileName;
  final String? artworkFile;
  final String audioUrl;
  final String? artworkUrl;
  final int? durationSeconds;
  final List<String> tags;
  final String? moodBenefit;
  final bool isPremium;
  final bool isFeatured;
  final int playCount;
  final String? recommendationReason;

  AudioTrack({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.subCategory,
    this.bucketName,
    this.folderName,
    this.fileName,
    this.artworkFile,
    required this.audioUrl,
    this.artworkUrl,
    this.durationSeconds,
    this.tags = const [],
    this.moodBenefit,
    this.isPremium = false,
    this.isFeatured = false,
    this.playCount = 0,
    this.recommendationReason,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      bucketName: json['bucketName'] as String?,
      folderName: json['folderName'] as String?,
      fileName: json['fileName'] as String?,
      artworkFile: json['artworkFile'] as String?,
      audioUrl: json['audioUrl'] as String,
      artworkUrl: json['artworkUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      moodBenefit: json['moodBenefit'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      playCount: json['playCount'] as int? ?? 0,
      recommendationReason: json['recommendationReason'] as String?,
    );
  }

  String get durationLabel {
    if (durationSeconds == null) return '—';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    if (m >= 60) return '${m ~/ 60}h ${m % 60}m';
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}

// ─── Audio Category Metadata ─────────────────────────────────────────────────

class AudioCategoryMeta {
  final String id;
  final String label;
  final String emoji;
  final String gradientStart;
  final String gradientEnd;
  final String moodBenefit;

  AudioCategoryMeta({
    required this.id,
    required this.label,
    required this.emoji,
    required this.gradientStart,
    required this.gradientEnd,
    required this.moodBenefit,
  });

  factory AudioCategoryMeta.fromJson(Map<String, dynamic> json) {
    return AudioCategoryMeta(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      gradientStart: json['gradientStart'] as String,
      gradientEnd: json['gradientEnd'] as String,
      moodBenefit: json['moodBenefit'] as String,
    );
  }
}

// ─── User Audio History ───────────────────────────────────────────────────────

class UserAudioHistory {
  final String id;
  final String userId;
  final String audioTrackId;
  final DateTime playedAt;
  final int? progress; // seconds
  final bool isFavorite;
  final AudioTrack? track;

  UserAudioHistory({
    required this.id,
    required this.userId,
    required this.audioTrackId,
    required this.playedAt,
    this.progress,
    this.isFavorite = false,
    this.track,
  });

  factory UserAudioHistory.fromJson(Map<String, dynamic> json) {
    return UserAudioHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audioTrackId: json['audioTrackId'] as String,
      playedAt: DateTime.parse(json['playedAt'] as String),
      progress: json['progress'] as int?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      track: json['track'] != null ? AudioTrack.fromJson(json['track']) : null,
    );
  }
}

// ─── Downloaded Audio Track ───────────────────────────────────────────────────

class DownloadedAudioTrack {
  final String id;
  final String userId;
  final String audioTrackId;
  final String localPath;
  final int? fileSize;
  final DateTime downloadedAt;
  final DateTime? lastPlayedAt;
  final AudioTrack? track;

  DownloadedAudioTrack({
    required this.id,
    required this.userId,
    required this.audioTrackId,
    required this.localPath,
    this.fileSize,
    required this.downloadedAt,
    this.lastPlayedAt,
    this.track,
  });

  factory DownloadedAudioTrack.fromJson(Map<String, dynamic> json) {
    return DownloadedAudioTrack(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audioTrackId: json['audioTrackId'] as String,
      localPath: json['localPath'] as String,
      fileSize: json['fileSize'] as int?,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] != null ? DateTime.parse(json['lastPlayedAt'] as String) : null,
      track: json['track'] != null ? AudioTrack.fromJson(json['track']) : null,
    );
  }

  String get fileSizeLabel {
    if (fileSize == null) return '—';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(0)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Local Audio Track (device storage) ──────────────────────────────────────

class LocalAudioTrack {
  final String id;
  final String title;
  final String? artist;
  final String? album;
  final String path;
  final Duration duration;
  final String? artworkPath;
  bool isFavorite;

  LocalAudioTrack({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    required this.path,
    required this.duration,
    this.artworkPath,
    this.isFavorite = false,
  });

  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Audio Queue ──────────────────────────────────────────────────────────────

enum AudioRepeatMode { none, one, all }

class AudioQueue {
  final List<AudioTrack> tracks;
  final int currentIndex;
  final AudioRepeatMode repeatMode;
  final bool shuffle;

  const AudioQueue({
    this.tracks = const [],
    this.currentIndex = 0,
    this.repeatMode = AudioRepeatMode.none,
    this.shuffle = false,
  });

  AudioTrack? get current => tracks.isEmpty ? null : tracks[currentIndex];

  AudioQueue copyWith({
    List<AudioTrack>? tracks,
    int? currentIndex,
    AudioRepeatMode? repeatMode,
    bool? shuffle,
  }) {
    return AudioQueue(
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffle: shuffle ?? this.shuffle,
    );
  }
}
