import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/network/questions_api_service.dart';
import '../../../core/network/stake_match_api_service.dart';
import '../../../core/models/stake_match.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/football_loading.dart';
import '../../../shared/widgets/question_display.dart';
import '../../../shared/widgets/top_notification.dart';

class StakeMatchGameScreen extends ConsumerStatefulWidget {
  final StakeMatch match;
  final bool isCreator;

  const StakeMatchGameScreen({
    super.key,
    required this.match,
    required this.isCreator,
  });

  @override
  ConsumerState<StakeMatchGameScreen> createState() => _StakeMatchGameScreenState();
}

class _StakeMatchGameScreenState extends ConsumerState<StakeMatchGameScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int timeRemaining = 15; // 15 seconds per question for stake matches
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  bool isLoading = true;
  String? errorMessage;
  int totalScore = 0;
  List<Map<String, dynamic>> questionResults = [];

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      print('🎮 Loading questions for Stake Match...');
      print('   Match ID: ${widget.match.id}');
      print('   Number of Questions: ${widget.match.numberOfQuestions}');
      print('   Difficulty: ${widget.match.difficulty}');
      
      final questionsService = ref.read(questionsApiServiceProvider);
      
      // Use default values if not set
      final count = widget.match.numberOfQuestions > 0 ? widget.match.numberOfQuestions : 10;
      final difficulty = widget.match.difficulty?.isNotEmpty == true ? widget.match.difficulty : null;
      
      print('   Requesting: count=$count, difficulty=$difficulty');
      
      final loadedQuestions = await questionsService.getRandomQuestions(
        count: count,
        difficulty: difficulty,
      );

      print('   ✅ Loaded ${loadedQuestions.length} questions');

      if (loadedQuestions.isEmpty) {
        throw Exception('No questions available');
      }

      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });

      _startTimer();
    } catch (e, stackTrace) {
      print('❌ Error loading questions: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Failed to load questions: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _startTimer() {
    timer?.cancel();
    timeRemaining = 15;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          // Time's up - treat as wrong answer
          _handleAnswer('', isTimeout: true);
        }
      });
    });
  }

  void _handleAnswer(String answer, {bool isTimeout = false}) {
    if (isAnswered) return;

    timer?.cancel();

    final question = questions[currentQuestionIndex];
    final correctAnswer = question['correctAnswer'] as String;
    final isCorrect = answer == correctAnswer && !isTimeout;

    // Calculate score: 100 points + time bonus (up to 50 points)
    int questionScore = 0;
    if (isCorrect) {
      questionScore = 100 + (timeRemaining * 3); // Up to 45 bonus points
      correctAnswers++;
    }

    totalScore += questionScore;

    questionResults.add({
      'question': question['text'] ?? question['question'],
      'selectedAnswer': answer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timeSpent': 15 - timeRemaining,
      'score': questionScore,
    });

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    // Wait 2 seconds before moving to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          isAnswered = false;
        });
        _startTimer();
      } else {
        _finishMatch();
      }
    });
  }

  Future<void> _finishMatch() async {
    timer?.cancel();

    try {
      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);
      final userId = StorageService.instance.getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Submit match completion
      final updatedMatch = await stakeMatchService.completeStakeMatch(
        matchId: widget.match.id,
        userId: userId,
        score: totalScore,
      );

      if (mounted) {
        // Navigate to results screen
        context.go(
          RouteNames.stakeMatchResults,
          extra: {
            'match': updatedMatch,
            'myScore': totalScore,
            'correctAnswers': correctAnswers,
            'totalQuestions': questions.length,
            'questionResults': questionResults,
            'isCreator': widget.isCreator,
          },
        );
      }
    } catch (e) {
      print('❌ Error submitting match: $e');
      if (mounted) {
        TopNotification.show(
          context,
          message: 'Error submitting match: ${e.toString()}',
          type: NotificationType.error,
        );
        // Still navigate to results
        context.go(RouteNames.home);
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: FootballLoading()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading questions',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.stakeMatch),
                child: const Text('Back to Stake Match'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit Match?'),
            content: const Text(
              'Are you sure you want to quit? You will lose your stake!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Quit'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.3),
            title: Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Stake Match',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    '${widget.match.stakeAmount} coins',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Score: $totalScore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),

                // Question info
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1}/${questions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: timeRemaining <= 5
                              ? Colors.red.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: timeRemaining <= 5
                                ? Colors.red
                                : AppColors.primary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: timeRemaining <= 5
                                  ? Colors.red
                                  : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$timeRemaining s',
                              style: TextStyle(
                                color: timeRemaining <= 5
                                    ? Colors.red
                                    : AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Question display
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child:                     QuestionDisplay(
                      question: question,
                      selectedAnswer: selectedAnswer,
                      isAnswered: isAnswered,
                      onAnswerSelected: _handleAnswer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

