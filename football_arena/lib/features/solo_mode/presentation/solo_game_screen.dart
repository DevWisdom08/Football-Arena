import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/network/questions_api_service.dart';
import '../../../core/network/coins_api_service.dart';
import '../../../core/network/users_api_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/football_loading.dart';
import '../../../shared/widgets/game_boosts.dart';
import '../../../shared/widgets/question_display.dart';
import '../../../shared/widgets/top_notification.dart';

class SoloGameScreen extends ConsumerStatefulWidget {
  final List? questions;
  final String? difficulty;
  final String? category;

  const SoloGameScreen({
    super.key,
    this.questions,
    this.difficulty,
    this.category,
  });

  @override
  ConsumerState<SoloGameScreen> createState() => _SoloGameScreenState();
}

class _SoloGameScreenState extends ConsumerState<SoloGameScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int timeRemaining = 10;
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  bool isLoading = true;
  String? errorMessage;
  int totalTimeBonus = 0; // Total time bonus points accumulated
  int totalPoints = 0; // Total points (base + time bonus)
  int availableCoins = 0;
  List<BoostType> usedBoosts = [];
  List<String> hiddenOptions = []; // Options hidden by reveal wrong boost
  List<Map<String, dynamic>> questionTimeBonuses =
      []; // Track time bonus per question

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
    _loadQuestions();
  }

  Future<void> _loadUserCoins() async {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      setState(() {
        availableCoins = userData['coins'] ?? 0;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getOfflineQuestions() async {
    // Load questions from local JSON file
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/comprehensive-questions.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      // Transform to match expected format
      final allQuestions = jsonData.map((q) {
        final questionMap = {
          'id': q['text'].hashCode.toString(), // Use hash as ID
          'question': q['text'],
          'text': q['text'], // Add text field for QuestionDisplay compatibility
          'options': List<String>.from(q['options']),
          'correctAnswer': q['correctAnswer'],
        };

        // Add optional fields if they exist
        if (q['type'] != null) {
          questionMap['type'] = q['type'];
        }
        if (q['imageUrl'] != null) {
          questionMap['imageUrl'] = q['imageUrl'];
        }
        if (q['videoUrl'] != null) {
          questionMap['videoUrl'] = q['videoUrl'];
        }

        return questionMap;
      }).toList();

      // Shuffle and take random 10 questions
      allQuestions.shuffle();
      return allQuestions.take(10).toList();
    } catch (e) {
      // Ultimate fallback if JSON file can't be loaded
      return [
        {
          'id': 'fallback_1',
          'question': 'Who won the FIFA World Cup in 2022?',
          'options': ['Argentina', 'France', 'Brazil', 'Germany'],
          'correctAnswer': 'Argentina',
        },
        {
          'id': 'fallback_2',
          'question': 'Which player has won the most Ballon d\'Or awards?',
          'options': [
            'Lionel Messi',
            'Cristiano Ronaldo',
            'Michel Platini',
            'Johan Cruyff',
          ],
          'correctAnswer': 'Lionel Messi',
        },
        {
          'id': 'fallback_3',
          'question':
              'Which club has won the most UEFA Champions League titles?',
          'options': ['Real Madrid', 'AC Milan', 'Liverpool', 'Barcelona'],
          'correctAnswer': 'Real Madrid',
        },
        {
          'id': 'fallback_4',
          'question': 'Which country has won the most FIFA World Cups?',
          'options': ['Brazil', 'Germany', 'Italy', 'Argentina'],
          'correctAnswer': 'Brazil',
        },
        {
          'id': 'fallback_5',
          'question': 'Who is known as \'The Egyptian King\'?',
          'options': [
            'Mohamed Salah',
            'Ahmed Hegazi',
            'Mohamed Elneny',
            'Omar Marmoush',
          ],
          'correctAnswer': 'Mohamed Salah',
        },
        {
          'id': 'fallback_6',
          'question': 'Which club is known as \'The Red Devils\'?',
          'options': ['Manchester United', 'Liverpool', 'Arsenal', 'AC Milan'],
          'correctAnswer': 'Manchester United',
        },
        {
          'id': 'fallback_7',
          'question': 'How many players are on a football team on the field?',
          'options': ['9', '10', '11', '12'],
          'correctAnswer': '11',
        },
        {
          'id': 'fallback_8',
          'question': 'How long is a standard football match?',
          'options': ['80 minutes', '90 minutes', '100 minutes', '120 minutes'],
          'correctAnswer': '90 minutes',
        },
        {
          'id': 'fallback_9',
          'question': 'Which team is known as \'The Gunners\'?',
          'options': ['Arsenal', 'Chelsea', 'Tottenham', 'West Ham'],
          'correctAnswer': 'Arsenal',
        },
        {
          'id': 'fallback_10',
          'question': 'Who won the FIFA World Cup in 2018?',
          'options': ['France', 'Croatia', 'Belgium', 'England'],
          'correctAnswer': 'France',
        },
      ];
    }
  }

  Future<void> _loadQuestions() async {
    if (widget.questions != null && widget.questions!.isNotEmpty) {
      setState(() {
        questions = List<Map<String, dynamic>>.from(widget.questions!);
        isLoading = false;
      });
      startTimer();
      return;
    }

    try {
      final questionsService = ref.read(questionsApiServiceProvider);
      List<Map<String, dynamic>> fetchedQuestions;

      if (widget.category != null && widget.category!.isNotEmpty) {
        fetchedQuestions = await questionsService.getQuestionsByCategory(
          category: widget.category!,
          count: 10,
        );
      } else {
        fetchedQuestions = await questionsService.getRandomQuestions(
          count: 10,
          difficulty: widget.difficulty,
        );
      }

      if (fetchedQuestions.isEmpty) {
        throw Exception('No questions returned from server');
      }

      // Transform API questions to match expected format
      setState(() {
        questions = fetchedQuestions.map((q) {
          return {
            'id': q['id'],
            'question': q['text'],
            'options': List<String>.from(q['options']),
            'correctAnswer': q['correctAnswer'],
          };
        }).toList();
        isLoading = false;
      });

      startTimer();
    } catch (e) {
      // Fallback to offline questions if backend is unavailable
      final offlineQuestions = await _getOfflineQuestions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '⚠️ Playing offline mode - Using local questions',
            ),
            backgroundColor: Colors.orange.withOpacity(0.9),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      setState(() {
        questions = offlineQuestions;
        isLoading = false;
        errorMessage = null; // Clear error to allow play
      });

      if (questions.isNotEmpty) {
        startTimer();
      }
    }
  }

  void startTimer() {
    timeRemaining = 10;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() => timeRemaining--);
      } else {
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    if (!isAnswered) {
      setState(() {
        isAnswered = true;
      });
      timer?.cancel();
      Future.delayed(const Duration(seconds: 2), nextQuestion);
    }
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;

    final remainingForBonus = timeRemaining;
    final isCorrect = answer == currentQuestion['correctAnswer'];

    // Calculate time bonus according to formula: (remaining_seconds / 10) * 50
    // This gives 0-50 points based on speed
    // Example: 10 seconds remaining = 50 points, 5 seconds = 25 points, 0 seconds = 0 points
    final timeBonusForQuestion = isCorrect
        ? ((remainingForBonus / 10) * AppConstants.maxTimeBonus).round()
        : 0;

    // Calculate base points for correct answer
    final basePointsForQuestion = isCorrect
        ? AppConstants.basePointsPerCorrect
        : 0;

    // Total points for this question
    final totalPointsForQuestion = basePointsForQuestion + timeBonusForQuestion;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      if (isCorrect) {
        correctAnswers++;
        totalTimeBonus += timeBonusForQuestion;
        totalPoints += totalPointsForQuestion;

        // Track time bonus for this question (for display/debugging)
        questionTimeBonuses.add({
          'questionIndex': currentQuestionIndex,
          'timeBonus': timeBonusForQuestion,
          'remainingTime': remainingForBonus,
        });

        // Show time bonus feedback if earned
        if (timeBonusForQuestion > 0 && mounted) {
          final timeBonusXp = (timeBonusForQuestion / AppConstants.xpDivisor)
              .round();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Time Bonus: +$timeBonusForQuestion pts (+$timeBonusXp XP)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    timer?.cancel();
    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
        hiddenOptions.clear(); // Reset hidden options for new question
        timeRemaining = 10; // Reset timer for next question
      });
      startTimer();
    } else {
      finishQuiz();
    }
  }

  Future<void> _useBoost(BoostType boostType) async {
    if (isAnswered) return;

    final boostConfig = BoostConfig.all.firstWhere((b) => b.type == boostType);
    if (availableCoins < boostConfig.cost) {
      TopNotification.show(
        context,
        message: 'Not enough coins!',
        type: NotificationType.error,
      );
      return;
    }

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        TopNotification.show(
          context,
          message: 'Please login to use boosts',
          type: NotificationType.error,
        );
        return;
      }

      final dio = ref.read(dioProvider);
      final coinsService = CoinsApiService(dio);

      await coinsService.spendCoins(
        userId: userId,
        amount: boostConfig.cost,
        reason: 'boost_${boostType.name}',
      );

      // Update local coins
      setState(() {
        availableCoins -= boostConfig.cost;
        usedBoosts.add(boostType);
      });

      // Apply boost effect
      switch (boostType) {
        case BoostType.extraTime:
          setState(() {
            timeRemaining += 5;
          });
          TopNotification.show(
            context,
            message: '+5 seconds added!',
            type: NotificationType.success,
          );
          break;
        case BoostType.skip:
          setState(() {
            isAnswered = true;
          });
          timer?.cancel();
          TopNotification.show(
            context,
            message: 'Question skipped!',
            type: NotificationType.info,
          );
          Future.delayed(const Duration(seconds: 1), nextQuestion);
          break;
        case BoostType.revealWrong:
          _revealWrongOption();
          break;
      }

      // Update user data in storage (refresh from API)
      final updatedUserId = StorageService.instance.getUserId();
      if (updatedUserId != null) {
        final dio = ref.read(dioProvider);
        final usersService = UsersApiService(dio);
        try {
          final updatedUser = await usersService.getUserById(updatedUserId);
          StorageService.instance.saveUserData(updatedUser);
        } catch (e) {
          // Silently fail - coins are already updated on server
        }
      }
    } catch (e) {
      TopNotification.show(
        context,
        message: 'Failed to use boost: ${e.toString()}',
        type: NotificationType.error,
      );
    }
  }

  void _revealWrongOption() {
    final currentQ = currentQuestion;
    if (currentQ.isEmpty) return;

    final options = List<String>.from(currentQ['options'] ?? []);
    final correctAnswer = currentQ['correctAnswer'];

    // Find wrong options that haven't been hidden yet
    final wrongOptions = options
        .where((opt) => opt != correctAnswer && !hiddenOptions.contains(opt))
        .toList();

    if (wrongOptions.isNotEmpty) {
      // Hide one random wrong option
      wrongOptions.shuffle();
      final toHide = wrongOptions.first;

      setState(() {
        hiddenOptions.add(toHide);
      });

      TopNotification.show(
        context,
        message: 'One wrong option removed!',
        type: NotificationType.success,
      );
    }
  }

  void finishQuiz() {
    timer?.cancel();

    // Safety check for empty questions
    if (questions.isEmpty) {
      context.pop();
      return;
    }

    // Calculate XP according to formula: TotalPoints / xpDivisor
    // TotalPoints = (basePointsPerCorrect * correctAnswers) + totalTimeBonus
    final basePoints = correctAnswers * AppConstants.basePointsPerCorrect;
    final totalPointsEarned = basePoints + totalTimeBonus;
    final xpGained = (totalPointsEarned / AppConstants.xpDivisor).round();

    // Base XP (without time bonus) for display
    final baseXp = (basePoints / AppConstants.xpDivisor).round();

    // Calculate coins: +1 coin per 2 correct answers (as per README)
    final coinsGained =
        (correctAnswers / 2).floor() * AppConstants.coinsPerTwoCorrect;
    // Ensure minimum 1 coin per correct answer if needed, or use fixed amount
    final coinsGainedFinal = coinsGained > 0
        ? coinsGained
        : correctAnswers * 10;

    final result = {
      'totalQuestions': questions.length,
      'correctAnswers': correctAnswers,
      'accuracy': questions.isNotEmpty
          ? (correctAnswers / questions.length * 100).toInt()
          : 0,
      'xpGained': xpGained,
      'timeBonus': totalTimeBonus, // Time bonus in points
      'timeBonusXp': (totalTimeBonus / AppConstants.xpDivisor)
          .round(), // Time bonus converted to XP
      'baseXp': baseXp,
      'totalPoints': totalPointsEarned,
      'basePoints': basePoints,
      'coinsGained': coinsGainedFinal,
    };
    context.go(RouteNames.soloModeResults, extra: result);
  }

  Map<String, dynamic> get currentQuestion {
    if (questions.isEmpty) return {};
    if (currentQuestionIndex >= questions.length) return {};
    return questions[currentQuestionIndex];
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const FootballLoadingScreen(message: 'Loading Questions...');
    }

    // Safety check for empty questions
    if (questions.isEmpty || currentQuestion.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/background1.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.95),
                BlendMode.lighten,
              ),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No questions available',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please check your connection',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95),
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}/${questions.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: timeRemaining <= 3
                            ? AppColors.error
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$timeRemaining',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Boosts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GameBoosts(
                  availableCoins: availableCoins,
                  usedBoosts: usedBoosts,
                  isAnswered: isAnswered,
                  onBoostUsed: _useBoost,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: QuestionDisplay(
                    question: currentQuestion,
                    selectedAnswer: selectedAnswer,
                    isAnswered: isAnswered,
                    onAnswerSelected: (answer) {
                      if (!isAnswered) {
                        selectAnswer(answer);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
