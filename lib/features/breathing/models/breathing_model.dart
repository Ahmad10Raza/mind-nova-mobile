enum BreathingPhase { inhale, holdIn, exhale, holdOut }

class BreathingTechnique {
  final String id;
  final String name;
  final String description;
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final int? targetCycles;
  final String? soundAsset;

  BreathingTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.inhale,
    this.holdIn = 0,
    required this.exhale,
    this.holdOut = 0,
    this.targetCycles,
    this.soundAsset,
  });

  int get totalDuration => inhale + holdIn + exhale + holdOut;

  static List<BreathingTechnique> defaults = [
    BreathingTechnique(
      id: 'box',
      name: 'Box Breathing',
      description: 'Equal intervals for focus and stress clearing.',
      inhale: 4,
      holdIn: 4,
      exhale: 4,
      holdOut: 4,
    ),
    BreathingTechnique(
      id: '478',
      name: '4-7-8 Relax',
      description: 'Used for immediate anxiety relief and falling asleep.',
      inhale: 4,
      holdIn: 7,
      exhale: 8,
    ),
    BreathingTechnique(
      id: 'calm',
      name: 'Calm Breathing',
      description: 'Simple 4-6 rhythm to slow down the nervous system.',
      inhale: 4,
      exhale: 6,
    ),
  ];
}
