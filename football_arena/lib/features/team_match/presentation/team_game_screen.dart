import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/question_display.dart';

class TeamGameScreen extends ConsumerStatefulWidget {
  final String roomId;
  final Map<String, dynamic>? initialQuestion;

  const TeamGameScreen({super.key, required this.roomId, this.initialQuestion});

  @override
  ConsumerState<TeamGameScreen> createState() => _TeamGameScreenState();
}

class _TeamGameScreenState extends ConsumerState<TeamGameScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? currentQuestion;
  int questionNumber = 0;
  int totalQuestions = 10;
  int myScore = 0;
  int teamAScore = 0;
  int teamBScore = 0;
  String lastRoundResult = 'Match starting';
  Color lastRoundColor = Colors.white70;
  int timeRemaining = 10;
  Timer? timer;
  String? selectedAnswer;
  bool isAnswered = false;
  int startTime = 0;
  List<String> recentAnswers = [];

  // Animation controllers for round animations
  late AnimationController _roundResultController;
  late AnimationController _scorePulseController;
  late AnimationController _teamCelebrationController;
  late Animation<double> _roundResultFade;
  late Animation<double> _roundResultScale;
  late Animation<double> _scorePulse;
  late Animation<double> _celebrationScale;

  bool _showRoundResult = false;
  String? _winningTeam;
  int _prevTeamAScore = 0;
  int _prevTeamBScore = 0;

  @override
  void initState() {
    super.initState();
    currentQuestion = widget.initialQuestion;

    // Initialize animation controllers
    _roundResultController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scorePulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _teamCelebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _roundResultFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _roundResultController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _roundResultScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _roundResultController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _scorePulse = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scorePulseController, curve: Curves.easeInOut),
    );
    _celebrationScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _teamCelebrationController,
        curve: Curves.elasticOut,
      ),
    );

    if (currentQuestion != null) {
      startTime = DateTime.now().millisecondsSinceEpoch;
      _startTimer();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);

    socketService.onTeamAnswerResult((data) {
      final correct = data['correct'] as bool;
      setState(() {
        myScore = data['yourScore'] ?? myScore;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? '✓ Correct! +100' : '✗ Wrong answer'),
          backgroundColor: correct ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    });

    socketService.onTeamPlayerAnswered((data) {
      final username = data['username'];
      final team = data['team'];

      setState(() {
        recentAnswers.insert(0, '$username (Team $team)');
        if (recentAnswers.length > 3) recentAnswers.removeLast();
      });
    });

    socketService.onTeamNextQuestion((data) {
      setState(() {
        _prevTeamAScore = teamAScore;
        _prevTeamBScore = teamBScore;
        final newTeamAScore = data['teamAScore'] ?? 0;
        final newTeamBScore = data['teamBScore'] ?? 0;

        // Determine round winner before updating scores
        if (newTeamAScore > _prevTeamAScore ||
            newTeamBScore > _prevTeamBScore) {
          if (newTeamAScore > _prevTeamAScore &&
              newTeamAScore > newTeamBScore) {
            _winningTeam = 'A';
            lastRoundResult = 'Team A won the round!';
            lastRoundColor = Colors.blueAccent;
          } else if (newTeamBScore > _prevTeamBScore &&
              newTeamBScore > newTeamAScore) {
            _winningTeam = 'B';
            lastRoundResult = 'Team B won the round!';
            lastRoundColor = Colors.redAccent;
          } else if (newTeamAScore == newTeamBScore &&
              newTeamAScore > _prevTeamAScore) {
            _winningTeam = null;
            lastRoundResult = 'Round tied!';
            lastRoundColor = Colors.amber;
          } else {
            _winningTeam = null;
            lastRoundResult = 'Round tied!';
            lastRoundColor = Colors.white70;
          }

          // Show round result animation
          _showRoundResultAnimation();
        }

        // Update scores with animation
        teamAScore = newTeamAScore;
        teamBScore = newTeamBScore;
        currentQuestion = data['question'];
        questionNumber = data['questionNumber'];
        totalQuestions = data['totalQuestions'];
        selectedAnswer = null;
        isAnswered = false;
        startTime = DateTime.now().millisecondsSinceEpoch;
        recentAnswers.clear();
      });

      // Start timer after animation delay
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _startTimer();
        }
      });
    });

    socketService.onTeamGameFinished((data) {
      timer?.cancel();
      _showResults(data);
    });
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

    socketService.teamSubmitAnswer(
      roomId: widget.roomId,
      questionId: currentQuestion?['id'] ?? '',
      answer: answer,
      timeSpent: timeSpent,
    );
  }

  void _showResults(Map<String, dynamic> data) {
    final winner = data['winner'];
    final teamA = data['teamA'];
    final teamB = data['teamB'];

    String? mvpId;
    int bestCorrect = -1;
    for (final team in [teamA, teamB]) {
      for (final p in List<Map<String, dynamic>>.from(team['players'] ?? [])) {
        final correct = p['correctAnswers'] ?? 0;
        if (correct > bestCorrect) {
          bestCorrect = correct;
          mvpId = p['userId'] as String?;
        }
      }
    }

    // Update local user data if provided by backend
    final currentUserId = StorageService.instance.getUserId();
    if (data['updatedUsers'] != null && currentUserId != null) {
      final updatedUser = data['updatedUsers'][currentUserId];
      if (updatedUser != null) {
        final userData = StorageService.instance.getUserData();
        if (userData != null) {
          userData['coins'] = updatedUser['coins'];
          userData['xp'] = updatedUser['xp'];
          userData['level'] = updatedUser['level'];
          userData['totalGames'] = updatedUser['totalGames'];
          userData['teamMatchesPlayed'] = updatedUser['teamMatchesPlayed'];
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
          winner == 'Draw' ? '🤝 Draw!' : '🎉 $winner Wins!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.heading,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTeamResult('Team A', teamA, Colors.blue, mvpId: mvpId),
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
              _buildTeamResult('Team B', teamB, Colors.red, mvpId: mvpId),
            ],
          ),
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
          ElevatedButton(
            onPressed: () {
              final socketService = ref.read(socketServiceProvider);
              socketService.disconnect();
              context.go(RouteNames.teamMatch);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamResult(
    String teamName,
    Map<String, dynamic> team,
    Color color, {
    String? mvpId,
  }) {
    final score = team['score'] ?? 0;
    final players = List<Map<String, dynamic>>.from(team['players'] ?? []);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            teamName + (mvpId != null ? '  |  MVP marked with ⭐' : ''),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          ...players.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (mvpId != null && p['userId'] == mvpId)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.star,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            p['username'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${p['score']} (${p['correctAnswers']}/$totalQuestions)',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoundResultAnimation() {
    setState(() {
      _showRoundResult = true;
    });

    // Trigger score pulse animation
    _scorePulseController.forward().then((_) {
      _scorePulseController.reverse();
    });

    // Trigger celebration animation for winning team
    if (_winningTeam != null) {
      _teamCelebrationController.forward().then((_) {
        _teamCelebrationController.reverse();
      });
    }

    // Show round result overlay
    _roundResultController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _roundResultController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showRoundResult = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _roundResultController.dispose();
    _scorePulseController.dispose();
    _teamCelebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with scores
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedBuilder(
                              animation: _scorePulse,
                              builder: (context, child) {
                                final shouldPulse =
                                    teamAScore > _prevTeamAScore;
                                return Transform.scale(
                                  scale: shouldPulse ? _scorePulse.value : 1.0,
                                  child: _buildTeamScoreCard(
                                    'Team A',
                                    teamAScore,
                                    Colors.blue,
                                    isWinning: _winningTeam == 'A',
                                  ),
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _scorePulse,
                              builder: (context, child) {
                                final shouldPulse =
                                    teamBScore > _prevTeamBScore;
                                return Transform.scale(
                                  scale: shouldPulse ? _scorePulse.value : 1.0,
                                  child: _buildTeamScoreCard(
                                    'Team B',
                                    teamBScore,
                                    Colors.red,
                                    isWinning: _winningTeam == 'B',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Score: $myScore',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

                  const SizedBox(height: 20),

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

                          if (recentAnswers.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Recent Answers:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...recentAnswers.map(
                                    (answer) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '• $answer',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Round Result Overlay
              if (_showRoundResult)
                AnimatedBuilder(
                  animation: _roundResultController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: Colors.black.withOpacity(
                            0.3 * _roundResultFade.value,
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: _roundResultScale.value,
                              child: Opacity(
                                opacity: _roundResultFade.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        lastRoundColor.withOpacity(0.9),
                                        lastRoundColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: lastRoundColor.withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_winningTeam != null)
                                        AnimatedBuilder(
                                          animation: _teamCelebrationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _celebrationScale.value,
                                              child: const Icon(
                                                Icons.emoji_events,
                                                size: 64,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      if (_winningTeam != null)
                                        const SizedBox(height: 16),
                                      Text(
                                        lastRoundResult,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildAnimatedScore(
                                            'Team A',
                                            teamAScore,
                                            Colors.blue,
                                            _winningTeam == 'A',
                                          ),
                                          const SizedBox(width: 24),
                                          const Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          _buildAnimatedScore(
                                            'Team B',
                                            teamBScore,
                                            Colors.red,
                                            _winningTeam == 'B',
                                          ),
                                        ],
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamScoreCard(
    String teamName,
    int score,
    Color color, {
    bool isWinning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinning ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isWinning ? Border.all(color: color, width: 2) : null,
        boxShadow: isWinning
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                teamName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (isWinning) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedScore(
    String teamName,
    int score,
    Color color,
    bool isWinning,
  ) {
    return Column(
      children: [
        Text(
          teamName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isWinning ? Colors.amber : color,
          ),
        ),
      ],
    );
  }
}
