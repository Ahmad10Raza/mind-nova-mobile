import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_sound.dart';
import '../models/audio_telemetry.dart';

class AudioRepository {
  final SharedPreferences _prefs;

  AudioRepository(this._prefs);

  // MOCK DATA FOR PROTOTYPING
  // In production, fetch from backend
  List<SleepSound> getFeaturedSounds() {
    return [
      SleepSound.create(
        title: 'Cosmic Drift',
        audioUrl: 'audio/space_ambience.mp3',
        durationSeconds: 1200,
        themeType: ThemeType.space,
        moodTags: ['Deep Sleep', 'Focus'],
      ),
      SleepSound.create(
        title: 'Deep Forest Night',
        audioUrl: 'audio/indian_flute.mp3',
        durationSeconds: 3600,
        themeType: ThemeType.none,
        moodTags: ['Anxiety Relief', 'Emotional Recovery'],
      ),
      SleepSound.create(
        title: 'Coherent Bells',
        audioUrl: 'audio/coherent_bells.mp3',
        durationSeconds: 600,
        themeType: ThemeType.none,
        moodTags: ['Panic Relief', 'Soft Energy'],
      ),
    ];
  }

  // Caching Layer
  Future<void> saveTelemetry(AudioTelemetry telemetry) async {
    final key = 'telemetry_${telemetry.soundId}';
    await _prefs.setString(key, json.encode(telemetry.toJson()));
  }

  AudioTelemetry? getTelemetry(String soundId) {
    final key = 'telemetry_$soundId';
    final dataString = _prefs.getString(key);
    if (dataString != null) {
      try {
        return AudioTelemetry.fromJson(json.decode(dataString));
      } catch (_) {}
    }
    return null;
  }

  List<AudioTelemetry> getAllFavorites() {
    final keys = _prefs.getKeys().where((k) => k.startsWith('telemetry_'));
    final List<AudioTelemetry> favs = [];
    for (var key in keys) {
      final str = _prefs.getString(key);
      if (str != null) {
        final t = AudioTelemetry.fromJson(json.decode(str));
        if (t.isFavorited) favs.add(t);
      }
    }
    return favs;
  }
}
