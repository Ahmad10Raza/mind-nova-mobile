class CommunityInsight {
  final int totalPostsToday;
  final int totalInteractionsToday;
  final int activeMembers;
  final Map<String, int> emotionBreakdown;

  CommunityInsight({
    required this.totalPostsToday,
    this.totalInteractionsToday = 0,
    this.activeMembers = 0,
    required this.emotionBreakdown,
  });

  factory CommunityInsight.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['emotionBreakdown'] as List<dynamic>? ?? [];
    final Map<String, int> breakdown = {};
    for (var item in rawBreakdown) {
      if (item is Map) {
        breakdown[item['emotion'] ?? 'UNKNOWN'] = item['count'] ?? 0;
      }
    }

    return CommunityInsight(
      totalPostsToday: json['totalPostsToday'] ?? 0,
      totalInteractionsToday: json['totalInteractionsToday'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      emotionBreakdown: breakdown,
    );
  }
}
