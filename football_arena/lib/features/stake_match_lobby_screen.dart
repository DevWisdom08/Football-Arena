import 'package:flutter/material.dart';
import '../core/models/stake_match.dart';
import '../shared/app_theme.dart';

class StakeMatchLobbyScreen extends StatelessWidget {
  final StakeMatch match;

  const StakeMatchLobbyScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Stake Match Lobby'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_soccer,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                match.status == 'waiting'
                    ? 'Waiting for opponent...'
                    : 'Match Ready!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Stake: ${match.stakeAmount} coins',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Prize: ${match.winnerPayout} coins',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (match.status == 'active')
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to quiz game with stake match ID
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz game integration coming soon!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

