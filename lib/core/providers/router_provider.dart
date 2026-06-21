import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/mental_health_onboarding_screen.dart';

import '../../features/dashboard/presentation/home_screen.dart';
import '../../features/dashboard/presentation/ai_suggestions_screen.dart';
import '../../features/dashboard/presentation/main_shell.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/assessment/presentation/assessment_screen.dart';
import '../../features/assessment/presentation/assessment_intro_screen.dart';
import '../../features/assessment/presentation/assessment_result_screen.dart';
import '../../features/assessment/models/assessment_model.dart';
import '../../features/adaptive_assessment/presentation/adaptive_assessment_screen.dart';

import '../../features/breathing/presentation/breathing_intro_screen.dart';
import '../../features/breathing/presentation/breathing_exercise_screen.dart';
import '../../features/breathing/models/breathing_model.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/assessment_history_screen.dart';
import '../../features/ai_reports/presentation/weekly_insight_screen.dart';
import '../../features/ai_reports/presentation/weekly_history_screen.dart';
import '../../features/ai_reports/models/weekly_report_model.dart';
import '../../features/ai_reports/presentation/screens/ai_prediction_hub_screen.dart';
import '../../features/ai_reports/providers/ai_prediction_provider.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../features/notifications/presentation/notification_inbox_screen.dart';
import '../../features/scoring/presentation/cmhi_info_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/notifications/presentation/notification_settings_screen.dart';
import '../../features/safety/providers/safety_provider.dart';
import '../../features/safety/presentation/emergency_screen.dart';
import '../../features/safety/presentation/crisis_plan_screen.dart';
import '../../features/safety/presentation/crisis_hub_screen.dart';
import '../../features/safety/presentation/safe_contacts_screen.dart';
import '../../features/safety/presentation/sos_mode_screen.dart';
import '../../features/safety/presentation/recovery_success_screen.dart';
import '../../features/sleep/presentation/sleep_mode_screen.dart';
import '../../features/sleep/presentation/sleep_breathing_screen.dart';
import '../../features/sleep/presentation/sleep_tracking_screen.dart';
import '../../features/sleep/presentation/sleep_emergency_screen.dart';
import '../../features/sleep/presentation/night_routine_screen.dart';
import '../../features/sleep/presentation/sleep_sounds_dashboard.dart';
import '../../features/sleep/presentation/ritual_builder_screen.dart';
import '../../features/sleep/presentation/night_routine_screen.dart';
import '../../features/gratitude/presentation/gratitude_dashboard_screen.dart';
import '../../features/gratitude/presentation/gratitude_memory_vault_screen.dart';
import '../../features/journal/presentation/journal_dashboard_screen.dart';
import '../../features/journal/presentation/journal_editor_screen.dart';
import '../../features/journal/presentation/journal_history_screen.dart';
import '../../features/journal/models/journal_model.dart';
import '../../features/grounding/presentation/grounding_dashboard_screen.dart';
import '../../features/grounding/presentation/sensory_exercise_screen.dart';
import '../../features/grounding/presentation/panic_reset_screen.dart';
import '../../features/grounding/presentation/color_breathing_screen.dart';
import '../../features/grounding/presentation/touch_hold_screen.dart';
import '../../features/grounding/presentation/body_scan_screen.dart';
import '../../features/grounding/presentation/safe_place_screen.dart';
import '../../features/grounding/presentation/grounding_history_screen.dart';
import '../../features/meditation/presentation/meditation_dashboard_screen.dart';
import '../../features/meditation/presentation/meditation_history_screen.dart';
import '../../features/meditation/presentation/meditation_player_screen.dart';
import '../../features/meditation/presentation/meditation_explore_screen.dart';
import '../../features/meditation/domain/meditation_model.dart';
import '../../features/audio/presentation/audio_dashboard_screen.dart';
import '../../features/audio/presentation/audio_player_screen.dart';
import '../../features/audio/presentation/audio_category_screen.dart';
import '../../features/audio/domain/audio_model.dart';
import '../../features/audio/presentation/audio_history_screen.dart';
import '../../features/focus/models/focus_model.dart';
import '../../features/focus/presentation/screens/focus_timer_screen.dart';
import '../../features/focus/presentation/screens/active_focus_session_screen.dart';
import '../../features/focus/presentation/screens/focus_completion_screen.dart';

