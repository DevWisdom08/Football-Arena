class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String guestLogin = '/auth/guest';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String appleSignIn = '/auth/apple';
  static const String googleSignIn = '/auth/google';
  static const String upgradeGuest = '/auth/upgrade-guest';
  
  // User endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static const String usersLeaderboard = '/users/leaderboard';
  
  // Questions endpoints
  static const String questions = '/questions';
  static String questionById(String id) => '/questions/$id';
  static String randomQuestions({int count = 10, String? difficulty}) {
    var url = '/questions/random?count=$count';
    if (difficulty != null) url += '&difficulty=$difficulty';
    return url;
  }
  static String questionsByCategory(String category, {int count = 10}) =>
      '/questions/category/$category?count=$count';
  static const String seedQuestions = '/questions/seed';
  
  // Leaderboard
  static String leaderboard({int limit = 50}) => '/users/leaderboard';
  
  // Store endpoints
  static const String storeItems = '/store/items';
  static const String storePurchase = '/store/purchase';
  
  // Future endpoints (not yet implemented in backend)
  static const String soloStart = '/game/solo/start';
  static const String soloSubmit = '/game/solo/submit';
  static const String challenge1v1Find = '/game/1v1/find';
  static const String teamMatchCreate = '/game/team/create';
  static const String dailyQuiz = '/game/daily-quiz';
}

