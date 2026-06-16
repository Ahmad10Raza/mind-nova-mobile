import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // Watch auth provider so this provider invalidates on logout
  final authState = ref.watch(authProvider);
  
  if (authState.status != AuthStatus.authenticated && authState.status != AuthStatus.anonymous) {
    return null; // Don't fetch profile for unauthenticated users
  }

  final service = ref.watch(profileServiceProvider);
  
  UserProfile? profile;
  try {
    profile = await service.getProfile();
  } catch (e) {
    // Backend might be down, especially in local dev with connections refused
    profile = null;
  }
  
  // If guest, fetch data strictly from local SharedPreferences
  if (authState.status == AuthStatus.anonymous) {
    final prefs = await SharedPreferences.getInstance();
    final guestId = prefs.getString('guest_uuid') ?? 'guest_fallback_id';
    
    return UserProfile(
      id: guestId,
      email: 'guest@mindnova.local',
      firstName: prefs.getString('guest_first_name') ?? 'Guest',
      lastName: prefs.getString('guest_last_name') ?? '',
      ageRange: prefs.getString('guest_age_range'),
      gender: prefs.getString('guest_gender'),
      goals: prefs.getStringList('guest_goals') ?? [],
      weight: prefs.getDouble('guest_weight'),
      height: prefs.getDouble('guest_height'),
    );
  }
  
  return profile;
});
