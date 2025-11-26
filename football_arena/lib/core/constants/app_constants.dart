class AppConstants {
  // App Info
  static const String appName = 'Football Arena';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // Android emulator needs 10.0.2.2 to reach host machine's localhost
  // iOS simulator can use localhost
  // For physical devices, use your computer's IP (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  static const String wsUrl = 'ws://10.0.2.2:3000'; // Android emulator WebSocket
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Game Configuration
  static const int defaultQuizQuestions = 10;
  static const int soloModeQuestions = 10;
  static const int challenge1v1Questions = 10;
  static const int teamMatchQuestions = 10;
  static const int dailyQuizQuestions = 15;
  
  static const int questionTimeLimit = 10; // seconds
  static const int reconnectionGracePeriod = 30; // seconds
  
  // Scoring
  static const int basePointsPerCorrect = 100;
  static const int maxTimeBonus = 50;
  static const int xpDivisor = 20;
  static const int coinsPerTwoCorrect = 1;
  
  // Levels & XP
  static const int xpPerLevel = 1000;
  static const int maxLevel = 100;
  
  // Matchmaking
  static const int maxTeamPlayers = 10;
  static const int minTeamPlayers = 2;
  static const int levelRangeForMatching = 5;
  static const Duration matchmakingTimeout = Duration(seconds: 30);
  
  // UI Configuration
  static const double defaultPadding = 20.0;
  static const double defaultBorderRadius = 26.0;
  static const double cardElevation = 12.0;
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyStreak = 'streak';
  static const String keyLastPlayDate = 'last_play_date';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Notification Channels
  static const String notificationChannelId = 'football_arena_notifications';
  static const String notificationChannelName = 'Football Arena';
  static const String notificationChannelDescription = 'Notifications for Football Arena';
  
  // Ad Configuration
  static const String adUnitIdRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String adUnitIdRewardedIOS = 'ca-app-pub-3940256099942544/1712485313'; // Test ID
  static const String adUnitIdInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String adUnitIdInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  
  // Countries (for profile selection)
  static const List<String> countries = [
    'UAE', 'Saudi Arabia', 'Egypt', 'Morocco', 'Algeria',
    'Tunisia', 'Qatar', 'Kuwait', 'Bahrain', 'Oman',
    'Jordan', 'Lebanon', 'Iraq', 'Syria', 'Yemen',
    'Libya', 'Sudan', 'Palestine', 'Other'
  ];
  
  // Question Categories
  static const List<String> questionCategories = [
    'General',
    'World Cup',
    'Champions League',
    'Premier League',
    'La Liga',
    'Serie A',
    'Bundesliga',
    'Players',
    'Clubs',
    'History',
    'Stats',
  ];
  
  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Easy',
    'Medium',
    'Hard',
  ];
}

