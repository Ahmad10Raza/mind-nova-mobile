import 'dart:convert';

class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final profile = json['profile'] ?? json;
    
    return UserProfile(
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      firstName: profile['firstName'],
      lastName: profile['lastName'],
      avatarUrl: profile['avatarUrl'],
    );
  }
}

void main() {
  final jsonString = '{"id":"97446455-e456-4748-b35c-d71f840d8f63","userId":"f0d0f16e-cfd9-4c32-b9b2-ae1d0e2f54cb","firstName":"Dr. Sarah Jenkins","lastName":"","avatarUrl":"https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300&h=300","onboarding":true,"goals":[]}';
  try {
    final jsonMap = jsonDecode(jsonString);
    final userProfile = UserProfile.fromJson(jsonMap);
    print('SUCCESS: ${userProfile.firstName}');
  } catch (e, stack) {
    print('ERROR: $e');
    print(stack);
  }
}
