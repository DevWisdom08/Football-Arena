class RouteNames {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String upgradeGuest = '/upgrade-guest';
  
  // Main Routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  
  // Game Mode Routes
  static const String soloMode = '/solo-mode';
  static const String soloModeSettings = '/solo-mode/settings';
  static const String soloModeGame = '/solo-mode/game';
  static const String soloModeResults = '/solo-mode/results';
  
  static const String challenge1v1 = '/challenge-1v1';
  static const String challenge1v1Matchmaking = '/challenge-1v1/matchmaking';
  static const String challenge1v1Game = '/challenge-1v1/game';
  static const String challenge1v1Results = '/challenge-1v1/results';
  
  static const String teamMatch = '/team-match';
  static const String teamMatchCreate = '/team-match/create';
  static const String teamMatchJoin = '/team-match/join';
  static const String teamMatchLobby = '/team-match/lobby';
  static const String teamMatchGame = '/team-match/game';
  static const String teamMatchResults = '/team-match/results';
  
  static const String dailyQuiz = '/daily-quiz';
  static const String dailyQuizGame = '/daily-quiz/game';
  static const String dailyQuizResults = '/daily-quiz/results';
  
  // Other Feature Routes
  static const String leaderboard = '/leaderboard';
  static const String store = '/store';
  static const String friends = '/friends';
  static const String notifications = '/notifications';
  static const String achievements = '/achievements';
  static const String history = '/history';
  
  // Stake Match & Withdrawal Routes
  static const String stakeMatch = '/stake-match';
  static const String stakeMatchGame = '/stake-match/game';
  static const String stakeMatchResults = '/stake-match/results';
  static const String withdrawal = '/withdrawal';
  
  // Helper method to check if route requires auth
  static bool requiresAuth(String route) {
    const unauthenticatedRoutes = [
      splash,
      onboarding,
      login,
      register,
      forgotPassword,
    ];
    return !unauthenticatedRoutes.contains(route);
  }
}

