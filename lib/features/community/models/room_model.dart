class CommunityRoom {
  final String id;
  final String title;
  final String category;
  final String hostType; // THERAPIST, MODERATOR, PEER, AI
  final String hostName;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool isLive;
  final int maxParticipants;
  final bool isRecurring;
  final int currentParticipantsCount;

  CommunityRoom({
    required this.id,
    required this.title,
    required this.category,
    required this.hostType,
    required this.hostName,
    required this.startsAt,
    this.endsAt,
    required this.isLive,
    required this.maxParticipants,
    required this.isRecurring,
    this.currentParticipantsCount = 0,
  });

  factory CommunityRoom.fromJson(Map<String, dynamic> json) {
    return CommunityRoom(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      hostType: json['hostType'],
      hostName: json['hostName'],
      startsAt: DateTime.parse(json['startsAt']),
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
      isLive: json['isLive'],
      maxParticipants: json['maxParticipants'],
      isRecurring: json['isRecurring'],
      currentParticipantsCount: json['_count']?['participants'] ?? 0,
    );
  }
}
