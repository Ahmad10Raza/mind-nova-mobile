class MoodQuestion {
  final String id;
  final String text;

  MoodQuestion({
    required this.id,
    required this.text,
  });

  factory MoodQuestion.fromJson(Map<String, dynamic> json) {
    return MoodQuestion(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
