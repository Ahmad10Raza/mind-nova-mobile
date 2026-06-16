import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../../../core/utils/storage_manager.dart';
import '../../../core/network/api_client.dart';
import '../../profile/providers/profile_provider.dart';
import '../../assessment/providers/assessment_history_provider.dart';
import '../../mood/providers/analytics_provider.dart';

enum AuthStatus {
  unauthenticated,
  authenticated,
  anonymous,
  initial,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? role;
  final bool profileCompleted;
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId;
  final String? avatarUrl;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.displayName,
    this.role,
    this.profileCompleted = false,
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
    this.avatarUrl,
  });

  bool get hasTherapistProfile => role != null && role!.toUpperCase() == 'THERAPIST';

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    String? role,
    bool? profileCompleted,
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
    String? avatarUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Provide AuthService as a singleton
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

class AuthNotifier extends Notifier<AuthState> {
  static const String _mockAccessToken = 
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4MzUzZTU1Zi1mYjk0LTQ2ZTYtODljNy1mMDk2OGYzNmNlNTMiLCJlbWFpbCI6Im1vY2t1c2VyQGV4YW1wbGUuY29tIiwicm9sZSI6IlVTRVIiLCJpYXQiOjE3NzU4NTIwMDksImV4cCI6MTgwNzM4ODAwOX0.sZVRvzmnEwH80f9M5zO_ocumBqfCIc8qsXAANvipLw0";