import '../../features/community_v2/presentation/community_home_screen_v2.dart';
import '../../features/community_v2/presentation/screens/live_circles_screen.dart';
import '../../features/community_v2/presentation/screens/live_room_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/groups/presentation/screens/group_onboarding_screen.dart';
import '../../features/groups/presentation/screens/group_post_detail_screen.dart';

import '../../features/recovery_v2/presentation/recovery_home_screen_v2.dart';


import '../../features/therapist_v2/presentation/therapist_home_screen_v2.dart';
import '../../features/therapist_v2/presentation/therapist_profile_screen.dart';
import '../../features/therapist_v2/presentation/therapist_session_prep_screen.dart';
import '../../features/therapist_v2/presentation/therapist_booking_screen.dart';
import '../../features/therapist_v2/presentation/therapist_chat_screen.dart';
import '../../features/therapist_v2/presentation/therapist_post_session_screen.dart';
import '../../features/therapist_v2/presentation/therapist_match_screen.dart';
import '../../features/therapist_v2/presentation/therapist_dashboard_screen.dart';
import '../../features/therapist_v2/presentation/therapist_patient_insight_screen.dart';
import '../../features/therapist_v2/presentation/therapist_notes_screen.dart';
import '../../features/therapist_v2/presentation/therapist_live_session_screen.dart';
import '../../features/therapist_v2/presentation/user_care_plan_screen.dart';
import '../../features/therapist_v2/presentation/user_messages_screen.dart';
import '../../features/therapist_v2/presentation/therapist_category_screen.dart';
import '../../features/therapist/models/therapist_model.dart';
import '../../features/habits/presentation/screens/habit_history_screen.dart';


import '../../features/habits/presentation/screens/habit_home_screen.dart';
import '../../features/habits/presentation/screens/habit_create_screen.dart';
import '../../features/challenges/presentation/screens/challenge_home_screen.dart';
import '../../features/challenges/presentation/screens/challenge_detail_screen.dart';
import '../../features/challenges/presentation/screens/active_challenge_screen.dart';

