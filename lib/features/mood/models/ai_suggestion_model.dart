class AiSuggestion {
  final String title;
  final String description;
  final String type;
  final String? routeDest;

  AiSuggestion({
    required this.title,
    required this.description,
    required this.type,
    this.routeDest,
  });

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'reflection_prompt',
      routeDest: json['routeDest'],
    );
  }
}
