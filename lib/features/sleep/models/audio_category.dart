import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class AudioCategory {
  final String id;
  final String name;
  final IconData icon;
  final String colorHex;

  const AudioCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
  });

  factory AudioCategory.create({
    required String name,
    required IconData icon,
    required String colorHex,
  }) {
    return AudioCategory(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      colorHex: colorHex,
    );
  }
}

class PlaylistItem {
  final String id;
  final String title;
  final bool isAudioTrack;
  final String? soundId;
  final String? interstitialType; // e.g., 'breathing_timer', 'journal_prompt'

  const PlaylistItem({
    required this.id,
    required this.title,
    required this.isAudioTrack,
    this.soundId,
    this.interstitialType,
  });
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final List<PlaylistItem> queue;
  final bool isNightRitual;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.queue,
    this.isNightRitual = false,
  });
}