import '../../features/journeys/presentation/journeys_home_screen.dart';
import '../../features/journeys/data/journey_data.dart';
import '../../features/personalization/presentation/personalization_screens.dart';
import '../../features/mood_v2/presentation/mood_home_screen_v2.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// A bridge that notifies GoRouter when Riverpod providers update.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    _authSubscription = ref.listen(
      authProvider,
      (_, __) => notifyListeners(),
    );
    _safetySubscription = ref.listen(
      safetyProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription _authSubscription;
  late final ProviderSubscription _safetySubscription;

  @override
  void dispose() {
    _authSubscription.close();
    _safetySubscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = RouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final safetyState = ref.read(safetyProvider);
      final status = authState.status;
      final location = state.matchedLocation;

      // ─── Crisis detected (Highest Priority) ─────────────────────
      if (safetyState.crisisDetected && location != '/crisis') {
        return '/crisis';
      }

      // ─── Auth status still loading ────────────────────────────
      if (status == AuthStatus.initial) return '/splash';

      // ─── Define auth-related screens ──────────────────────────
      final bool onAuthScreen = location == '/splash' ||
          location == '/welcome' ||
          location == '/onboarding' ||
          location == '/login' ||
          location == '/signup' ||
          location == '/phone-auth' ||
          location == '/otp-verification' ||
          location == '/change-password';

      final bool onProfileSetup = location == '/mental-health-onboarding';

      // ─── Unauthenticated ──────────────────────────────────────
      if (status == AuthStatus.unauthenticated) {
        if (!onAuthScreen || location == '/splash') return '/welcome';
        return null;
      }

      // ─── Authenticated or Anonymous ───────────────────────────
      if (status == AuthStatus.authenticated || status == AuthStatus.anonymous) {
        // If on an auth screen, redirect appropriately
        if (onAuthScreen) {
          // New user who hasn't completed profile setup
          if (!authState.profileCompleted) {
            return '/mental-health-onboarding';
          }
          return '/';
        }

        // If profile not completed and NOT already on the setup screen
        if (!authState.profileCompleted && !onProfileSetup) {
          return '/mental-health-onboarding';
        }

        // ─── Therapist role guard ────────────────────────────────
        final therapistOnlyPaths = ['/therapist/panel', '/therapist/availability'];
        if (therapistOnlyPaths.any((p) => location.startsWith(p))) {
          final isTherapist = authState.userId != null && (authState.role == 'THERAPIST' || authState.hasTherapistProfile);
          if (!isTherapist) return '/therapist';
        }

        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/phone-auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpVerificationScreen(
            identifier: extra['identifier'] as String,
            isPasswordReset: extra['isPasswordReset'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ChangePasswordScreen(
            identifier: extra['identifier'] as String,
            otp: extra['otp'] as String,
          );
        },
      ),
      GoRoute(
        path: '/mental-health-onboarding',
        builder: (context, state) => const MentalHealthOnboardingScreen(),
      ),
      GoRoute(
        path: '/crisis',
        builder: (context, state) => const SosModeScreen(),
      ),
      GoRoute(
        path: '/cmhi-info',
        builder: (context, state) => const CMHIInfoScreen(),
      ),

      // ─── Community Routes ──────────────────────────────────
      GoRoute(
        path: '/community',
        builder: (context, state) => const CommunityHomeScreenV2(),
      ),
      GoRoute(
        path: '/community/live_circles',
        builder: (context, state) => const LiveCirclesScreen(),
        routes: [
          GoRoute(
            path: ':roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return LiveRoomScreen(roomId: roomId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/groups/posts/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return GroupPostDetailScreen(postId: postId);
        },
      ),
      // ─── Groups Routes ──────────────────────────────────────
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GroupDetailScreen(groupId: id);
        },
        routes: [
          GoRoute(
            path: 'onboarding',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return GroupOnboardingScreen(groupId: id);
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/ai-suggestions',
            builder: (context, state) {
              final mood = state.extra as String? ?? 'Neutral';
              return AISuggestionsScreen(mood: mood);
            },
          ),
          GoRoute(
            path: '/tools',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/gratitude',
            builder: (context, state) => const GratitudeDashboardScreen(),
            routes: [
              GoRoute(
                path: 'vault',
                builder: (context, state) => const GratitudeMemoryVaultScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const JournalDashboardScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const JournalHistoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/grounding',
            builder: (context, state) => const GroundingDashboardScreen(),
          ),
          GoRoute(
            path: '/meditation',
            builder: (context, state) => const MeditationDashboardScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const MeditationHistoryScreen(),
              ),
              GoRoute(
                path: 'player',
                builder: (context, state) {
                  final content = state.extra is MeditationContent
                      ? state.extra as MeditationContent
                      : null;
                  return MeditationPlayerScreen(content: content);
                },
              ),
              GoRoute(
                path: 'explore',
                builder: (context, state) {
                  final category = state.extra as String?;
                  return MeditationExploreScreen(initialCategory: category);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/mood-analytics',
            builder: (context, state) => const MoodHomeScreenV2(),
          ),

          GoRoute(
            path: '/assessment/:id',
            builder: (context, state) =>
                AssessmentIntroScreen(assessmentId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'run',
                builder: (context, state) {
                  final depth = state.extra as String? ?? 'standard';
                  return AssessmentScreen(
                    assessmentId: state.pathParameters['id']!,
                    depth: depth,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/assessment-result',
            builder: (context, state) =>
                AssessmentResultScreen(result: state.extra as AssessmentResult),
          ),
          GoRoute(
            path: '/adaptive-assessment/:treeId',
            builder: (context, state) =>
                AdaptiveAssessmentScreen(treeId: state.pathParameters['treeId']!),
          ),
          GoRoute(
            path: '/breathing',
            builder: (context, state) => const BreathingIntroScreen(),
          ),
          GoRoute(
            path: '/breathing/exercise',
            builder: (context, state) => BreathingExerciseScreen(
              technique: state.extra as BreathingTechnique,
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const AssessmentHistoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/weekly-insight',
            builder: (context, state) => WeeklyInsightScreen(
              report: state.extra as WeeklyReport,
            ),
          ),
          GoRoute(
            path: '/weekly-history',
            builder: (context, state) => const WeeklyReportHistoryScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationInboxScreen(),
          ),
          GoRoute(
            path: '/ai-hub',
            builder: (context, state) => const AiPredictionHubScreen(),
          ),
          GoRoute(
            path: '/notification-settings',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: '/sleep',
            builder: (context, state) => const SleepModeScreen(),
          ),

          GoRoute(
            path: '/sleep/tracking',
            builder: (context, state) => const SleepTrackingScreen(),
          ),
          GoRoute(
            path: '/sleep/emergency',
            builder: (context, state) => const SleepEmergencyScreen(),
          ),
          GoRoute(
            path: '/sleep/routine',
            builder: (context, state) => const NightRoutineScreen(),
          ),
          GoRoute(
            path: '/sleep/sounds',
            builder: (context, state) => const SleepSoundsDashboard(),
          ),
          GoRoute(
            path: '/sleep/ritual-builder',
            builder: (context, state) => const RitualBuilderScreen(),
          ),
          // ─── Crisis Support ─────────────────────────────────────────

          GoRoute(
            path: '/crisis-hub',
            builder: (context, state) => const CrisisHubScreen(),
          ),
          GoRoute(
            path: '/safe-contacts',
            builder: (context, state) => const SafeContactsScreen(),
          ),
          GoRoute(
            path: '/sos-mode',
            builder: (context, state) => const SosModeScreen(),
          ),
          GoRoute(
            path: '/recovery',
            builder: (context, state) => const RecoverySuccessScreen(),
          ),
          GoRoute(
            path: '/recovery-engine',
            builder: (context, state) => const RecoveryHomeScreenV2(),

          ),
          // ─── Audio Sanctuary ───────────────────────────────────────

          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitHomeScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const HabitCreateScreen(),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const HabitHistoryScreen(),
              ),
            ],
          ),

        ],
      ),
      GoRoute(
        path: '/therapist',
        builder: (context, state) => const TherapistHomeScreenV2(),
        routes: [
          GoRoute(
            path: 'messages',
            builder: (context, state) => const UserMessagesScreen(),
          ),
          GoRoute(
            path: 'match',
            builder: (context, state) => const TherapistMatchScreen(),
          ),
          GoRoute(
            path: 'post-session',
            builder: (context, state) {
               final appointmentId = state.extra as String? ?? 'dummy_id';
               return TherapistPostSessionScreen(appointmentId: appointmentId);
            },
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) {
              final profile = state.extra as TherapistProfile;
              return TherapistProfileScreen(profile: profile);
            },
            routes: [
              GoRoute(
                path: 'booking',
                builder: (context, state) {
                  final profile = state.extra as TherapistProfile;
                  return TherapistBookingScreen(profile: profile);
                },
              ),
              GoRoute(
                path: 'prep',
                builder: (context, state) {
                  final profile = state.extra as TherapistProfile;
                  return TherapistSessionPrepScreen(profile: profile);
                },
              ),
              GoRoute(
                path: 'chat',
                builder: (context, state) {
                  final profile = state.extra as TherapistProfile;
                  return TherapistChatScreen(profile: profile);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'category',
            builder: (context, state) {
              final category = state.extra as String? ?? 'Anxiety';
              return TherapistCategoryScreen(category: category);
            },
          ),
          GoRoute(
            path: 'portal',
            builder: (context, state) => const TherapistDashboardScreen(),
            routes: [
              GoRoute(
                path: 'insight',
                builder: (context, state) {
                  final Map<String, dynamic> extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : {};
                  final patientName = extra['patientName'] as String? ?? 'Patient';
                  final patientId = extra['patientId'] as String? ?? '';
                  return TherapistPatientInsightScreen(patientName: patientName, patientId: patientId);
                },
              ),
              GoRoute(
                path: 'notes',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final patientName = extra['remoteName'] as String? ?? 'Patient';
                  final appointmentId = extra['appointmentId'] as String? ?? 'dummy_id';
                  return TherapistNotesScreen(patientName: patientName, appointmentId: appointmentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'session/live',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return TherapistLiveSessionScreen(
                isTherapistRole: extra['isTherapistRole'] ?? false,
                remoteName: extra['remoteName'] ?? 'Unknown',
                remoteImageUrl: extra['remoteImageUrl'],
                roomId: extra['roomId'] ?? 'default_room',
                appointmentId: extra['appointmentId'] ?? 'dummy_id',
              );
            },
          ),
          GoRoute(
            path: 'care-plan',
            builder: (context, state) => const UserCarePlanScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengeHomeScreen(),
        routes: [
          GoRoute(
            path: 'active',
            builder: (context, state) => const ActiveChallengeScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return ChallengeDetailScreen(challengeId: id);
            },
          ),
        ],
      ),

      GoRoute(
        path: '/sleep/breathing',
        builder: (context, state) => const SleepBreathingScreen(),
      ),
      GoRoute(
        path: '/support-plan',
        builder: (context, state) => const CrisisPlanScreen(),
      ),
      GoRoute(
        path: '/audio',
        builder: (context, state) => const AudioDashboardScreen(),
        routes: [
          GoRoute(
            path: 'player',
            builder: (context, state) {
              final track = state.extra is AudioTrack
                  ? state.extra as AudioTrack
                  : null;
              return AudioPlayerScreen(initialTrack: track);
            },
          ),
          GoRoute(
            path: 'category',
            builder: (context, state) {
              final category = state.extra as AudioCategoryMeta;
              return AudioCategoryScreen(category: category);
            },
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const AudioHistoryScreen(),
          ),
        ],
      ),
      // ─── Grounding Interactive Tools ──────────────────────────
      GoRoute(
        path: '/grounding/sensory',
        builder: (context, state) => const SensoryExerciseScreen(),
      ),
      GoRoute(
        path: '/grounding/panic',
        builder: (context, state) => const PanicResetScreen(),
      ),
      GoRoute(
        path: '/grounding/color-breathing',
        builder: (context, state) => const ColorBreathingScreen(),
      ),
      GoRoute(
        path: '/grounding/touch-hold',
        builder: (context, state) => const TouchHoldScreen(),
      ),
      GoRoute(
        path: '/grounding/body-scan',
        builder: (context, state) => const BodyScanScreen(),
      ),
      GoRoute(
        path: '/grounding/safe-place',
        builder: (context, state) => const SafePlaceScreen(),
      ),
      GoRoute(
        path: '/grounding/history',
        builder: (context, state) => const GroundingHistoryScreen(),
      ),
      GoRoute(
        path: '/journal/editor',
        builder: (context, state) {
          final entry = state.extra is JournalEntry ? state.extra as JournalEntry : null;
          return JournalEditorScreen(initialEntry: entry);
        },
      ),
      GoRoute(
        path: '/focus',
        builder: (context, state) => const FocusTimerScreen(),
        routes: [
          GoRoute(
            path: 'active',
            builder: (context, state) => const ActiveFocusSessionScreen(),
          ),
          GoRoute(
            path: 'completion',
            builder: (context, state) {
              final session = state.extra as FocusSession?;
              return FocusCompletionScreen(session: session);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/journeys',
        builder: (context, state) => const JourneysHomeScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              return JourneyDetailScreen(journey: state.extra as GuidedHealingJourney);
            },
          ),
          GoRoute(
            path: 'compassionate-return',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return CompassionateReturnScreen(
                journey: args['journey'] as GuidedHealingJourney,
                lastDay: args['lastDay'] as int,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/personalization',
        builder: (context, state) => const PersonalizationInsightScreen(),
        routes: [
          GoRoute(
            path: 'memory',
            builder: (context, state) => const EmotionalMemoryControlsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/prediction-hub',
        builder: (context, state) => const AiPredictionHubScreen(),
      ),
    ],
  );
});

