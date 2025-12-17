import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/models/stake_match.dart';
import '../../../shared/widgets/custom_button.dart';

class StakeMatchResultsScreen extends StatelessWidget {
  final StakeMatch match;
  final int myScore;
  final int correctAnswers;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionResults;
  final bool isCreator;

  const StakeMatchResultsScreen({
    super.key,
    required this.match,
    required this.myScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questionResults,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if user won (in real implementation, wait for opponent's score)
    final opponentScore = isCreator ? match.opponentScore : match.creatorScore;
    final didWin = myScore > opponentScore;
    final isDraw = myScore == opponentScore;

    final resultColor = didWin ? Colors.green : (isDraw ? Colors.orange : Colors.red);
    final resultText = didWin ? '🏆 YOU WON!' : (isDraw ? '🤝 DRAW!' : '😔 YOU LOST');
    final resultMessage = didWin
        ? 'Congratulations! You won ${match.winnerPayout} coins!'
        : isDraw
            ? 'It\'s a draw! Stakes refunded.'
            : 'Better luck next time!';

    final accuracy = (correctAnswers / totalQuestions * 100).toStringAsFixed(1);

    return Container(
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
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(RouteNames.home),
          ),
          title: const Text(
            'Match Results',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Result card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        resultColor.withOpacity(0.2),
                        resultColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: resultColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: resultColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        resultText,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        resultMessage,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ScoreColumn(
                            label: 'Your Score',
                            value: myScore.toString(),
                            isHighlight: didWin,
                          ),
                          Container(
                            width: 2,
                            height: 60,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _ScoreColumn(
                            label: 'Opponent',
                            value: opponentScore.toString(),
                            isHighlight: !didWin && !isDraw,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Correct',
                        value: '$correctAnswers/$totalQuestions',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.percent,
                        label: 'Accuracy',
                        value: '$accuracy%',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.monetization_on,
                        label: 'Stake',
                        value: '${match.stakeAmount}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events,
                        label: didWin ? 'Won' : 'Lost',
                        value: didWin ? '+${match.winnerPayout}' : '-${match.stakeAmount}',
                        color: didWin ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Buttons
                CustomButton(
                  onPressed: () => context.go(RouteNames.stakeMatch),
                  text: 'Back to Stake Match',
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: () => context.go(RouteNames.home),
                  text: 'Home',
                  type: ButtonType.outlined,
                ),

                const SizedBox(height: 24),

                // Question breakdown
                _QuestionBreakdown(
                  questionResults: questionResults,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _ScoreColumn({
    required this.label,
    required this.value,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.primary : Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> questionResults;

  const _QuestionBreakdown({required this.questionResults});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.list, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Question Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          ...questionResults.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final isCorrect = result['isCorrect'] as bool;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${index + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          result['question'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '+${result['score']}',
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

