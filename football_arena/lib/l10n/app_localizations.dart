import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Football Arena'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @soloMode.
  ///
  /// In en, this message translates to:
  /// **'Solo Mode'**
  String get soloMode;

  /// No description provided for @challenge1v1.
  ///
  /// In en, this message translates to:
  /// **'1v1 Challenge'**
  String get challenge1v1;

  /// No description provided for @teamMatch.
  ///
  /// In en, this message translates to:
  /// **'Team Match'**
  String get teamMatch;

  /// No description provided for @dailyQuiz.
  ///
  /// In en, this message translates to:
  /// **'Daily Quiz'**
  String get dailyQuiz;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @roomNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Room Name (Optional)'**
  String get roomNameOptional;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your room'**
  String get roomNameHint;

  /// No description provided for @numberOfRounds.
  ///
  /// In en, this message translates to:
  /// **'Number of Rounds'**
  String get numberOfRounds;

  /// No description provided for @roundsHint.
  ///
  /// In en, this message translates to:
  /// **'Number of questions (5-30)'**
  String get roundsHint;

  /// No description provided for @roundsMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 5 rounds'**
  String get roundsMin;

  /// No description provided for @roundsMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum 30 rounds'**
  String get roundsMax;

  /// No description provided for @roundsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number between 5 and 30'**
  String get roundsInvalid;

  /// No description provided for @shuffleTeams.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Teams'**
  String get shuffleTeams;

  /// No description provided for @teamsShuffled.
  ///
  /// In en, this message translates to:
  /// **'Teams have been shuffled!'**
  String get teamsShuffled;

  /// No description provided for @shufflingTeams.
  ///
  /// In en, this message translates to:
  /// **'Shuffling teams...'**
  String get shufflingTeams;

  /// No description provided for @onlyHostCanShuffle.
  ///
  /// In en, this message translates to:
  /// **'Only the host can shuffle teams'**
  String get onlyHostCanShuffle;

  /// No description provided for @cannotShuffleAfterStart.
  ///
  /// In en, this message translates to:
  /// **'Cannot shuffle teams after game has started'**
  String get cannotShuffleAfterStart;

  /// No description provided for @needTwoPlayersToShuffle.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 players to shuffle teams'**
  String get needTwoPlayersToShuffle;

  /// No description provided for @protectYourStreak.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Streak'**
  String get protectYourStreak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak: {streak} days'**
  String currentStreak(int streak);

  /// No description provided for @streakProtectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your streak is about to be broken! Protect it using coins or VIP membership.'**
  String get streakProtectionDescription;

  /// No description provided for @protectWithVip.
  ///
  /// In en, this message translates to:
  /// **'Protect with VIP (Free)'**
  String get protectWithVip;

  /// No description provided for @protectWithCoins.
  ///
  /// In en, this message translates to:
  /// **'Protect with {coins} Coins'**
  String protectWithCoins(int coins);

  /// No description provided for @notEnoughCoinsForProtection.
  ///
  /// In en, this message translates to:
  /// **'You need 100 coins to protect your streak'**
  String get notEnoughCoinsForProtection;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No Thanks'**
  String get noThanks;

  /// No description provided for @streakProtected.
  ///
  /// In en, this message translates to:
  /// **'Streak Protected! {streak} days'**
  String streakProtected(int streak);

  /// No description provided for @streakBroken.
  ///
  /// In en, this message translates to:
  /// **'Streak Broken'**
  String get streakBroken;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String dayStreak(int count);

  /// No description provided for @streakProtectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your streak has been protected!'**
  String get streakProtectedMessage;

  /// No description provided for @streakBrokenMessage.
  ///
  /// In en, this message translates to:
  /// **'Your streak has been broken'**
  String get streakBrokenMessage;

  /// No description provided for @keepPlayingDaily.
  ///
  /// In en, this message translates to:
  /// **'Keep playing daily!'**
  String get keepPlayingDaily;

  /// No description provided for @protectStreakNow.
  ///
  /// In en, this message translates to:
  /// **'Protect Your Streak Now!'**
  String get protectStreakNow;

  /// No description provided for @protectStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t lose your progress! Use coins or VIP to protect your streak.'**
  String get protectStreakDescription;

  /// No description provided for @protectMyStreak.
  ///
  /// In en, this message translates to:
  /// **'Protect My Streak'**
  String get protectMyStreak;

  /// No description provided for @pleaseLoginToProtectStreak.
  ///
  /// In en, this message translates to:
  /// **'Please login to protect your streak'**
  String get pleaseLoginToProtectStreak;

  /// No description provided for @streakProtectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Streak protected successfully!'**
  String get streakProtectedSuccessfully;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backHome;

  /// No description provided for @shareScore.
  ///
  /// In en, this message translates to:
  /// **'Share Score'**
  String get shareScore;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category (Optional)'**
  String get selectCategory;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @worldCup.
  ///
  /// In en, this message translates to:
  /// **'World Cup'**
  String get worldCup;

  /// No description provided for @clubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @difficultyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your challenge level'**
  String get difficultyDescription;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a specific topic or leave blank for mixed questions'**
  String get categoryDescription;

  /// No description provided for @anyDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Any Difficulty'**
  String get anyDifficulty;

  /// No description provided for @anyCategory.
  ///
  /// In en, this message translates to:
  /// **'Any Category'**
  String get anyCategory;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'{count} Coins'**
  String coins(int count);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionNumber(int current, int total);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String timeRemaining(int seconds);

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// True option for True/False questions
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueText;

  /// False option for True/False questions
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseText;

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select Answer'**
  String get selectAnswer;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timeUp;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @revealWrong.
  ///
  /// In en, this message translates to:
  /// **'Reveal Wrong'**
  String get revealWrong;

  /// No description provided for @extraTime.
  ///
  /// In en, this message translates to:
  /// **'Extra Time'**
  String get extraTime;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// No description provided for @incorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Answers'**
  String get incorrectAnswers;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @xpGained.
  ///
  /// In en, this message translates to:
  /// **'XP Gained'**
  String get xpGained;

  /// No description provided for @coinsEarned.
  ///
  /// In en, this message translates to:
  /// **'Coins Earned'**
  String get coinsEarned;

  /// No description provided for @timeBonus.
  ///
  /// In en, this message translates to:
  /// **'Time Bonus'**
  String get timeBonus;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well Done!'**
  String get wellDone;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @matchmaking.
  ///
  /// In en, this message translates to:
  /// **'Matchmaking'**
  String get matchmaking;

  /// No description provided for @findingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Finding Opponent...'**
  String get findingOpponent;

  /// No description provided for @opponentFound.
  ///
  /// In en, this message translates to:
  /// **'Opponent Found!'**
  String get opponentFound;

  /// No description provided for @waitingForOpponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Opponent...'**
  String get waitingForOpponent;

  /// No description provided for @opponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponent;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @attack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get attack;

  /// No description provided for @counterAttack.
  ///
  /// In en, this message translates to:
  /// **'Counter Attack'**
  String get counterAttack;

  /// No description provided for @neutralPlay.
  ///
  /// In en, this message translates to:
  /// **'Neutral Play'**
  String get neutralPlay;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get selectRegion;

  /// No description provided for @teamLobby.
  ///
  /// In en, this message translates to:
  /// **'Team Lobby'**
  String get teamLobby;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @joinTeam.
  ///
  /// In en, this message translates to:
  /// **'Join Team'**
  String get joinTeam;

  /// No description provided for @teamA.
  ///
  /// In en, this message translates to:
  /// **'Team A'**
  String get teamA;

  /// No description provided for @teamB.
  ///
  /// In en, this message translates to:
  /// **'Team B'**
  String get teamB;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @notReady.
  ///
  /// In en, this message translates to:
  /// **'Not Ready'**
  String get notReady;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Players...'**
  String get waitingForPlayers;

  /// No description provided for @teamFull.
  ///
  /// In en, this message translates to:
  /// **'Team Full'**
  String get teamFull;

  /// No description provided for @mvp.
  ///
  /// In en, this message translates to:
  /// **'MVP'**
  String get mvp;

  /// No description provided for @dailyQuizAvailable.
  ///
  /// In en, this message translates to:
  /// **'Daily Quiz Available'**
  String get dailyQuizAvailable;

  /// No description provided for @dailyQuizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Daily Quiz Completed'**
  String get dailyQuizCompleted;

  /// No description provided for @quizStartsIn.
  ///
  /// In en, this message translates to:
  /// **'Quiz starts in {time}'**
  String quizStartsIn(String time);

  /// No description provided for @specialRewards.
  ///
  /// In en, this message translates to:
  /// **'Special Rewards'**
  String get specialRewards;

  /// No description provided for @bonusCoins.
  ///
  /// In en, this message translates to:
  /// **'Bonus Coins'**
  String get bonusCoins;

  /// No description provided for @bonusXP.
  ///
  /// In en, this message translates to:
  /// **'Bonus XP'**
  String get bonusXP;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet. Add friends to see their rankings!'**
  String get noFriendsYet;

  /// No description provided for @usingOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Using offline data. Pull to refresh.'**
  String get usingOfflineData;

  /// No description provided for @friendsList.
  ///
  /// In en, this message translates to:
  /// **'Friends List'**
  String get friendsList;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @sentRequests.
  ///
  /// In en, this message translates to:
  /// **'Sent Requests'**
  String get sentRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @searchFriends.
  ///
  /// In en, this message translates to:
  /// **'Search Friends'**
  String get searchFriends;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriends;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noRequests;

  /// No description provided for @addFriendsToChallenge.
  ///
  /// In en, this message translates to:
  /// **'Add friends to challenge them!'**
  String get addFriendsToChallenge;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @removeFriendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this friend?'**
  String get removeFriendConfirmation;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed successfully'**
  String get friendRemoved;

  /// No description provided for @enterUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter username or email'**
  String get enterUsernameOrEmail;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent successfully'**
  String get friendRequestSent;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get friendRequestRejected;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistory;

  /// No description provided for @recentMatches.
  ///
  /// In en, this message translates to:
  /// **'Recent Matches'**
  String get recentMatches;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches played yet'**
  String get noMatches;

  /// No description provided for @matchType.
  ///
  /// In en, this message translates to:
  /// **'Match Type'**
  String get matchType;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// No description provided for @lose.
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get lose;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// No description provided for @playedAt.
  ///
  /// In en, this message translates to:
  /// **'Played At'**
  String get playedAt;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @totalGames.
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// No description provided for @soloGames.
  ///
  /// In en, this message translates to:
  /// **'Solo Games'**
  String get soloGames;

  /// No description provided for @challengeGames.
  ///
  /// In en, this message translates to:
  /// **'1v1 Games'**
  String get challengeGames;

  /// No description provided for @teamGames.
  ///
  /// In en, this message translates to:
  /// **'Team Games'**
  String get teamGames;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @accuracyRate.
  ///
  /// In en, this message translates to:
  /// **'Accuracy Rate'**
  String get accuracyRate;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @vipStatus.
  ///
  /// In en, this message translates to:
  /// **'VIP Status'**
  String get vipStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires On'**
  String get expiresOn;

  /// No description provided for @coinPacks.
  ///
  /// In en, this message translates to:
  /// **'Coin Packs'**
  String get coinPacks;

  /// No description provided for @vipMembership.
  ///
  /// In en, this message translates to:
  /// **'VIP Membership'**
  String get vipMembership;

  /// No description provided for @boosts.
  ///
  /// In en, this message translates to:
  /// **'Boosts'**
  String get boosts;

  /// No description provided for @smallPack.
  ///
  /// In en, this message translates to:
  /// **'Small Pack'**
  String get smallPack;

  /// No description provided for @mediumPack.
  ///
  /// In en, this message translates to:
  /// **'Medium Pack'**
  String get mediumPack;

  /// No description provided for @largePack.
  ///
  /// In en, this message translates to:
  /// **'Large Pack'**
  String get largePack;

  /// No description provided for @vipMonthly.
  ///
  /// In en, this message translates to:
  /// **'VIP Monthly'**
  String get vipMonthly;

  /// No description provided for @vipYearly.
  ///
  /// In en, this message translates to:
  /// **'VIP Yearly'**
  String get vipYearly;

  /// No description provided for @vipLifetime.
  ///
  /// In en, this message translates to:
  /// **'VIP Lifetime'**
  String get vipLifetime;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No ads + 50% more rewards'**
  String get noAds;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @insufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins'**
  String get insufficientCoins;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccessful;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboarding;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your football knowledge and compete with players worldwide'**
  String get welcomeDescription;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection.'**
  String get connectionTimeout;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get pleaseLogin;

  /// No description provided for @pleaseLoginToPurchase.
  ///
  /// In en, this message translates to:
  /// **'Please login to make purchases'**
  String get pleaseLoginToPurchase;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists'**
  String get emailAlreadyExists;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @upgradeGuestAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Guest Account'**
  String get upgradeGuestAccount;

  /// No description provided for @upgradeGuestDescription.
  ///
  /// In en, this message translates to:
  /// **'Convert your guest account to a full account to save your progress and access all features.'**
  String get upgradeGuestDescription;

  /// No description provided for @upgradeAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Account'**
  String get upgradeAccount;

  /// No description provided for @accountUpgradedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account upgraded successfully!'**
  String get accountUpgradedSuccessfully;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @bonus20Percent.
  ///
  /// In en, this message translates to:
  /// **'20% Bonus'**
  String get bonus20Percent;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @skipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Skip Question'**
  String get skipQuestion;

  /// No description provided for @revealWrongOption.
  ///
  /// In en, this message translates to:
  /// **'Reveal Wrong'**
  String get revealWrongOption;

  /// No description provided for @extraTimeBoost.
  ///
  /// In en, this message translates to:
  /// **'Extra Time'**
  String get extraTimeBoost;

  /// No description provided for @plus5Seconds.
  ///
  /// In en, this message translates to:
  /// **'+5 seconds per question'**
  String get plus5Seconds;

  /// No description provided for @skipAnyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Skip any question'**
  String get skipAnyQuestion;

  /// No description provided for @revealOneWrong.
  ///
  /// In en, this message translates to:
  /// **'Reveal one wrong option'**
  String get revealOneWrong;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'XP Progress'**
  String get xpProgress;

  /// No description provided for @yourStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @visitStore.
  ///
  /// In en, this message translates to:
  /// **'Visit Store'**
  String get visitStore;

  /// No description provided for @boostsAndItems.
  ///
  /// In en, this message translates to:
  /// **'Boosts & Items'**
  String get boostsAndItems;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick quiz'**
  String get quickQuiz;

  /// No description provided for @duelMode.
  ///
  /// In en, this message translates to:
  /// **'Duel mode'**
  String get duelMode;

  /// No description provided for @upTo10Players.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 players'**
  String get upTo10Players;

  /// No description provided for @twoXRewards.
  ///
  /// In en, this message translates to:
  /// **'2x Rewards'**
  String get twoXRewards;

  /// No description provided for @twoXXP.
  ///
  /// In en, this message translates to:
  /// **'2x XP'**
  String get twoXXP;

  /// No description provided for @bonusCoinsExclamation.
  ///
  /// In en, this message translates to:
  /// **'Bonus Coins!'**
  String get bonusCoinsExclamation;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @levelFormat.
  ///
  /// In en, this message translates to:
  /// **'Level {level} - {country}'**
  String levelFormat(int level, String country);

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @noQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available. Please try again later.'**
  String get noQuestions;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompleted;

  /// No description provided for @matchEnded.
  ///
  /// In en, this message translates to:
  /// **'Match Ended'**
  String get matchEnded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
