import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';

class StakeMatchResultsScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const StakeMatchResultsScreen({
    super.key,
    required this.matchData,
  });

  @override
  State<StakeMatchResultsScreen> createState() =>
      _StakeMatchResultsScreenState();
}

class _StakeMatchResultsScreenState extends State<StakeMatchResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  bool get isWinner =>
      widget.matchData['winnerId'] == widget.matchData['playerId'] ||
      (widget.matchData['playerScore'] ?? 0) >
          (widget.matchData['opponentScore'] ?? 0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchData = widget.matchData;
    final playerScore = matchData['playerScore'] ?? 0;
    final opponentScore = matchData['opponentScore'] ?? 0;
    final playerUsername = matchData['playerUsername'] ?? 'You';
    final opponentUsername = matchData['opponentUsername'] ?? 'Opponent';
    final stakeAmount = matchData['stakeAmount'] ?? 0;
    final playerPayout = matchData['playerPayout'] ?? 0;
    final commission = matchData['commission'] ?? 0;
    final error = matchData['error'];

    final isDraw = playerScore == opponentScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Result Trophy
                  _buildResultIcon(),

                  const SizedBox(height: 24),

                  // Result Text
                  _buildResultText(isDraw),

                  const SizedBox(height: 32),

                  // Scores Card
                  _buildScoresCard(
                    playerUsername,
                    opponentUsername,
                    playerScore,
                    opponentScore,
                  ),

                  const SizedBox(height: 24),

                  // Payout Card (if won)
                  if (isWinner && !isDraw && error == null)
                    _buildPayoutCard(stakeAmount, playerPayout, commission),

                  // Draw card
                  if (isDraw) _buildDrawCard(stakeAmount),

                  // Loss card
                  if (!isWinner && !isDraw) _buildLossCard(stakeAmount),

                  // Error card (if any)
                  if (error != null) _buildErrorCard(error),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIcon() {
    IconData icon;
    Color color;
    double size = 100;

    if (widget.matchData['error'] != null) {
      icon = Icons.error_outline;
      color = Colors.orange;
    } else if (isWinner && !isDraw) {
      icon = Icons.emoji_events;
      color = AppColors.primary;
    } else if (isDraw) {
      icon = Icons.handshake;
      color = Colors.blue;
    } else {
      icon = Icons.sentiment_dissatisfied;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  Widget _buildResultText(bool isDraw) {
    String title;
    String subtitle;
    Color color;

    if (widget.matchData['error'] != null) {
      title = 'Match Incomplete';
      subtitle = 'There was an issue processing the match';
      color = Colors.orange;
    } else if (isDraw) {
      title = 'IT\'S A DRAW!';
      subtitle = 'Both players scored the same';
      color = Colors.blue;
    } else if (isWinner) {
      title = 'VICTORY!';
      subtitle = 'You won the stake match!';
      color = AppColors.primary;
    } else {
      title = 'DEFEAT';
      subtitle = 'Better luck next time!';
      color = Colors.red;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildScoresCard(
    String playerUsername,
    String opponentUsername,
    int playerScore,
    int opponentScore,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Text(
            'FINAL SCORES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Player
              Expanded(
                child: _buildPlayerScore(
                  playerUsername,
                  playerScore,
                  Colors.blue,
                  isWinner: playerScore > opponentScore,
                ),
              ),

              // VS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Opponent
              Expanded(
                child: _buildPlayerScore(
                  opponentUsername,
                  opponentScore,
                  Colors.red,
                  isWinner: opponentScore > playerScore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(
    String username,
    int score,
    Color color, {
    bool isWinner = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isWinner ? 0.3 : 0.15),
            color.withOpacity(isWinner ? 0.2 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isWinner ? 0.8 : 0.4),
          width: isWinner ? 2 : 1,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isWinner)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Icon(
                Icons.emoji_events,
                color: color,
                size: 24,
              ),
            ),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'points',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(int stakeAmount, int playerPayout, int commission) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text(
                'YOU WON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPayoutRow('Stake Amount:', '$stakeAmount coins'),
          const Divider(color: Colors.white24),
          _buildPayoutRow('Opponent Stake:', '$stakeAmount coins'),
          const Divider(color: Colors.white24),
          _buildPayoutRow('Total Pot:', '${stakeAmount * 2} coins'),
          const Divider(color: Colors.white24),
          _buildPayoutRow('Commission:', '-$commission coins', isNegative: true),
          const Divider(color: Colors.green),
          _buildPayoutRow('Your Payout:', '+$playerPayout coins', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildDrawCard(int stakeAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.cyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.handshake, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'DRAW - STAKE REFUNDED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your $stakeAmount coins have been refunded',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLossCard(int stakeAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied,
                  color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text(
                'STAKE LOST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You lost $stakeAmount coins',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Practice makes perfect! Try again!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Processing Issue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutRow(String label, String value,
      {bool isNegative = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? Colors.white : Colors.white70,
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isNegative
                  ? Colors.redAccent
                  : isHighlight
                      ? Colors.greenAccent
                      : Colors.white,
              fontSize: isHighlight ? 20 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Play Again Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Go back to stake match arena
                context.go(RouteNames.stakeMatch);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'PLAY ANOTHER MATCH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Home Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => context.go(RouteNames.home),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              'GO HOME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get isDraw =>
      (widget.matchData['playerScore'] ?? 0) ==
      (widget.matchData['opponentScore'] ?? 0);
}
