class AudioTelemetry {
  final String soundId;
  final bool isFavorited;
  final DateTime? lastPlayedAt;
  final int playCount;
  final bool isDownloadedLocally;
  final int savedPlaybackPositionMillis;

  const AudioTelemetry({
    required this.soundId,
    this.isFavorited = false,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isDownloadedLocally = false,
    this.savedPlaybackPositionMillis = 0,
  });

  factory AudioTelemetry.fromJson(Map<String, dynamic> json) {
    return AudioTelemetry(
      soundId: json['soundId'],
      isFavorited: json['isFavorited'] ?? false,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : null,
      playCount: json['playCount'] ?? 0,
      isDownloadedLocally: json['isDownloadedLocally'] ?? false,
      savedPlaybackPositionMillis: json['savedPlaybackPositionMillis'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundId': soundId,
      'isFavorited': isFavorited,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'playCount': playCount,
      'isDownloadedLocally': isDownloadedLocally,
      'savedPlaybackPositionMillis': savedPlaybackPositionMillis,
    };
  }

  AudioTelemetry copyWith({
    bool? isFavorited,
    DateTime? lastPlayedAt,
    int? playCount,
    bool? isDownloadedLocally,
    int? savedPlaybackPositionMillis,
  }) {
    return AudioTelemetry(
      soundId: soundId,
      isFavorited: isFavorited ?? this.isFavorited,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isDownloadedLocally: isDownloadedLocally ?? this.isDownloadedLocally,
      savedPlaybackPositionMillis: savedPlaybackPositionMillis ?? this.savedPlaybackPositionMillis,
    );
  }
}
