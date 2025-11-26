// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Football Arena';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get username => 'Username';

  @override
  String get country => 'Country';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get home => 'Home';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get profile => 'Profile';

  @override
  String get store => 'Store';

  @override
  String get settings => 'Settings';

  @override
  String get friends => 'Friends';

  @override
  String get history => 'History';

  @override
  String get soloMode => 'Solo Mode';

  @override
  String get challenge1v1 => '1v1 Challenge';

  @override
  String get teamMatch => 'Team Match';

  @override
  String get dailyQuiz => 'Daily Quiz';

  @override
  String get play => 'Play';

  @override
  String get roomName => 'Room Name';

  @override
  String get roomNameOptional => 'Room Name (Optional)';

  @override
  String get roomNameHint => 'Enter a name for your room';

  @override
  String get numberOfRounds => 'Number of Rounds';

  @override
  String get roundsHint => 'Number of questions (5-30)';

  @override
  String get roundsMin => 'Minimum 5 rounds';

  @override
  String get roundsMax => 'Maximum 30 rounds';

  @override
  String get roundsInvalid => 'Please enter a valid number between 5 and 30';

  @override
  String get shuffleTeams => 'Shuffle Teams';

  @override
  String get teamsShuffled => 'Teams have been shuffled!';

  @override
  String get shufflingTeams => 'Shuffling teams...';

  @override
  String get onlyHostCanShuffle => 'Only the host can shuffle teams';

  @override
  String get cannotShuffleAfterStart =>
      'Cannot shuffle teams after game has started';

  @override
  String get needTwoPlayersToShuffle =>
      'Need at least 2 players to shuffle teams';

  @override
  String get protectYourStreak => 'Protect Your Streak';

  @override
  String currentStreak(int streak) {
    return 'Current Streak: $streak days';
  }

  @override
  String get streakProtectionDescription =>
      'Your streak is about to be broken! Protect it using coins or VIP membership.';

  @override
  String get protectWithVip => 'Protect with VIP (Free)';

  @override
  String protectWithCoins(int coins) {
    return 'Protect with $coins Coins';
  }

  @override
  String get notEnoughCoinsForProtection =>
      'You need 100 coins to protect your streak';

  @override
  String get noThanks => 'No Thanks';

  @override
  String streakProtected(int streak) {
    return 'Streak Protected! $streak days';
  }

  @override
  String get streakBroken => 'Streak Broken';

  @override
  String dayStreak(int count) {
    return '$count Day Streak';
  }

  @override
  String get streakProtectedMessage => 'Your streak has been protected!';

  @override
  String get streakBrokenMessage => 'Your streak has been broken';

  @override
  String get keepPlayingDaily => 'Keep playing daily!';

  @override
  String get protectStreakNow => 'Protect Your Streak Now!';

  @override
  String get protectStreakDescription =>
      'Don\'t lose your progress! Use coins or VIP to protect your streak.';

  @override
  String get protectMyStreak => 'Protect My Streak';

  @override
  String get pleaseLoginToProtectStreak =>
      'Please login to protect your streak';

  @override
  String get streakProtectedSuccessfully => 'Streak protected successfully!';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get startGame => 'Start Game';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backHome => 'Back Home';

  @override
  String get shareScore => 'Share Score';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get category => 'Category';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get selectCategory => 'Select Category (Optional)';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get general => 'General';

  @override
  String get worldCup => 'World Cup';

  @override
  String get clubs => 'Clubs';

  @override
  String get players => 'Players';

  @override
  String get difficultyDescription => 'Choose your challenge level';

  @override
  String get categoryDescription =>
      'Pick a specific topic or leave blank for mixed questions';

  @override
  String get anyDifficulty => 'Any Difficulty';

  @override
  String get anyCategory => 'Any Category';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get level => 'Level';

  @override
  String get xp => 'XP';

  @override
  String coins(int count) {
    return '$count Coins';
  }

  @override
  String get streak => 'Streak';

  @override
  String get question => 'Question';

  @override
  String questionNumber(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String timeRemaining(int seconds) {
    return '${seconds}s';
  }

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get trueText => 'True';

  @override
  String get falseText => 'False';

  @override
  String get selectAnswer => 'Select Answer';

  @override
  String get timeUp => 'Time\'s Up!';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get skip => 'Skip';

  @override
  String get revealWrong => 'Reveal Wrong';

  @override
  String get extraTime => 'Extra Time';

  @override
  String get results => 'Results';

  @override
  String get score => 'Score';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get incorrectAnswers => 'Incorrect Answers';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get xpGained => 'XP Gained';

  @override
  String get coinsEarned => 'Coins Earned';

  @override
  String get timeBonus => 'Time Bonus';

  @override
  String get totalScore => 'Total Score';

  @override
  String get wellDone => 'Well Done!';

  @override
  String get greatJob => 'Great Job!';

  @override
  String get excellent => 'Excellent!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get matchmaking => 'Matchmaking';

  @override
  String get findingOpponent => 'Finding Opponent...';

  @override
  String get opponentFound => 'Opponent Found!';

  @override
  String get waitingForOpponent => 'Waiting for Opponent...';

  @override
  String get opponent => 'Opponent';

  @override
  String get you => 'You';

  @override
  String get attack => 'Attack';

  @override
  String get counterAttack => 'Counter Attack';

  @override
  String get neutralPlay => 'Neutral Play';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get shareResult => 'Share Result';

  @override
  String get region => 'Region';

  @override
  String get selectRegion => 'Select Region';

  @override
  String get teamLobby => 'Team Lobby';

  @override
  String get createTeam => 'Create Team';

  @override
  String get joinTeam => 'Join Team';

  @override
  String get teamA => 'Team A';

  @override
  String get teamB => 'Team B';

  @override
  String get ready => 'Ready';

  @override
  String get notReady => 'Not Ready';

  @override
  String get waitingForPlayers => 'Waiting for Players...';

  @override
  String get teamFull => 'Team Full';

  @override
  String get mvp => 'MVP';

  @override
  String get dailyQuizAvailable => 'Daily Quiz Available';

  @override
  String get dailyQuizCompleted => 'Daily Quiz Completed';

  @override
  String quizStartsIn(String time) {
    return 'Quiz starts in $time';
  }

  @override
  String get specialRewards => 'Special Rewards';

  @override
  String get bonusCoins => 'Bonus Coins';

  @override
  String get bonusXP => 'Bonus XP';

  @override
  String get global => 'Global';

  @override
  String get monthly => 'Monthly';

  @override
  String get allTime => 'All Time';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get rank => 'Rank';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noFriendsYet =>
      'No friends yet. Add friends to see their rankings!';

  @override
  String get usingOfflineData => 'Using offline data. Pull to refresh.';

  @override
  String get friendsList => 'Friends List';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get sentRequests => 'Sent Requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get remove => 'Remove';

  @override
  String get searchFriends => 'Search Friends';

  @override
  String get noFriends => 'No friends yet';

  @override
  String get noRequests => 'No pending requests';

  @override
  String get addFriendsToChallenge => 'Add friends to challenge them!';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String get removeFriendConfirmation =>
      'Are you sure you want to remove this friend?';

  @override
  String get friendRemoved => 'Friend removed successfully';

  @override
  String get enterUsernameOrEmail => 'Enter username or email';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get friendRequestSent => 'Friend request sent successfully';

  @override
  String get userNotFound => 'User not found';

  @override
  String get friendRequestAccepted => 'Friend request accepted';

  @override
  String get friendRequestRejected => 'Friend request rejected';

  @override
  String get matchHistory => 'Match History';

  @override
  String get recentMatches => 'Recent Matches';

  @override
  String get noMatches => 'No matches played yet';

  @override
  String get matchType => 'Match Type';

  @override
  String get result => 'Result';

  @override
  String get win => 'Win';

  @override
  String get lose => 'Lose';

  @override
  String get draw => 'Draw';

  @override
  String get playedAt => 'Played At';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get totalGames => 'Total Games';

  @override
  String get soloGames => 'Solo Games';

  @override
  String get challengeGames => '1v1 Games';

  @override
  String get teamGames => 'Team Games';

  @override
  String get winRate => 'Win Rate';

  @override
  String get accuracyRate => 'Accuracy Rate';

  @override
  String get achievements => 'Achievements';

  @override
  String get badges => 'Badges';

  @override
  String get vipStatus => 'VIP Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get expiresOn => 'Expires On';

  @override
  String get coinPacks => 'Coin Packs';

  @override
  String get vipMembership => 'VIP Membership';

  @override
  String get boosts => 'Boosts';

  @override
  String get smallPack => 'Small Pack';

  @override
  String get mediumPack => 'Medium Pack';

  @override
  String get largePack => 'Large Pack';

  @override
  String get vipMonthly => 'VIP Monthly';

  @override
  String get vipYearly => 'VIP Yearly';

  @override
  String get vipLifetime => 'VIP Lifetime';

  @override
  String get noAds => 'No ads + 50% more rewards';

  @override
  String get purchase => 'Purchase';

  @override
  String get purchased => 'Purchased';

  @override
  String get insufficientCoins => 'Insufficient coins';

  @override
  String get purchaseSuccessful => 'Purchase successful!';

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get notifications => 'Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get logout => 'Logout';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get version => 'Version';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get onboarding => 'Onboarding';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeDescription =>
      'Test your football knowledge and compete with players worldwide';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get connectionTimeout =>
      'Connection timeout. Please check your internet connection.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get pleaseLogin => 'Please login to continue';

  @override
  String get pleaseLoginToPurchase => 'Please login to make purchases';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get emailAlreadyExists => 'Email already exists';

  @override
  String get weakPassword => 'Password is too weak';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get upgradeGuestAccount => 'Upgrade Guest Account';

  @override
  String get upgradeGuestDescription =>
      'Convert your guest account to a full account to save your progress and access all features.';

  @override
  String get upgradeAccount => 'Upgrade Account';

  @override
  String get accountUpgradedSuccessfully => 'Account upgraded successfully!';

  @override
  String get optional => 'Optional';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get bonus20Percent => '20% Bonus';

  @override
  String get bestValue => 'Best Value';

  @override
  String get skipQuestion => 'Skip Question';

  @override
  String get revealWrongOption => 'Reveal Wrong';

  @override
  String get extraTimeBoost => 'Extra Time';

  @override
  String get plus5Seconds => '+5 seconds per question';

  @override
  String get skipAnyQuestion => 'Skip any question';

  @override
  String get revealOneWrong => 'Reveal one wrong option';

  @override
  String get gameModes => 'Game Modes';

  @override
  String get xpProgress => 'XP Progress';

  @override
  String get yourStats => 'Your Stats';

  @override
  String get games => 'Games';

  @override
  String get visitStore => 'Visit Store';

  @override
  String get boostsAndItems => 'Boosts & Items';

  @override
  String get open => 'Open';

  @override
  String get playNow => 'Play Now';

  @override
  String get quickQuiz => 'Quick quiz';

  @override
  String get duelMode => 'Duel mode';

  @override
  String get upTo10Players => 'Up to 10 players';

  @override
  String get twoXRewards => '2x Rewards';

  @override
  String get twoXXP => '2x XP';

  @override
  String get bonusCoinsExclamation => 'Bonus Coins!';

  @override
  String get or => 'OR';

  @override
  String get apple => 'Apple';

  @override
  String get google => 'Google';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String levelFormat(int level, String country) {
    return 'Level $level - $country';
  }

  @override
  String get empty => 'Empty';

  @override
  String get noQuestions => 'No questions available. Please try again later.';

  @override
  String get quizCompleted => 'Quiz Completed';

  @override
  String get matchEnded => 'Match Ended';
}
