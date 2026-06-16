import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_constants.dart';

class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? ageRange;
  final String? gender;
  final List<String> goals;
  final double? baselineStress;
  final double? baselineSleep;
  final double? baselineMood;
  final String? avatarUrl;
  final double? weight;
  final double? height;

  UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.ageRange,
    this.gender,
    this.avatarUrl,
    this.goals = const [],
    this.baselineStress,
    this.baselineSleep,
    this.baselineMood,
    this.weight,
    this.height,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final profile = json['profile'] ?? json;
    
    return UserProfile(
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      firstName: profile['firstName'],
      lastName: profile['lastName'],
      ageRange: profile['ageRange'],
      gender: profile['gender'],
      avatarUrl: parseAvatarUrl(profile['avatarUrl']),
      goals: (profile['goals'] as List?)?.map((e) => e.toString()).toList() ?? [],
      baselineStress: (profile['baselineStress'] as num?)?.toDouble(),
      baselineSleep: (profile['baselineSleep'] as num?)?.toDouble(),
      baselineMood: (profile['baselineMood'] as num?)?.toDouble(),
      weight: (profile['weight'] as num?)?.toDouble(),
      height: (profile['height'] as num?)?.toDouble(),
    );
  }

  static String? parseAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    // Remove leading slash if present to avoid double slashes
    final path = url.startsWith('/') ? url.substring(1) : url;
    return '${NetworkConstants.baseUrl}/$path';
  }
}

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserProfile?> getProfile() async {
    try {
      final response = await _apiClient.get('/users/profile');
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Get Profile Error: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? ageRange,
    String? gender,
    List<String>? goals,
    double? baselineStress,
    double? baselineSleep,
    double? baselineMood,
    double? weight,
    double? height,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.patch('/users/profile', data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (ageRange != null) 'ageRange': ageRange,
        if (gender != null) 'gender': gender,
        if (goals != null && goals.isNotEmpty) 'goals': goals,
        if (baselineStress != null) 'baselineStress': baselineStress,
        if (baselineSleep != null) 'baselineSleep': baselineSleep,
        if (baselineMood != null) 'baselineMood': baselineMood,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Profile Update Error: $e');
      return false;
    }
  }

  Future<String?> uploadAvatar(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _apiClient.post(
        '/users/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['avatarUrl'];
      }
      return null;
    } catch (e) {
      print('Avatar Upload Error: $e');
      return null;
    }
  }
}

// Provider for ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProfileService(api);
});
