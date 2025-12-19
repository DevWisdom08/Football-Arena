import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/network/questions_api_service.dart';
import '../../../core/network/stake_match_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/football_loading.dart';
import '../../../shared/widgets/question_display.dart';
import '../../../shared/widgets/top_notification.dart';
import 'widgets/stake_match_header.dart';

class StakeMatchGameScreen extends ConsumerStatefulWidget {
  final String matchId;
  final String opponentId;
  final String opponentUsername;
  final int stakeAmount;
  final String difficulty;
  final int questionCount;

  const StakeMatchGameScreen({
    super.key,
    required this.matchId,
    required this.opponentId,
    required this.opponentUsername,
    required this.stakeAmount,
    this.difficulty = 'mixed',
    this.questionCount = 10,
  });

  @override
  ConsumerState<StakeMatchGameScreen> createState() =>
      _StakeMatchGameScreenState();
}

class _StakeMatchGameScreenState extends ConsumerState<StakeMatchGameScreen> {
  int currentQuestionIndex = 0;
  int playerScore = 0;
  int opponentScore = 0; // Will be calculated by backend
  int timeRemaining = 15; // 15 seconds per question for stake matches
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;
  String playerUsername = 'You';

  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> playerAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
    _loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlayerData() async {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      setState(() {
        playerUsername = userData['username'] ?? 'You';
      });
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final questionsService = ref.read(questionsApiServiceProvider);

      // Load questions based on difficulty
      final loadedQuestions = await questionsService.getRandomQuestions(
        count: widget.questionCount,
        difficulty: widget.difficulty,
      );

      if (loadedQuestions.isEmpty) {
        setState(() {
          errorMessage = 'No questions available. Please try again.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        questions = loadedQuestions
            .map((q) => {
                  'id': q['id'],
                  'question': q['text'] ?? q['question'],
                  'text': q['text'] ?? q['question'],
                  'options': List<String>.from(q['options'] ?? []),
                  'correctAnswer': q['correctAnswer'],
                  'difficulty': q['difficulty'],
                })
            .toList();
        isLoading = false;
      });

      _startTimer();
    } catch (e) {
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
          // Time's up - auto submit with no answer
          _handleAnswer(null, isTimeout: true);
        }
      });
    });
  }

  void _handleAnswer(String? answer, {bool isTimeout = false}) {
    if (isAnswered) return;

    timer?.cancel();

    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = answer == currentQuestion['correctAnswer'];

    // Calculate points (100 base + time bonus)
    int questionPoints = 0;
    if (isCorrect) {
      questionPoints = 100 + (timeRemaining * 5); // 5 points per second remaining
      playerScore += questionPoints;
    }

    // Record answer
    playerAnswers.add({
      'questionId': currentQuestion['id'],
      'question': currentQuestion['question'],
      'selectedAnswer': answer,
      'correctAnswer': currentQuestion['correctAnswer'],
      'isCorrect': isCorrect,
      'timeSpent': 15 - timeRemaining,
      'points': questionPoints,
    });

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    // Move to next question after delay
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
        // Game finished - submit results
        _submitResults();
      }
    });
  }

  Future<void> _submitResults() async {
    setState(() => isSubmitting = true);

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);

      // Submit score to backend
      final result = await stakeMatchService.completeStakeMatch(
        matchId: widget.matchId,
        userId: userId,
        score: playerScore,
      );

      if (!mounted) return;

      // Calculate opponent score
      final isCreator = result.creatorId == userId;
      final opponentScore = isCreator ? result.opponentScore : result.creatorScore;
      
      // Calculate payout if match is completed
      int playerPayout = 0;
      if (result.status == 'completed' && result.winnerId == userId) {
        playerPayout = result.winnerPayout;
      }

      // Navigate to results screen
      context.pushReplacement(
        RouteNames.stakeMatchResults,
        extra: {
          'matchId': widget.matchId,
          'playerScore': playerScore,
          'opponentScore': opponentScore,
          'playerUsername': playerUsername,
          'opponentUsername': widget.opponentUsername,
          'stakeAmount': widget.stakeAmount,
          'winnerId': result.winnerId,
          'playerId': userId,
          'playerPayout': playerPayout,
          'status': result.status,
        },
      );
    } catch (e) {
      setState(() => isSubmitting = false);

      if (mounted) {
        TopNotification.show(
          context,
          message: 'Failed to submit results: ${e.toString()}',
          type: NotificationType.error,
        );
      }

      // Fallback: Navigate to results with local data
      if (mounted) {
        context.pushReplacement(
          RouteNames.stakeMatchResults,
          extra: {
            'matchId': widget.matchId,
            'playerScore': playerScore,
            'opponentScore': 0,
            'playerUsername': playerUsername,
            'opponentUsername': widget.opponentUsername,
            'stakeAmount': widget.stakeAmount,
            'error': e.toString(),
          },
        );
      }
    }
  }

  Color _getTimerColor() {
    if (timeRemaining > 10) return Colors.green;
    if (timeRemaining > 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FootballLoading(),
              const SizedBox(height: 24),
              Text(
                'Loading Stake Match...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stake: ${widget.stakeAmount} coins',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Error',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isSubmitting) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FootballLoading(),
              const SizedBox(height: 24),
              Text(
                'Submitting Results...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Calculating Winner...',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with match info
            Padding(
              padding: const EdgeInsets.all(16),
              child: StakeMatchHeader(
                stakeAmount: widget.stakeAmount,
                currentQuestion: currentQuestionIndex + 1,
                totalQuestions: questions.length,
                playerScore: playerScore,
                opponentScore: opponentScore,
                playerUsername: playerUsername,
                opponentUsername: widget.opponentUsername,
              ),
            ),

            // Timer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTimerColor().withOpacity(0.2),
                    _getTimerColor().withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTimerColor(), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: _getTimerColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$timeRemaining seconds',
                    style: TextStyle(
                      color: _getTimerColor(),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question Display
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionDisplay(
                  question: currentQuestion,
                  selectedAnswer: selectedAnswer,
                  onAnswerSelected: (answer) => _handleAnswer(answer),
                  isAnswered: isAnswered,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
