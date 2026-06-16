import 'dart:convert';

void main() {
  final jsonString = '''{
    "data": [
      {
        "id": "6a31a591f612d1b05c6beca5",
        "moodName": "Stressed",
        "category": "negative",
        "intensity": "strong",
        "tags": [
          "Stressed"
        ],
        "notes": "Just working to to much from morning to knight not know what to do?",
        "aiSafetyFlag": false,
        "followUpAnswers": [],
        "createdAt": "2026-06-16T19:35:45.828Z",
        "emoji": "😫",
        "color": "#8B5CF6"
      }
    ],
    "total": 1,
    "page": 1,
    "limit": 2,
    "hasMore": false
  }''';

  final json = jsonDecode(jsonString);
  
  try {
    final entry = json['data'][0];
    final tags = List<String>.from(entry['tags'] ?? []);
    print('tags: \$tags');
    final followUps = List<Map<String, dynamic>>.from(entry['followUpAnswers'] ?? []);
    print('followUps: \$followUps');
    final dt = DateTime.parse(entry['createdAt']);
    print('dt: \$dt');
    print('SUCCESS');
  } catch (e, stack) {
    print('ERROR: \$e\\n\$stack');
  }
}
