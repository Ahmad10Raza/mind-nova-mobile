import 'package:uuid/uuid.dart';

enum ThemeType { rain, space, fire, none }

class SleepSound {
  final String id;
  final String title;
  final String audioUrl;
  final String? artworkUrl;
  final int durationSeconds;
  final ThemeType themeType;
  final List<String> moodTags;
  final String? localPath;
  final bool isPremium;

  const SleepSound({
    required this.id,
    required this.title,
    required this.audioUrl,
    this.artworkUrl,
    required this.durationSeconds,
    this.themeType = ThemeType.none,
    this.moodTags = const [],
    this.localPath,
    this.isPremium = false,
  });

  factory SleepSound.create({
    required String title,
    required String audioUrl,
    String? artworkUrl,
    required int durationSeconds,
    ThemeType themeType = ThemeType.none,
    List<String> moodTags = const [],
    bool isPremium = false,
  }) {
    return SleepSound(
      id: const Uuid().v4(),
      title: title,
      audioUrl: audioUrl,
      artworkUrl: artworkUrl,
      durationSeconds: durationSeconds,
      themeType: themeType,
      moodTags: moodTags,
      isPremium: isPremium,
    );
  }

  SleepSound copyWith({
    String? id,
    String? title,
    String? audioUrl,
    String? artworkUrl,
    int? durationSeconds,
    ThemeType? themeType,
    List<String>? moodTags,
    String? localPath,
    bool? isPremium,
  }) {
    return SleepSound(
      id: id ?? this.id,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      themeType: themeType ?? this.themeType,
      moodTags: moodTags ?? this.moodTags,
      localPath: localPath ?? this.localPath,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
