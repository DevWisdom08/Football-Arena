import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/network/friends_api_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/football_loading.dart';
import '../../../shared/widgets/top_notification.dart';
import '../../../shared/widgets/question_display.dart';

class Challenge1v1GameScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String opponent;

  const Challenge1v1GameScreen({
    super.key,
    required this.roomId,
    required this.opponent,
  });

  @override
  ConsumerState<Challenge1v1GameScreen> createState() =>
      _Challenge1v1GameScreenState();
}

class _Challenge1v1GameScreenState
    extends ConsumerState<Challenge1v1GameScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? currentQuestion;
  int questionNumber = 0;
  int totalQuestions = 10;
  int myScore = 0;
  int opponentScore = 0;
  int timeRemaining = 10;
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  bool waitingForReady = true;
  bool opponentReady = false;
  bool opponentAnswered = false;
  int startTime = 0;
  String momentumText = 'Neutral Play';
  Color momentumColor = Colors.white70;
  IconData momentumIcon = Icons.sports_soccer;
  
  // Attack/Counter-Attack animations
  late AnimationController _attackAnimationController;
  late AnimationController _counterAnimationController;
  late Animation<double> _attackScaleAnimation;
  late Animation<double> _attackRotationAnimation;
  late Animation<double> _counterScaleAnimation;
  late Animation<Color?> _attackColorAnimation;
  late Animation<Color?> _counterColorAnimation;
  bool _showAttackEffect = false;
  bool _showCounterEffect = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize attack animation
    _attackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _attackScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _attackAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _attackRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _attackAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _attackColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.primary.withOpacity(0.3),
    ).animate(_attackAnimationController);
    
    // Initialize counter-attack animation
    _counterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _counterScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _counterAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _counterColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.redAccent.withOpacity(0.3),
    ).animate(_counterAnimationController);
    
    // Defer socket operations until after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
      _sendPlayerReady();
    });
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);

    socketService.onPlayerReady((data) {
      setState(() {
        opponentReady = true;
      });
    });

    socketService.onGameStarted((data) {
      setState(() {
        waitingForReady = false;
        currentQuestion = data['question'];
        questionNumber = data['questionNumber'];
        totalQuestions = data['totalQuestions'];
        startTime = DateTime.now().millisecondsSinceEpoch;
      });
      _startTimer();
    });

    socketService.onAnswerResult((data) {
      final correct = data['correct'] as bool;
      final attackResult = data['attackResult'] as String?;
      setState(() {
        myScore = data['score'];
        _updateMomentum(attackResult, isPlayer: true, wasCorrect: correct);
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? '✓ Correct!' : '✗ Wrong answer!'),
          backgroundColor: correct ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    });

    socketService.onOpponentAnswered((data) {
      setState(() {
        opponentAnswered = true;
        final result = data['attackResult'] as String?;
        final correct = data['correct'] as bool? ?? false;
        _updateMomentum(result, isPlayer: false, wasCorrect: correct);
      });
    });

    socketService.onNextQuestion((data) {
      setState(() {
        currentQuestion = data['question'];
        questionNumber = data['questionNumber'];
        myScore = data['scores']['player1'] ?? myScore;
        opponentScore = data['scores']['player2'] ?? opponentScore;
        selectedAnswer = null;
        isAnswered = false;
        opponentAnswered = false;
        startTime = DateTime.now().millisecondsSinceEpoch;
        momentumText = 'Neutral Play';
        momentumColor = Colors.white70;
        momentumIcon = Icons.sports_soccer;
      });
      _startTimer();
    });

    socketService.onGameFinished((data) {
      timer?.cancel();
      _showResults(data);
    });

    socketService.onOpponentDisconnected((data) {
      timer?.cancel();
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Opponent Disconnected'),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  context.go(RouteNames.home);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _sendPlayerReady() {
    final socketService = ref.read(socketServiceProvider);
    socketService.playerReady(widget.roomId);
  }

  void _startTimer() {
    timeRemaining = 10;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() => timeRemaining--);
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (!isAnswered) {
      _submitAnswer('');
    }
  }

  void _selectAnswer(String answer) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    timer?.cancel();
    _submitAnswer(answer);
  }

  void _submitAnswer(String answer) {
    final socketService = ref.read(socketServiceProvider);
    final timeSpent = DateTime.now().millisecondsSinceEpoch - startTime;

    socketService.submitAnswer(
      roomId: widget.roomId,
      questionId: currentQuestion?['id'] ?? '',
      answer: answer,
      timeSpent: timeSpent,
    );
  }

  void _updateMomentum(
    String? attackResult, {
    required bool isPlayer,
    required bool wasCorrect,
  }) {
    if (attackResult != null && attackResult.isNotEmpty) {
      switch (attackResult) {
        case 'attack':
          momentumText = isPlayer ? 'You attack!' : '${widget.opponent} attacks!';
          momentumColor = AppColors.primary;
          momentumIcon = Icons.flash_on;
          if (isPlayer) {
            _triggerAttackAnimation();
          }
          break;
        case 'counter':
          momentumText = isPlayer ? 'Counter Attack!' : '${widget.opponent} countered!';
          momentumColor = Colors.redAccent;
          momentumIcon = Icons.shield;
          if (isPlayer) {
            _triggerCounterAnimation();
          }
          break;
        default:
          momentumText = attackResult;
          momentumColor = AppColors.heading;
          momentumIcon = Icons.sports_soccer;
      }
    } else {
      if (wasCorrect) {
        momentumText = isPlayer ? 'You lead this play' : '${widget.opponent} leads this play';
        momentumColor = AppColors.primaryLight;
        momentumIcon = Icons.trending_up;
      } else {
        momentumText = isPlayer ? 'You lost the ball' : '${widget.opponent} lost the ball';
        momentumColor = Colors.redAccent;
        momentumIcon = Icons.trending_down;
      }
    }
  }
  
  void _triggerAttackAnimation() {
    setState(() {
      _showAttackEffect = true;
    });
    _attackAnimationController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showAttackEffect = false;
          });
        }
      });
    });
  }
  
  void _triggerCounterAnimation() {
    setState(() {
      _showCounterEffect = true;
    });
    _counterAnimationController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showCounterEffect = false;
          });
        }
      });
    });
  }

  void _showResults(Map<String, dynamic> data) {
    final winner = data['winner'];
    final player1 = data['player1'];
    final player2 = data['player2'];
    final player1UserId = player1['userId'];
    final player2UserId = player2['userId'];
    final summaryText =
        '1v1 Challenge: ${player1['username']} ${player1['score']} - ${player2['score']} ${player2['username']}';
    
    // Determine which player is the current user
    final currentUserId = StorageService.instance.getUserId();
    final isPlayer1 = currentUserId == player1UserId;
    final currentUsername = isPlayer1 ? player1['username'] : player2['username'];
    final opponentUserId = isPlayer1 ? player2UserId : player1UserId;
    final opponentUsername = isPlayer1 ? player2['username'] : player1['username'];

    // Determine if current user won
    final didIWin = winner != 'Draw' && winner == currentUsername;

    // Update local user data if provided by backend
    if (data['updatedUsers'] != null && currentUserId != null) {
      final updatedUser = data['updatedUsers'][currentUserId];
      if (updatedUser != null) {
        final userData = StorageService.instance.getUserData();
        if (userData != null) {
          userData['coins'] = updatedUser['coins'];
          userData['xp'] = updatedUser['xp'];
          userData['level'] = updatedUser['level'];
          userData['totalGames'] = updatedUser['totalGames'];
          userData['challenge1v1Played'] = updatedUser['challenge1v1Played'];
          userData['accuracyRate'] = updatedUser['accuracyRate'];
          userData['winRate'] = updatedUser['winRate'];
          StorageService.instance.saveUserData(userData);
        }
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          winner == 'Draw'
              ? '🤝 Draw!'
              : didIWin
              ? '🎉 You Won!'
              : '😢 You Lost',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.heading,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayerResult(
              player1['username'],
              player1['score'],
              player1['correctAnswers'],
              isPlayer1,
            ),
            const SizedBox(height: 20),
            const Text(
              'VS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            _buildPlayerResult(
              player2['username'],
              player2['score'],
              player2['correctAnswers'],
              !isPlayer1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final socketService = ref.read(socketServiceProvider);
              socketService.disconnect();
              context.go(RouteNames.home);
            },
            child: const Text('Go Home'),
          ),
          TextButton(
            onPressed: () async {
              await _sendFriendRequest(opponentUserId, opponentUsername);
            },
            child: const Text('Add Friend'),
          ),
          TextButton(
            onPressed: () {
              Share.share(
                '${winner == 'Draw' ? 'Draw!' : '$winner won!'} $summaryText',
              );
            },
            child: const Text('Share'),
          ),
          ElevatedButton(
            onPressed: () {
              final socketService = ref.read(socketServiceProvider);
              socketService.disconnect();
              context.go(RouteNames.challenge1v1);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendFriendRequest(String opponentUserId, String opponentUsername) async {
    try {
      final currentUserId = StorageService.instance.getUserId();
      if (currentUserId == null) {
      if (mounted) {
        TopNotification.show(
          context,
          message: 'Please login to add friends',
          type: NotificationType.error,
        );
      }
        return;
      }
      
      final dio = ref.read(dioProvider);
      final friendsService = FriendsApiService(dio);
      
      await friendsService.sendFriendRequest(
        senderId: currentUserId,
        receiverId: opponentUserId,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Close results dialog
        TopNotification.show(
          context,
          message: 'Friend request sent to $opponentUsername!',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        TopNotification.show(
          context,
          message: errorMessage.contains('Already') 
              ? 'Already friends or request pending'
              : 'Failed to send friend request',
          type: NotificationType.error,
        );
      }
    }
  }

  Widget _buildPlayerResult(
    String username,
    int score,
    int correct,
    bool isYou,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYou ? AppColors.primary : Colors.white24,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            username + (isYou ? ' (You)' : ''),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $score',
            style: const TextStyle(fontSize: 16, color: AppColors.primary),
          ),
          Text(
            'Correct: $correct/$totalQuestions',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _attackAnimationController.dispose();
    _counterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (waitingForReady) {
      return FootballLoadingScreen(
        message: opponentReady
            ? 'Get Ready!'
            : 'Waiting for ${widget.opponent}...',
      );
    }

    if (currentQuestion == null) {
      return const FootballLoadingScreen(
        message: 'Preparing Game...',
      );
    }

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: momentumColor.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          Icon(momentumIcon, color: momentumColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              momentumText,
                              style: TextStyle(
                                color: momentumColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward, color: Colors.white70, size: 18),
                        ],
                      ),
                    ),
                  ),
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Your score
                    _buildScoreCard('You', myScore, true),

                    // VS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Opponent score
                    _buildScoreCard(widget.opponent, opponentScore, false),
                  ],
                ),
              ),

              // Progress & Timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question $questionNumber/$totalQuestions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: timeRemaining <= 3
                                  ? Colors.red
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${timeRemaining}s',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: timeRemaining <= 3
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: questionNumber / totalQuestions,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Question Display
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      QuestionDisplay(
                        question: currentQuestion!,
                        selectedAnswer: selectedAnswer,
                        isAnswered: isAnswered,
                        onAnswerSelected: (answer) {
                          if (!isAnswered) {
                            _selectAnswer(answer);
                          }
                        },
                      ),

                      if (opponentAnswered)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.opponent} answered',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
                ],
              ),
              
              // Attack visual effect overlay
              if (_showAttackEffect)
                AnimatedBuilder(
                  animation: _attackAnimationController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _attackColorAnimation.value,
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: _attackScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _attackRotationAnimation.value * 3.14159 * 2,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.8),
                                        AppColors.primary.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              // Counter-attack visual effect overlay
              if (_showCounterEffect)
                AnimatedBuilder(
                  animation: _counterAnimationController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _counterColorAnimation.value,
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: _counterScaleAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.redAccent.withOpacity(0.8),
                                      Colors.redAccent.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String name, int score, bool isYou) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isYou ? AppColors.primary : Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isYou ? AppColors.primary : Colors.white,
          ),
        ),
      ],
    );
  }
}
