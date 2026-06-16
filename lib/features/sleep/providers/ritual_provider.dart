import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/audio_category.dart';

class RitualNotifier extends Notifier<List<PlaylistItem>> {
  @override
  List<PlaylistItem> build() => _defaultRitual;

  static final List<PlaylistItem> _defaultRitual = [
    PlaylistItem(
      id: const Uuid().v4(),
      title: 'Moon Breathing',
      isAudioTrack: false,
      interstitialType: 'breathing_timer',
    ),
    PlaylistItem(
      id: const Uuid().v4(),
      title: 'Evening Journal',
      isAudioTrack: false,
      interstitialType: 'journal_prompt',
    ),
  ];

  void addStep(String type, {required String title, String? soundId, bool isAudio = false}) {
    state = [
      ...state,
      PlaylistItem(
        id: const Uuid().v4(),
        title: title,
        isAudioTrack: isAudio,
        soundId: soundId,
        interstitialType: isAudio ? null : type,
      ),
    ];
  }

  void removeStep(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }

  void reset() {
    state = _defaultRitual;
  }
}

final ritualProvider = NotifierProvider<RitualNotifier, List<PlaylistItem>>(() {
  return RitualNotifier();
});
