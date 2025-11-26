import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/daily_quiz_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/football_loading.dart';
import '../../../shared/widgets/top_notification.dart';

class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  bool isLoading = true;
  bool isAvailable = false;
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic>? completedAttempt;
  DateTime? nextAvailable;
  Map<String, dynamic>? rewards;
  Timer? countdownTimer;
  Duration? timeUntilNext;

  @override
  void initState() {
    super.initState();
    _loadDailyQuiz();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      setState(() {
        timeUntilNext = tomorrow.difference(now);
      });
    });
  }

  Future<void> _loadDailyQuiz() async {
    final userId = StorageService.instance.getUserId();
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final dailyQuizService = ref.read(dailyQuizApiServiceProvider);
      final data = await dailyQuizService.getDailyQuiz(userId);

      setState(() {
        isAvailable = data['available'] ?? false;

        if (isAvailable) {
          questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
          rewards = data['rewards'];
        } else {
          completedAttempt = data['attempt'];
          if (data['nextAvailable'] != null) {
            nextAvailable = DateTime.parse(data['nextAvailable']);
          }
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startQuiz() {
    if (questions.isNotEmpty) {
      context.go(
        RouteNames.dailyQuizGame,
        extra: {'questions': questions, 'rewards': rewards},
      );
    }
  }

  Widget _buildStreakProtectCard() {
    final userData = StorageService.instance.getUserData();
    final currentStreak = userData?['currentStreak'] ?? 0;
    final userCoins = userData?['coins'] ?? 0;
    final isVip = userData?['isVip'] ?? false;

    if (currentStreak < 3) {
      return const SizedBox.shrink(); // Don't show if streak is too low
    }

    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protect Your ${currentStreak}-Day Streak',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Protect your streak if you miss tomorrow',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: userCoins >= 100
                      ? () => _purchaseStreakProtect('coins')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userCoins >= 100
                        ? AppColors.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/icons/coin_icon.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.monetization_on, size: 18),
                  ),
                  label: const Text(
                    '100 Coins',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isVip ? () => _purchaseStreakProtect('vip') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVip ? Colors.amber : Colors.grey,
                    foregroundColor: isVip ? Colors.black : Colors.white54,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.verified, size: 18),
                  label: Text(
                    isVip ? 'Free VIP' : 'VIP Only',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseStreakProtect(String method) async {
    final userId = StorageService.instance.getUserId();
    if (userId == null) return;

    final userData = StorageService.instance.getUserData();
    final currentStreak = userData?['currentStreak'] ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Protect Your Streak?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          method == 'coins'
              ? 'Spend 100 coins to protect your $currentStreak-day streak?\n\nIf you miss tomorrow\'s quiz, your streak won\'t be lost.'
              : 'Use your VIP membership to protect your $currentStreak-day streak?\n\nIf you miss tomorrow\'s quiz, your streak won\'t be lost.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Protect'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final dailyQuizService = ref.read(dailyQuizApiServiceProvider);
      await dailyQuizService.protectStreak(userId: userId, method: method);

      if (mounted) {
        TopNotification.show(
          context,
          message: '✅ Streak protected! Safe for tomorrow.',
          type: NotificationType.success,
        );

        // Reload quiz data to reflect changes
        _loadDailyQuiz();
      }
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          type: NotificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const FootballLoadingScreen(message: 'Loading Daily Quiz...');
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/daily_quiz.jpg'),
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Daily Quiz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.dailyQuizGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (isAvailable) ...[
                        // Available - Show start button
                        const Text(
                          'Today\'s Quiz Ready!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.heading,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          '15 Special Questions',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),

                        const SizedBox(height: 32),

                        // Rewards Card
                        CustomCard(
                          gradient: AppColors.primaryGradient,
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Special Rewards',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildRewardItem(
                                    Icons.flash_on,
                                    '${rewards?['totalXP'] ?? 150} XP',
                                    'Experience',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white24,
                                  ),
                                  _buildRewardItem(
                                    Icons.monetization_on,
                                    '${rewards?['totalCoins'] ?? 75} Coins',
                                    'Currency',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '🔥 +Streak Bonus',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        CustomButton(
                          text: 'Start Daily Quiz',
                          onPressed: _startQuiz,
                          gradient: AppColors.dailyQuizGradient,
                          icon: Icons.play_arrow,
                        ),

                        const SizedBox(height: 20),

                        // Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.purple[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Daily Quiz Rules:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple[200],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Available once every 24 hours\n'
                                '• 15 questions (vs 10 in solo mode)\n'
                                '• Higher rewards than other modes\n'
                                '• Maintain streaks for bonus rewards\n'
                                '• Complete before midnight',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Not available - Already completed
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Quiz Completed!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.heading,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Come back tomorrow for a new quiz',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Streak Protect Option
                        _buildStreakProtectCard(),

                        const SizedBox(height: 24),

                        if (completedAttempt != null)
                          CustomCard(
                            backgroundColor: AppColors.cardBackground,
                            child: Column(
                              children: [
                                const Text(
                                  'Today\'s Results',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat(
                                      'Accuracy',
                                      '${completedAttempt!['accuracy']?.toStringAsFixed(0) ?? 0}%',
                                    ),
                                    _buildStat(
                                      'Correct',
                                      '${completedAttempt!['correctAnswers']}/${completedAttempt!['totalQuestions']}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat(
                                      'XP Earned',
                                      '+${completedAttempt!['xpGained']}',
                                    ),
                                    _buildStat(
                                      'Coins Earned',
                                      '+${completedAttempt!['coinsGained']}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Countdown to next quiz
                        if (timeUntilNext != null)
                          CustomCard(
                            gradient: AppColors.dailyQuizGradient,
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.timer, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Next Quiz In:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _formatDuration(timeUntilNext!),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
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
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
