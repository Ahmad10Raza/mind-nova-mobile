import 'package:shared_preferences/shared_preferences.dart';
import '../../features/safety/data/crisis_local_storage.dart';

class StorageManager {
  /// Clears all sensitive user data upon logout or session switch.
  /// This completely severs the link between sessions to prevent data leakage.
  /// It preserves app preferences like theme or language by not calling prefs.clear().
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Explicitly wipe the authentication and PII keys
    await prefs.remove('access_token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userAvatar');
    await prefs.remove('userRole');
    await prefs.remove('profileCompleted');
    await prefs.remove('isAnonymous');
    await prefs.remove('guest_uuid');
    await prefs.remove('guest_first_name');
    await prefs.remove('guest_last_name');
    await prefs.remove('guest_age_range');
    await prefs.remove('guest_gender');
    await prefs.remove('guest_goals');
    await prefs.remove('guest_weight');
    await prefs.remove('guest_height');
    
    // Wipe encrypted crisis support data
    await CrisisLocalStorage().clearAll();
  }
}
