class CommunityRoom {
  final String id;
  final String title;
  final String category;
  final String hostType; // THERAPIST, PEER, AI, MODERATOR
  final String hostName;
  final bool isLive;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int maxParticipants;
  final bool isRecurring;
  final int participantCount;
  final String? hostImageUrl;

  CommunityRoom({
    required this.id,
    required this.title,
    required this.category,
    required this.hostType,
    required this.hostName,
    required this.isLive,
    required this.startsAt,
    this.endsAt,
    this.maxParticipants = 50,
    this.isRecurring = false,
    this.participantCount = 0,
    this.hostImageUrl,
  });

  /// Derive a display status from the isLive flag and startsAt time
  String get status {
    if (isLive) return 'LIVE';
    if (startsAt.isAfter(DateTime.now())) return 'SCHEDULED';
    return 'ENDED';
  }

  factory CommunityRoom.fromJson(Map<String, dynamic> json) {
    return CommunityRoom(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      hostType: json['hostType'] ?? 'PEER',
      hostName: json['hostName'] ?? 'Community Host',
      isLive: json['isLive'] ?? false,
      startsAt: json['startsAt'] != null ? DateTime.parse(json['startsAt']) : DateTime.now(),
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
      maxParticipants: json['maxParticipants'] ?? 50,
      isRecurring: json['isRecurring'] ?? false,
      participantCount: json['_count']?['participants'] ?? 0,
      hostImageUrl: json['hostImageUrl'],
    );
  }
}
