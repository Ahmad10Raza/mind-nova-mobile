class TherapistProfile {
  final String id;
  final String userId;
  final String name;
  final String title;
  final String specialty;
  final List<String> languages;
  final double hourlyRate;
  final double priceQuick;
  final double priceDeep;
  final double priceStudent;
  final String bio;
  final String? imageUrl;
  final List<String> styleTags;
  final bool isVerified;
  final int experienceYrs;
  final double rating;
  final String responseTime;
  final int matchScore; // Only present after matching
  final String? matchReason;

  // ─── Marketplace fields ───────────────────────────────────────
  final int sessionsCompleted;
  final String onlineStatus; // "ONLINE", "BUSY", "OFFLINE"
  final List<String> supportedModes; // ["CHAT", "VOICE", "VIDEO"]
  final List<TherapistAvailabilitySlot> availability;

  TherapistProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.title,
    required this.specialty,
    required this.languages,
    required this.hourlyRate,
    this.priceQuick = 499,
    this.priceDeep = 999,
    this.priceStudent = 299,
    required this.bio,
    this.imageUrl,
    required this.styleTags,
    required this.isVerified,
    required this.experienceYrs,
    required this.rating,
    required this.responseTime,
    this.matchScore = 0,
    this.matchReason,
    this.sessionsCompleted = 0,
    this.onlineStatus = 'OFFLINE',
    this.supportedModes = const ['CHAT', 'VOICE', 'VIDEO'],
    this.availability = const [],
  });

  factory TherapistProfile.fromJson(Map<String, dynamic> json) {
    return TherapistProfile(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Therapist',
      title: json['title'] ?? '',
      specialty: json['specialty'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      priceQuick: (json['priceQuick'] ?? 499).toDouble(),
      priceDeep: (json['priceDeep'] ?? 999).toDouble(),
      priceStudent: (json['priceStudent'] ?? 299).toDouble(),
      bio: json['bio'] ?? '',
      imageUrl: json['imageUrl'],
      styleTags: List<String>.from(json['styleTags'] ?? []),
      isVerified: json['isVerified'] ?? false,
      experienceYrs: json['experienceYrs'] ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
      responseTime: json['responseTime'] ?? 'Usually replies in a few hours',
      matchScore: json['matchScore'] ?? 0,
      matchReason: json['matchReason'],
      sessionsCompleted: json['sessionsCompleted'] ?? 0,
      onlineStatus: json['onlineStatus'] ?? 'OFFLINE',
      supportedModes: List<String>.from(json['supportedModes'] ?? ['CHAT', 'VOICE', 'VIDEO']),
      availability: (json['availability'] as List<dynamic>?)
              ?.map((e) => TherapistAvailabilitySlot.fromJson(e))
              .toList() ??
          [],
    );
  }

  TherapistProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? title,
    String? specialty,
    List<String>? languages,
    double? hourlyRate,
    double? priceQuick,
    double? priceDeep,
    double? priceStudent,
    String? bio,
    String? imageUrl,
    List<String>? styleTags,
    bool? isVerified,
    int? experienceYrs,
    double? rating,
    String? responseTime,
    int? matchScore,
    String? matchReason,
    int? sessionsCompleted,
    String? onlineStatus,
    List<String>? supportedModes,
    List<TherapistAvailabilitySlot>? availability,
  }) {
    return TherapistProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      languages: languages ?? this.languages,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      priceQuick: priceQuick ?? this.priceQuick,
      priceDeep: priceDeep ?? this.priceDeep,
      priceStudent: priceStudent ?? this.priceStudent,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      styleTags: styleTags ?? this.styleTags,
      isVerified: isVerified ?? this.isVerified,
      experienceYrs: experienceYrs ?? this.experienceYrs,
      rating: rating ?? this.rating,
      responseTime: responseTime ?? this.responseTime,
      matchScore: matchScore ?? this.matchScore,
      matchReason: matchReason ?? this.matchReason,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      supportedModes: supportedModes ?? this.supportedModes,
      availability: availability ?? this.availability,
    );
  }
}

class TherapistAvailabilitySlot {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String mode;

  TherapistAvailabilitySlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.mode = 'CHAT',
  });

  factory TherapistAvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return TherapistAvailabilitySlot(
      id: json['id'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      mode: json['mode'] ?? 'CHAT',
    );
  }
}

class MessageThread {
  final String id;
  final String userId;
  final String therapistId;
  final String? category;
  final String? subject;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TherapistProfile? therapist;
  final List<ChatMessage> messages;

  MessageThread({
    required this.id,
    required this.userId,
    required this.therapistId,
    this.category,
    this.subject,
    this.status = 'OPEN',
    required this.createdAt,
    required this.updatedAt,
    this.therapist,
    this.messages = const [],
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      therapistId: json['therapistId'] ?? '',
      category: json['category'],
      subject: json['subject'],
      status: json['status'] ?? 'OPEN',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      therapist: json['therapist'] != null
          ? TherapistProfile.fromJson(json['therapist'])
          : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ChatMessage {
  final String id;
  final String threadId;
  final String senderType; // "USER" or "THERAPIST"
  final String senderId;
  final String content;
  final String messageType; // "TEXT", "VOICE", "IMAGE", "FILE"
  final String? fileUrl;
  final int? duration;
  final String status; // "SENT", "DELIVERED", "SEEN"
  final DateTime? seenAt;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderType,
    required this.senderId,
    required this.content,
    this.messageType = 'TEXT',
    this.fileUrl,
    this.duration,
    this.status = 'SENT',
    this.seenAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      threadId: json['threadId'] ?? '',
      senderType: json['senderType'] ?? 'USER',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'TEXT',
      fileUrl: json['fileUrl'],
      duration: json['duration'],
      status: json['status'] ?? 'SENT',
      seenAt: json['seenAt'] != null ? DateTime.tryParse(json['seenAt']) : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class UserSession {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime date;
  final int durationMin;
  final String type;
  final String status;
  final String? notes;
  final String? preferredSlot;
  final String? aiSummary;
  final DateTime createdAt;
  final Map<String, dynamic>? therapist;

  UserSession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.date,
    this.durationMin = 45,
    this.type = 'VIDEO_CALL',
    this.status = 'PENDING',
    this.notes,
    this.preferredSlot,
    this.aiSummary,
    required this.createdAt,
    this.therapist,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? (json['patient'] != null ? json['patient']['id'] : ''),
      therapistId: json['therapistId'] ?? (json['therapist'] != null ? json['therapist']['id'] : ''),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      durationMin: json['durationMin'] ?? 45,
      type: json['type'] ?? 'VIDEO_CALL',
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      preferredSlot: json['preferredSlot'],
      aiSummary: json['aiSummary'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      therapist: json['therapist'],
    );
  }

  String get therapistName => therapist?['name'] ?? 'Therapist';
  String get therapistTitle => therapist?['title'] ?? '';
  String get therapistImageUrl => therapist?['imageUrl'] ?? '';
}