  @override
  AuthState build() {
    _loadSession();
    return AuthState(status: AuthStatus.initial);
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> refreshProfile() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final profileService = ref.read(profileServiceProvider);
      final profile = await profileService.getProfile();
      if (profile != null) {
        final prefs = await SharedPreferences.getInstance();
        String fullName = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
        if (fullName.isNotEmpty) {
          await prefs.setString('userName', fullName);
          if (profile.avatarUrl != null) {
            await prefs.setString('userAvatar', profile.avatarUrl!);
          }
          state = state.copyWith(
            displayName: fullName, 
            avatarUrl: profile.avatarUrl,
            isLoading: false
          );
          return;
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final bool isAnon = prefs.getBool('isAnonymous') ?? false;
      final String? token = prefs.getString('access_token');
      final bool profileDone = prefs.getBool('profileCompleted') ?? false;
      final String? savedUserId = prefs.getString('userId');
      final String? guestUuid = prefs.getString('guest_uuid');

      // Guest session takes absolute priority if the flag is set.
      if (isAnon && guestUuid != null) {
        state = state.copyWith(
          status: AuthStatus.anonymous, 
          userId: guestUuid,
          displayName: prefs.getString('userName') ?? 'Guest',
          profileCompleted: profileDone,
        );
        return;
      }

      // Only enter authenticated state if we have a token AND a saved user ID
      if (token != null && savedUserId != null) {
        // Ensure refresh_token is also present for robust sessions
        final String? refreshToken = prefs.getString('refresh_token');
        if (refreshToken == null) {
          // If RT is missing but AT exists, we might be in an inconsistent state
          // For now, we proceed but RT will be needed for rotation
        }

        String? savedName = prefs.getString('userName');
        
        // If name is missing or the default 'Mock User', try to fetch from profile
        if (savedName == null || savedName == 'Mock User') {
          final profileService = ref.read(profileServiceProvider);
          final profile = await profileService.getProfile();
          if (profile != null) {
            String fullName = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
            if (fullName.isNotEmpty) {
              savedName = fullName;
              await prefs.setString('userName', savedName);
            }
          }
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: savedUserId,
          email: prefs.getString('userEmail') ?? 'user@example.com',
          displayName: savedName ?? 'Friend',
          profileCompleted: profileDone,
          role: prefs.getString('userRole'),
          avatarUrl: prefs.getString('userAvatar'),
        );

        // Always trigger a fresh profile fetch in background to ensure consistency
        refreshProfile();
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _saveSession({
    required String userId,
    String? email,
    String? displayName,
    bool? profileCompleted,
    String? accessToken,
    String? refreshToken,
    String? role,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Use genuine token if provided, fallback to mock only for development testing
    final tokenToSave = accessToken ?? _mockAccessToken;
    await prefs.setString('access_token', tokenToSave);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    await prefs.setString('userId', userId);
    if (email != null) await prefs.setString('userEmail', email); else await prefs.remove('userEmail');
    if (displayName != null) await prefs.setString('userName', displayName); else await prefs.remove('userName');
    if (avatarUrl != null) await prefs.setString('userAvatar', avatarUrl); else await prefs.remove('userAvatar');
    if (role != null) await prefs.setString('userRole', role); else await prefs.remove('userRole');
    await prefs.setBool('profileCompleted', profileCompleted ?? false);
    
    if (role != null) await prefs.setString('userRole', role);
    
    // Set anonymous flag correctly based on context
    await prefs.setBool('isAnonymous', email == null && displayName == 'Guest');
  }

  // ─── Google Sign-In ──────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.signInWithGoogle();

    if (result.success) {
      await _saveSession(
        userId: result.userId!,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: result.role,
        avatarUrl: result.avatarUrl,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted ?? false,
        role: result.role,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  // ─── Email/Password Login ────────────────────────────────────────

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.loginWithEmail(email: email, password: password);

    if (result.success) {
      await _saveSession(
        userId: result.userId!,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: result.role,
        avatarUrl: result.avatarUrl,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted ?? false,
        role: result.role,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  // ─── Forgot Password ─────────────────────────────────────────────

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
        );
      },
      verificationFailed: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.message ?? 'Phone verification failed.',
        );
      },
    );
  }

  Future<void> signInWithPhoneNumber(String smsCode) async {
    if (state.verificationId == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.signInWithPhoneNumber(
      state.verificationId!,
      smsCode,
    );

    if (result.success) {
      await _saveSession(
        userId: result.userId!,
        email: result.email,
        displayName: 'User', // Fallback
        profileCompleted: result.profileCompleted,
        avatarUrl: result.avatarUrl,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: 'User',
        profileCompleted: result.profileCompleted ?? false,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  // ─── Email/Password Registration ─────────────────────────────────

  Future<void> registerWithEmail(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: name,
    );

    if (result.success) {
      // MVP: Registration now returns tokens directly, treat like login
      await _saveSession(
        userId: result.userId!,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: result.role,
        avatarUrl: result.avatarUrl,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted ?? false,
        role: result.role,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.verifyEmailOtp(
      email: email,
      otp: otp,
    );

    if (result.success) {
      await _saveSession(
        userId: result.userId!,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: result.role,
        avatarUrl: result.avatarUrl,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted ?? false,
        role: result.role,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }

  Future<void> resendOtp(String identifier) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.resendEmailOtp(identifier);
    state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.forgotPassword(email);
    state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    return result.success;
  }

  Future<bool> verifyPasswordResetOtp(String email, String otp, String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _authService.verifyPasswordResetOtp(email, otp, newPassword);
    state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    return result.success;
  }

  // ─── Guest Upgrade ───────────────────────────────────────────────

  Future<AuthResult> upgradeAccount(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final prefs = await SharedPreferences.getInstance();
    final String? guestId = prefs.getString('guest_uuid');
    
    if (guestId == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'No active guest session found.');
      return AuthResult(success: false, errorMessage: 'No active guest session found.');
    }

    // Call the backend service to perform the conversion
    final result = await _authService.upgradeGuestToUser(
      guestId: guestId,
      email: email,
      password: password,
      displayName: prefs.getString('userName'),
    );

    if (result.success) {
      // Step 1: Migrate local keys to the new User ID (in a real app, also migrate local DBs here)
      await _saveSession( // Saves the new access_token, userId, etc.
        userId: result.userId!,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        role: result.role,
        avatarUrl: result.avatarUrl,
      );
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: result.userId,
        email: result.email,
        displayName: result.displayName,
        profileCompleted: result.profileCompleted ?? false,
        role: result.role,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
    
    return result;
  }

  // ─── Anonymous Login ─────────────────────────────────────────────

  Future<void> loginAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // COMPLETELY clear any previous local session to guarantee isolation
    await StorageManager.clearAllUserData().timeout(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Generate a unique local identity for the guest session if none exists
    final String deviceId = const Uuid().v4();
    
    // Request a session from the backend
    final result = await _authService.loginAnonymously(deviceId: deviceId);
    
    if (result.success) {
      await _saveSession(
        userId: result.userId!,
        email: null,
        displayName: 'Guest',
        profileCompleted: false,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        avatarUrl: result.avatarUrl,
      );
      
      state = state.copyWith(
        status: AuthStatus.anonymous,
        userId: result.userId,
        displayName: 'Guest',
        profileCompleted: false,
        avatarUrl: result.avatarUrl,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
        status: AuthStatus.unauthenticated,
      );
    }
  }

  // ─── Update Guest Profile ────────────────────────────────────────

  Future<void> updateGuestProfile({
    String? firstName,
    String? lastName,
    String? ageRange,
    String? gender,
    List<String>? goals,
    double? weight,
    double? height,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (firstName != null) await prefs.setString('guest_first_name', firstName);
    if (lastName != null) await prefs.setString('guest_last_name', lastName);
    if (ageRange != null) await prefs.setString('guest_age_range', ageRange);
    if (gender != null) await prefs.setString('guest_gender', gender);
    if (goals != null) await prefs.setStringList('guest_goals', goals);
    if (weight != null) await prefs.setDouble('guest_weight', weight);
    if (height != null) await prefs.setDouble('guest_height', height);
    
    String fullName = '${firstName ?? prefs.getString('guest_first_name') ?? ''} ${lastName ?? prefs.getString('guest_last_name') ?? ''}'.trim();
    if (fullName.isNotEmpty) {
      await updateDisplayName(fullName);
    }
  }

  // ─── Mark Profile Completed ──────────────────────────────────────

  Future<void> markProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileCompleted', true);
    state = state.copyWith(profileCompleted: true);
  }

  // ─── Update Display Name ─────────────────────────────────────────
  
  Future<void> updateDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    state = state.copyWith(displayName: name);
  }

  Future<void> updateUserAvatar(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAvatar', avatarUrl);
    state = state.copyWith(avatarUrl: avatarUrl);
  }

  // ─── Logout ──────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authService.signOut();
      await StorageManager.clearAllUserData().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
