import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/daily_quiz_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/question_display.dart';

class DailyQuizGameScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic>? rewards;

  const DailyQuizGameScreen({super.key, required this.questions, this.rewards});

  @override
  ConsumerState<DailyQuizGameScreen> createState() =>
      _DailyQuizGameScreenState();
}

class _DailyQuizGameScreenState extends ConsumerState<DailyQuizGameScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int timeRemaining = 10;
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  List<Map<String, dynamic>> userAnswers = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    startTimer();
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
      selectAnswer('');
    }
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;

    final currentQuestion = widget.questions[currentQuestionIndex];
    final correct = answer == currentQuestion['correctAnswer'];

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      if (correct) correctAnswers++;
    });

    // Record answer
    userAnswers.add({
      'questionId': currentQuestion['id'],
      'answer': answer,
      'correct': correct,
    });

    timer?.cancel();
    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
      });
      startTimer();
    } else {
      finishQuiz();
    }
  }

  Future<void> finishQuiz() async {
    timer?.cancel();
    setState(() => isSubmitting = true);

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) throw Exception('User not found');

      final dailyQuizService = ref.read(dailyQuizApiServiceProvider);
      final result = await dailyQuizService.submitDailyQuiz(
        userId: userId,
        answers: userAnswers,
      );

      if (!mounted) return;

      final accuracy = (correctAnswers / widget.questions.length * 100).toInt();
      final wouldBreakStreak = result['wouldBreakStreak'] ?? false;
      final currentStreak = result['currentStreak'] ?? 1;

      // Update local user data with new coins, XP, and streak
      final userData = StorageService.instance.getUserData();
      if (userData != null && result['user'] != null) {
        userData['coins'] = result['user']['coins'];
        userData['xp'] = result['user']['xp'];
        userData['level'] = result['user']['level'];
        userData['currentStreak'] = result['user']['currentStreak'];
        userData['longestStreak'] = result['user']['longestStreak'];
        userData['totalGames'] = result['user']['totalGames'];
        userData['accuracyRate'] = result['user']['accuracyRate'];
        userData['winRate'] = result['user']['winRate'];
        await StorageService.instance.saveUserData(userData);
      }

      final resultData = {
        'totalQuestions': widget.questions.length,
        'correctAnswers': correctAnswers,
        'accuracy': accuracy,
        'xpGained': result['rewards']['totalXP'] ?? 150,
        'coinsGained': result['rewards']['totalCoins'] ?? 75,
        'streak': result['rewards']['streak'] ?? 1,
        'wouldBreakStreak': wouldBreakStreak,
        'currentStreak': currentStreak,
        'isDaily': true,
      };

      context.go(RouteNames.dailyQuizResults, extra: resultData);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting quiz: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      setState(() => isSubmitting = false);
    }
  }

  Map<String, dynamic> get currentQuestion =>
      widget.questions[currentQuestionIndex];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20),
                Text(
                  'Submitting your results...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
              // Header with special daily quiz badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.dailyQuizGradient,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Daily Quiz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${timeRemaining}s',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: timeRemaining <= 3
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Correct: $correctAnswers',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value:
                          (currentQuestionIndex + 1) / widget.questions.length,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Question Display
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
