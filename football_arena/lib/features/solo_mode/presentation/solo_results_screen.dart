import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/network/game_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/top_notification.dart';

class SoloResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? result;

  const SoloResultsScreen({super.key, this.result});

  @override
  ConsumerState<SoloResultsScreen> createState() => _SoloResultsScreenState();
}

class _SoloResultsScreenState extends ConsumerState<SoloResultsScreen> {
  bool _resultsSaved = false;

  @override
  void initState() {
    super.initState();
    _saveResultsToBackend();
  }

  Future<void> _saveResultsToBackend() async {
    if (_resultsSaved || widget.result == null) {
      debugPrint('Solo Results: Already saved or no result data');
      return;
    }

    final userId = StorageService.instance.getUserId();
    if (userId == null) {
      debugPrint('Solo Results: No user ID found');
      await _applyOfflineResultLocally();
      return;
    }

    debugPrint('Solo Results: Saving to backend for user $userId');

    try {
      final gameService = ref.read(gameApiServiceProvider);
      final response = await gameService.submitSoloResult(
        userId: userId,
        correctAnswers: widget.result!['correctAnswers'] ?? 0,
        totalQuestions: widget.result!['totalQuestions'] ?? 10,
        accuracy: widget.result!['accuracy'] ?? 0,
        xpGained: widget.result!['xpGained'] ?? 0,
        coinsGained: widget.result!['coinsGained'] ?? 0,
        score: widget.result!['totalPoints'] ?? 0,
      );

      debugPrint('Solo Results: Backend response received');
      debugPrint('Solo Results: Success = ${response['success']}');
      debugPrint('Solo Results: Level up = ${response['leveledUp']}');

      // Update local storage with new user data
      if (response['user'] != null) {
        final mergedUser = _mergeStatsIntoUser(
          Map<String, dynamic>.from(response['user']),
        );
        await StorageService.instance.saveUserData(mergedUser);
        debugPrint('Solo Results: User data saved to local storage');

        // Show success notification
        if (mounted) {
          TopNotification.show(
            context,
            message:
                '✅ Stats updated! +${widget.result!['xpGained']} XP, +${widget.result!['coinsGained']} Coins',
            type: NotificationType.success,
          );
        }
      }

      // Show level up notification if leveled up
      if (response['leveledUp'] == true && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showLevelUpDialog(
              response['newLevel'] ?? 1,
              response['user']?['coins'] ?? 0,
            );
          }
        });
      }

      setState(() {
        _resultsSaved = true;
      });
    } catch (e) {
      // Show error to user so they know stats weren't saved
      debugPrint('Solo Results: Error saving to backend: $e');
      await _applyOfflineResultLocally();
      if (mounted) {
        TopNotification.show(
          context,
          message:
              '⚠️ Could not save stats to server. Stats saved locally for offline play.',
          type: NotificationType.warning,
        );
      }
      setState(() {
        _resultsSaved = true;
      });
    }
  }

  Future<void> _applyOfflineResultLocally() async {
    final result = widget.result;
    if (result == null) return;

    final userData = StorageService.instance.getUserData();
    if (userData == null) return;

    final mergedUser = _mergeStatsIntoUser(Map<String, dynamic>.from(userData));
    await StorageService.instance.saveUserData(mergedUser);
    debugPrint('Solo Results: Offline stats applied locally');
  }

  Map<String, dynamic> _mergeStatsIntoUser(Map<String, dynamic> user) {
    final result = widget.result ?? {};

    final gainedXp = result['xpGained'] ?? 0;
    final gainedCoins = result['coinsGained'] ?? 0;
    final correct = result['correctAnswers'] ?? 0;
    final totalQ = result['totalQuestions'] ?? 0;

    user['xp'] = (user['xp'] ?? 0) + gainedXp;
    user['coins'] = (user['coins'] ?? 0) + gainedCoins;
    user['totalGames'] = (user['totalGames'] ?? 0) + 1;

    // Track cumulative question stats to compute accuracy
    user['totalQuestionsAnswered'] =
        (user['totalQuestionsAnswered'] ?? 0) + totalQ;
    user['totalCorrectAnswers'] = (user['totalCorrectAnswers'] ?? 0) + correct;

    final answered = (user['totalQuestionsAnswered'] ?? 0) as int;
    final correctTotal = (user['totalCorrectAnswers'] ?? 0) as int;
    user['accuracyRate'] = answered > 0
        ? (correctTotal / answered) * 100.0
        : 0.0;

    // For solo mode, treat win rate as accuracy-based since there is no opponent
    user['winRate'] = user['accuracyRate'];

    final newLevel = ((user['xp'] ?? 0) ~/ AppConstants.xpPerLevel) + 1;
    user['level'] = newLevel;

    return user;
  }

  void _showLevelUpDialog(int newLevel, int totalCoins) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Level Up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'You reached Level $newLevel!',
          style: const TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text(
              'Awesome!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareScore() async {
    final totalQuestions = widget.result?['totalQuestions'] ?? 10;
    final correctAnswers = widget.result?['correctAnswers'] ?? 0;
    final accuracy = widget.result?['accuracy'] ?? 0;
    final xpGained = widget.result?['xpGained'] ?? 0;
    final timeBonusXp = widget.result?['timeBonusXp'] ?? 0;
    final coinsGained = widget.result?['coinsGained'] ?? 0;

    // Create a well-formatted share message
    final shareMessage = StringBuffer();

    // Header with emoji
    shareMessage.writeln('⚽ Football Arena - Solo Mode Results ⚽\n');

    // Score
    shareMessage.writeln('📊 Score: $correctAnswers/$totalQuestions');
    shareMessage.writeln('🎯 Accuracy: $accuracy%');

    // Rewards
    shareMessage.writeln('\n💰 Rewards:');
    shareMessage.writeln('⭐ +$xpGained XP');
    if (timeBonusXp > 0) {
      shareMessage.writeln('⚡ Time Bonus: +$timeBonusXp XP');
    }
    if (coinsGained > 0) {
      shareMessage.writeln('🪙 +$coinsGained Coins');
    }

    // Footer
    shareMessage.writeln('\n🏆 Challenge me in Football Arena!');
    shareMessage.writeln('#FootballArena #TriviaGame');

    try {
      await Share.share(
        shareMessage.toString(),
        subject: 'My Football Arena Solo Mode Score!',
      );

      // Show success notification after a short delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            TopNotification.show(
              context,
              message: 'Score shared successfully!',
              type: NotificationType.success,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context,
          message: 'Failed to share score. Please try again.',
          type: NotificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.result?['totalQuestions'] ?? 10;
    final correctAnswers = widget.result?['correctAnswers'] ?? 0;
    final accuracy = widget.result?['accuracy'] ?? 0;
    final xpGained = widget.result?['xpGained'] ?? 0;
    final timeBonus = widget.result?['timeBonus'] ?? 0; // Time bonus in points
    final timeBonusXp =
        widget.result?['timeBonusXp'] ??
        (timeBonus ~/ 20); // Time bonus converted to XP
    final baseXp =
        widget.result?['baseXp'] ??
        (correctAnswers * 5); // Base XP (100 points / 20 = 5 XP per correct)
    final coinsGained = widget.result?['coinsGained'] ?? 0;

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Trophy icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: accuracy >= 70
                              ? AppColors.primaryGradient
                              : const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (accuracy >= 70
                                          ? AppColors.primary
                                          : Colors.grey)
                                      .withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          accuracy >= 70
                              ? Icons.emoji_events
                              : Icons.sentiment_satisfied,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        accuracy >= 80
                            ? 'Excellent!'
                            : accuracy >= 60
                            ? 'Good Job!'
                            : 'Keep Practicing!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Score card
                      CustomCard(
                        gradient: AppColors.cardGradient,
                        child: Column(
                          children: [
                            // Main score
                            Text(
                              '$correctAnswers/$totalQuestions',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Correct Answers',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Accuracy
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$accuracy% Accuracy',
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
                      const SizedBox(height: 24),

                      // Rewards
                      CustomCard(
                        gradient: AppColors.xpGradient,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // XP Section
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/icons/xp_star.png',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+$xpGained',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'XP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 32),
                                // Coins Section
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/icons/coins_dumb.png',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+$coinsGained',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Coins',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // XP breakdown below as one line
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Base: +$baseXp XP',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (timeBonusXp > 0) ...[
                                    const SizedBox(width: 16),
                                    Text(
                                      'Time bonus: +$timeBonusXp XP',
                                      style: const TextStyle(
                                        color: AppColors.primaryLight,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Play Again',
                      type: ButtonType.gradient,
                      gradient: AppColors.soloModeGradient,
                      icon: Icons.replay,
                      onPressed: () {
                        context.go(RouteNames.soloMode);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: context.l10n.shareScore,
                            type: ButtonType.outlined,
                            icon: Icons.share,
                            onPressed: _shareScore,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Back to Home',
                            type: ButtonType.outlined,
                            onPressed: () {
                              context.go(RouteNames.home);
                            },
                          ),
                        ),
                      ],
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
