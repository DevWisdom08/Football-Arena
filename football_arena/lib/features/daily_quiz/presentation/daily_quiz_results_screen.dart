import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/network/daily_quiz_api_service.dart';
import '../../../core/network/users_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/top_notification.dart';

class DailyQuizResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? result;

  const DailyQuizResultsScreen({super.key, this.result});

  @override
  ConsumerState<DailyQuizResultsScreen> createState() =>
      _DailyQuizResultsScreenState();
}

class _DailyQuizResultsScreenState
    extends ConsumerState<DailyQuizResultsScreen> {
  bool _isProtecting = false;
  bool _streakProtected = false;

  Future<void> _protectStreak(String method) async {
    final userId = StorageService.instance.getUserId();
    if (userId == null) {
      TopNotification.show(
        context,
        message: context.l10n.pleaseLoginToProtectStreak,
        type: NotificationType.error,
      );
      return;
    }

    setState(() => _isProtecting = true);

    try {
      final dailyQuizService = ref.read(dailyQuizApiServiceProvider);
      final result = await dailyQuizService.protectStreak(
        userId: userId,
        method: method,
      );

      if (!mounted) return;

      setState(() {
        _streakProtected = true;
        _isProtecting = false;
      });

      // Refresh user data
      final usersService = ref.read(usersApiServiceProvider);
      final updatedUser = await usersService.getUserById(userId);
      StorageService.instance.saveUserData(updatedUser);

      TopNotification.show(
        context,
        message: context.l10n.streakProtectedSuccessfully,
        type: NotificationType.success,
      );

      // Update streak in result
      widget.result?['streak'] = result['streak'];
      widget.result?['wouldBreakStreak'] = false;
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProtecting = false);

      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  void _showStreakProtectionDialog() {
    final userId = StorageService.instance.getUserId();
    if (userId == null) return;

    final userData = StorageService.instance.getUserData();
    final userCoins = userData?['coins'] ?? 0;
    final isVip = userData?['isVip'] ?? false;
    final currentStreak = widget.result?['currentStreak'] ?? 1;
    final protectionCost = 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.protectYourStreak,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade700, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.currentStreak(currentStreak),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.streakProtectionDescription,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (isVip) ...[
                CustomButton(
                  text: context.l10n.protectWithVip,
                  type: ButtonType.gradient,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.pink.shade600],
                  ),
                  icon: Icons.star,
                  onPressed: _isProtecting
                      ? null
                      : () {
                          Navigator.pop(context);
                          _protectStreak('vip');
                        },
                ),
                const SizedBox(height: 12),
              ],
              CustomButton(
                text: context.l10n.protectWithCoins(protectionCost),
                type: isVip ? ButtonType.outlined : ButtonType.gradient,
                gradient: isVip ? null : AppColors.primaryGradient,
                icon: Icons.monetization_on,
                onPressed: _isProtecting || userCoins < protectionCost
                    ? null
                    : () {
                        Navigator.pop(context);
                        _protectStreak('coins');
                      },
              ),
              if (userCoins < protectionCost) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.notEnoughCoinsForProtection,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.noThanks,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No results available'),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final totalQuestions = widget.result!['totalQuestions'] ?? 15;
    final correctAnswers = widget.result!['correctAnswers'] ?? 0;
    final accuracy = widget.result!['accuracy'] ?? 0;
    final xpGained = widget.result!['xpGained'] ?? 150;
    final coinsGained = widget.result!['coinsGained'] ?? 75;
    final streak = _streakProtected
        ? (widget.result!['currentStreak'] ?? 1)
        : (widget.result!['streak'] ?? 1);
    final wouldBreakStreak = widget.result!['wouldBreakStreak'] ?? false;

    final isPerfect = correctAnswers == totalQuestions;
    final isGoodScore = accuracy >= 70;

    // Show protection dialog if streak would be broken
    if (wouldBreakStreak && !_streakProtected && !_isProtecting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStreakProtectionDialog();
      });
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
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.dailyQuizGradient,
                ),
                child: Column(
                  children: [
                    Icon(
                      isPerfect
                          ? Icons.emoji_events
                          : isGoodScore
                          ? Icons.celebration
                          : Icons.thumb_up,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isPerfect
                          ? '🏆 Perfect Score!'
                          : isGoodScore
                          ? '🎉 Great Job!'
                          : '👍 Good Try!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Daily Quiz Completed',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Accuracy Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400.withOpacity(0.15),
                              Colors.blue.shade700.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Your Accuracy',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$accuracy%',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..shader = AppColors.primaryGradient
                                      .createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$correctAnswers correct out of $totalQuestions',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rewards Grid
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400.withOpacity(0.15),
                                    Colors.purple.shade700.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.15),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '+$xpGained',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'XP Earned',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade400.withOpacity(0.15),
                                    Colors.amber.shade700.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.15),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '+$coinsGained',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Coins Earned',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Streak Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _streakProtected
                                ? [
                                    Colors.green.shade400.withOpacity(0.15),
                                    Colors.teal.shade600.withOpacity(0.15),
                                  ]
                                : wouldBreakStreak
                                ? [
                                    Colors.red.shade400.withOpacity(0.15),
                                    Colors.orange.shade600.withOpacity(0.15),
                                  ]
                                : [
                                    Colors.orange.shade400.withOpacity(0.15),
                                    Colors.red.shade600.withOpacity(0.15),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _streakProtected
                                ? Colors.green.withOpacity(0.5)
                                : wouldBreakStreak
                                ? Colors.red.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _streakProtected
                                  ? Colors.green.withOpacity(0.15)
                                  : wouldBreakStreak
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _streakProtected
                                  ? Icons.shield
                                  : wouldBreakStreak
                                  ? Icons.warning
                                  : Icons.local_fire_department,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _streakProtected
                                        ? context.l10n.streakProtected(streak)
                                        : wouldBreakStreak
                                        ? context.l10n.streakBroken
                                        : '$streak ${context.l10n.dayStreak}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _streakProtected
                                        ? context.l10n.streakProtectedMessage
                                        : wouldBreakStreak
                                        ? context.l10n.streakBrokenMessage
                                        : context.l10n.keepPlayingDaily,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (wouldBreakStreak && !_streakProtected) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warning.withOpacity(0.15),
                                Colors.orange.shade700.withOpacity(0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.7),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.warning,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.l10n.protectStreakNow,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.protectStreakDescription,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: _isProtecting
                                    ? 'Protecting...'
                                    : 'Protect My Streak',
                                type: ButtonType.gradient,
                                gradient: AppColors.primaryGradient,
                                icon: Icons.shield,
                                onPressed: _isProtecting
                                    ? null
                                    : _showStreakProtectionDialog,
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (isPerfect) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade400.withOpacity(0.15),
                                Colors.pink.shade600.withOpacity(0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stars, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Perfect Score Bonus!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Next quiz info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade400.withOpacity(0.15),
                              Colors.cyan.shade700.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.cyan[300],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Come back tomorrow for a new daily quiz!\n'
                                'Maintain your streak for bonus rewards.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () => context.go(RouteNames.home),
                      gradient: AppColors.primaryGradient,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'View Leaderboard',
                      onPressed: () => context.push(RouteNames.leaderboard),
                      type: ButtonType.outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
