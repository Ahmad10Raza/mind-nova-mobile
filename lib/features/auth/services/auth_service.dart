import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'profile_service.dart';

/// Result wrapper for authentication operations.
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;
  final bool? profileCompleted;
  final String? accessToken;
  final String? refreshToken;
  final String? role;
  final String? avatarUrl;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
    this.profileCompleted,
    this.accessToken,
    this.refreshToken,
    this.role,
    this.avatarUrl,
  });
}

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // Unified Mock Auth (Linux/Windows/Chrome development)
  // Set to false for production-ready real-time authentication
  bool get _useMock => false;

  FirebaseAuth? get _firebaseAuth {
    if (_useMock) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get the currently signed-in user, if any.
  User? get currentUser => _useMock ? null : _firebaseAuth?.currentUser;

  /// Listen to authentication state changes.
  Stream<User?> get authStateChanges {
    if (_useMock) return const Stream.empty();
    return _firebaseAuth!.authStateChanges();
  }

  /// Initialize Google Sign-In. Call once at app startup.
  Future<void> initializeGoogleSignIn() async {
    if (_useMock) return;
    await GoogleSignIn.instance.initialize();
  }

  // ─── Google Sign-In (v7 API) ──────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return AuthResult(
        success: true,
        userId: 'mock_google_id',
        email: 'mockuser@example.com',
        displayName: null,
      );
    }
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // Get the idToken from the authentication data
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth!.signInWithCredential(credential);
      final User? user = userCredential.user;

      return AuthResult(
        success: true,
        userId: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message ?? 'Google sign-in failed.');
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Email/Password Registration ──────────────────────────────

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
        'firstName': displayName?.split(' ').first,
        'lastName': displayName?.split(' ').skip(1).join(' '),
      });

      // MVP: Backend now returns user + tokens directly (no OTP step)
      final user = response.data['user'];
      final profile = user?['profile'];
      final therapistData = user?['therapistData'];
      final role = user?['role'];

      String? fullName;
      if (role == 'THERAPIST' && therapistData != null) {
        fullName = therapistData['name'];
      } else if (profile != null) {
        final fName = profile['firstName'] ?? '';
        final lName = profile['lastName'] ?? '';
        fullName = '$fName $lName'.trim();
        if (fullName.isEmpty) fullName = displayName;
      } else {
        fullName = displayName;
      }

      String? avatarUrl;
      if (role == 'THERAPIST' && therapistData != null) {
        avatarUrl = UserProfile.parseAvatarUrl(therapistData['imageUrl']);
      } else {
        avatarUrl = UserProfile.parseAvatarUrl(profile?['avatarUrl']);
      }

      return AuthResult(
        success: true,
        userId: user?['id'],
        email: user?['email'] ?? email,
        displayName: fullName,
        profileCompleted: profile?['onboarding'] ?? false,
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        role: role,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  Future<AuthResult> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post('/auth/verify-email', data: {
        'email': email,
        'otp': otp,
      });

      return AuthResult(
        success: true,
        userId: response.data['userId'],
        email: response.data['email'],
        displayName: response.data['displayName'],
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
        role: response.data['role'],
        profileCompleted: response.data['profileCompleted'] ?? false,
        avatarUrl: UserProfile.parseAvatarUrl(response.data['avatarUrl']),
      );
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  Future<AuthResult> resendEmailOtp(String email) async {
    try {
      await _apiClient.post('/auth/resend-otp', data: {'email': email});
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {'email': email});
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> verifyPasswordResetOtp(String email, String otp, String newPassword) async {
    try {
      await _apiClient.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'password': newPassword,
      });
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  // ─── Email/Password Login ─────────────────────────────────────

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      String? fullName;
      final profile = response.data['user']['profile'];
      final therapistProfile = response.data['user']['therapistData'];
      final role = response.data['user']['role'];
      
      if (role == 'THERAPIST' && therapistProfile != null) {
        fullName = therapistProfile['name'];
      } else if (profile != null) {
        final fName = profile['firstName'] ?? '';
        final lName = profile['lastName'] ?? '';
        fullName = '$fName $lName'.trim();
        if (fullName.isEmpty) fullName = null;
      }
      
      String? avatarUrl;
      if (role == 'THERAPIST' && therapistProfile != null) {
        avatarUrl = UserProfile.parseAvatarUrl(therapistProfile['imageUrl']);
      } else {
        avatarUrl = UserProfile.parseAvatarUrl(profile?['avatarUrl']);
      }

      return AuthResult(
        success: true,
        userId: response.data['user']['id'],
        email: response.data['user']['email'],
        displayName: fullName,
        profileCompleted: profile?['onboarding'] ?? false,
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        role: response.data['user']['role'],
        avatarUrl: avatarUrl,
      );
    } on DioException catch (e) {
      String errorMessage = 'Login failed.';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'].toString() ?? errorMessage;
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Phone Authentication ───────────────────────────────────────

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      // Use the phone number as the verification ID so we can use it for ID generation
      codeSent(phoneNumber, null);
      return;
    }

    await _firebaseAuth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (not always triggered)
        await _firebaseAuth!.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<AuthResult> signInWithPhoneNumber(
      String verificationId, String smsCode) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      if (smsCode == '123456') {
        // Generate a dynamic mock ID based on the phone number (verificationId)
        final cleanId = verificationId.replaceAll(RegExp(r'[^0-9]'), '');
        return AuthResult(success: true, userId: 'mock_user_$cleanId');
      }
      return AuthResult(success: false, errorMessage: 'Invalid verification code.');
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final UserCredential userCredential =
          await _firebaseAuth!.signInWithCredential(credential);
      
      final user = userCredential.user;
      if (user == null) return AuthResult(success: false, errorMessage: 'User not found after sign-in.');

      // ─── Production Step: Sync with Backend ────────────────────────
      final String? idToken = await user.getIdToken();
      if (idToken == null) return AuthResult(success: false, errorMessage: 'Failed to retrieve Firebase token.');

      final response = await _apiClient.post(
        '/auth/firebase',
        data: {
          'token': idToken,
          'phoneNumber': user.phoneNumber,
        },
      );

      return AuthResult(
        success: true,
        userId: response.data['user']['id'],
        email: response.data['user']['email'],
        displayName: response.data['user']['profile']?['firstName'],
        profileCompleted: response.data['user']['profile']?['onboarding'],
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        role: response.data['user']['role'],
        avatarUrl: UserProfile.parseAvatarUrl(response.data['user']['profile']?['avatarUrl']),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } on DioException catch (e) {
      return AuthResult(
        success: false, 
        errorMessage: e.response?.data?['message']?.toString() ?? 'Backend synchronization failed.'
      );
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Email Verification ─────────────────────────────────────────

  Future<AuthResult> sendEmailVerification() async {
    if (_useMock) return AuthResult(success: true);
    try {
      final user = _firebaseAuth?.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return AuthResult(success: true);
      }
      return AuthResult(success: false, errorMessage: 'No user found or already verified.');
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Guest Upgrade ───────────────────────────────────────────────

  Future<AuthResult> upgradeGuestToUser({
    required String guestId,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/upgrade',
        data: {
          'email': email,
          'password': password,
          'guestUuid': guestId,
          'firstName': displayName ?? 'User',
        },
      );

      return AuthResult(
        success: true,
        userId: response.data['user']['id'],
        email: response.data['user']['email'],
        displayName: response.data['user']['profile']?['firstName'],
        profileCompleted: response.data['user']['profile']?['onboarding'],
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        role: response.data['user']['role'],
        avatarUrl: UserProfile.parseAvatarUrl(response.data['user']['profile']?['avatarUrl']),
      );
    } on DioException catch (e) {
      String errorMessage = 'Upgrade failed. Please try again.';
      if (e.response?.statusCode == 409) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'].toString() ?? errorMessage;
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Anonymous Login ──────────────────────────────────────────

  Future<AuthResult> loginAnonymously({required String deviceId}) async {
    try {
      final response = await _apiClient.post(
        '/auth/anonymous-session',
        data: {'deviceId': deviceId},
      );

      return AuthResult(
        success: true,
        userId: response.data['user']['id'],
        displayName: 'Guest',
        profileCompleted: false,
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        role: response.data['user']['role'],
        avatarUrl: UserProfile.parseAvatarUrl(response.data['user']['profile']?['avatarUrl']),
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false, 
        errorMessage: e.response?.data?['message'] ?? 'Guest login failed.'
      );
    } catch (e) {
      String errorMessage = 'Action failed.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = 'An account with this email already exists.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code.';
        } else if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'].toString() ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      return AuthResult(success: false, errorMessage: errorMessage);
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────

  Future<void> signOut() async {
    if (_useMock) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
  }
}
