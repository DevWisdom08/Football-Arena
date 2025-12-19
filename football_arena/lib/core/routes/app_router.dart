import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/upgrade_guest_screen.dart';
import '../../features/solo_mode/presentation/solo_mode_screen.dart';
import '../../features/solo_mode/presentation/solo_game_screen.dart';
import '../../features/solo_mode/presentation/solo_results_screen.dart';
import '../../features/challenge_1v1/presentation/matchmaking_screen.dart';
import '../../features/challenge_1v1/presentation/challenge_1v1_game_screen.dart';
import '../../features/team_match/presentation/team_match_screen.dart';
import '../../features/team_match/presentation/team_lobby_screen.dart';
import '../../features/team_match/presentation/team_game_screen.dart';
import '../../features/daily_quiz/presentation/daily_quiz_screen.dart';
import '../../features/daily_quiz/presentation/daily_quiz_game_screen.dart';
import '../../features/daily_quiz/presentation/daily_quiz_results_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/friends/presentation/friends_screen.dart';
import '../../features/history/presentation/match_history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/store/presentation/store_screen.dart';
import '../../features/stake_match_screen.dart';
import '../../features/stake_match/presentation/stake_match_game_screen.dart';
import '../../features/stake_match/presentation/stake_match_results_screen.dart';
import '../../features/withdrawal_screen.dart';
import '../../features/legal/terms_of_service_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../services/storage_service.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = StorageService.instance.isAuthenticated;
      final isGoingToAuth =
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.forgotPassword ||
          state.matchedLocation == RouteNames.splash;

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isGoingToAuth) {
        return RouteNames.login;
      }

      // If authenticated and trying to access auth screens (except forgot password)
      if (isAuthenticated &&
          isGoingToAuth &&
          state.matchedLocation != RouteNames.splash &&
          state.matchedLocation != RouteNames.forgotPassword) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.upgradeGuest,
        builder: (context, state) => const UpgradeGuestScreen(),
      ),

      // Home
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Profile
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // Settings
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Friends
      GoRoute(
        path: RouteNames.friends,
        builder: (context, state) => const FriendsScreen(),
      ),

      // Match History
      GoRoute(
        path: RouteNames.history,
        builder: (context, state) => const MatchHistoryScreen(),
      ),

      // Solo Mode
      GoRoute(
        path: RouteNames.soloMode,
        builder: (context, state) => const SoloModeScreen(),
      ),
      GoRoute(
        path: RouteNames.soloModeGame,
        builder: (context, state) {
          List? questions;
          String? difficulty;
          String? category;

          if (state.extra is List) {
            questions = state.extra as List?;
          } else if (state.extra is Map) {
            final extra = state.extra as Map?;
            questions = extra?['questions'] as List?;
            difficulty = extra?['difficulty'] as String?;
            category = extra?['category'] as String?;
          }

          return SoloGameScreen(
            questions: questions,
            difficulty: difficulty,
            category: category,
          );
        },
      ),
      GoRoute(
        path: RouteNames.soloModeResults,
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>?;
          return SoloResultsScreen(result: result);
        },
      ),

      // Leaderboard
      GoRoute(
        path: RouteNames.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Store
      GoRoute(
        path: RouteNames.store,
        builder: (context, state) => const StoreScreen(),
      ),

      // 1v1 Challenge
      GoRoute(
        path: RouteNames.challenge1v1,
        builder: (context, state) => const MatchmakingScreen(),
      ),
      GoRoute(
        path: RouteNames.challenge1v1Game,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return Challenge1v1GameScreen(
            roomId: data?['roomId'] ?? '',
            opponent: data?['opponent'] ?? 'Unknown',
          );
        },
      ),

      // Team Match
      GoRoute(
        path: RouteNames.teamMatch,
        builder: (context, state) => const TeamMatchScreen(),
      ),
      GoRoute(
        path: RouteNames.teamMatchLobby,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return TeamLobbyScreen(
            roomId: data?['roomId'],
            roomCode: data?['roomCode'],
            myTeam: data?['myTeam'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.teamMatchGame,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return TeamGameScreen(
            roomId: data?['roomId'] ?? '',
            initialQuestion: data?['question'],
          );
        },
      ),

      // Daily Quiz
      GoRoute(
        path: RouteNames.dailyQuiz,
        builder: (context, state) => const DailyQuizScreen(),
      ),
      GoRoute(
        path: RouteNames.dailyQuizGame,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return DailyQuizGameScreen(
            questions: List<Map<String, dynamic>>.from(
              data?['questions'] ?? [],
            ),
            rewards: data?['rewards'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.dailyQuizResults,
        builder: (context, state) {
          final result = state.extra as Map<String, dynamic>?;
          return DailyQuizResultsScreen(result: result);
        },
      ),

      // Stake Match
      GoRoute(
        path: RouteNames.stakeMatch,
        builder: (context, state) => const StakeMatchScreen(),
      ),
      GoRoute(
        path: RouteNames.stakeMatchGame,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return StakeMatchGameScreen(
            matchId: data?['matchId'] ?? '',
            opponentId: data?['opponentId'] ?? '',
            opponentUsername: data?['opponentUsername'] ?? 'Opponent',
            stakeAmount: data?['stakeAmount'] ?? 0,
            difficulty: data?['difficulty'] ?? 'mixed',
            questionCount: data?['questionCount'] ?? 10,
          );
        },
      ),
      GoRoute(
        path: RouteNames.stakeMatchResults,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return StakeMatchResultsScreen(matchData: data ?? {});
        },
      ),

      // Withdrawal
      GoRoute(
        path: RouteNames.withdrawal,
        builder: (context, state) => const WithdrawalScreen(),
      ),

      // Legal Routes
      GoRoute(
        path: RouteNames.termsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // TODO: Add more routes for other features
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
