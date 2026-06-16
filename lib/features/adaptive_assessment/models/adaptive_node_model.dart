class AdaptiveNodeModel {
  final String questionId;
  final String category;
  final String text;
  final String type;
  final List<dynamic> options;
  final bool crisisFlag;
  
  AdaptiveNodeModel({
    required this.questionId,
    required this.category,
    required this.text,
    required this.type,
    required this.options,
    required this.crisisFlag,
  });

  factory AdaptiveNodeModel.fromJson(Map<String, dynamic> json) {
    return AdaptiveNodeModel(
      questionId: json['questionId'] ?? '',
      category: json['category'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      options: json['options'] ?? [],
      crisisFlag: json['crisisFlag'] ?? false,
    );
  }
}
