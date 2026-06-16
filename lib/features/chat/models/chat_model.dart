class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      isUser: json['role'] == 'user',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
