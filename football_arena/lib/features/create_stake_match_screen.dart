import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/stake_match_service.dart';
import '../core/providers/user_provider.dart';
import '../shared/app_theme.dart';

class CreateStakeMatchScreen extends StatefulWidget {
  const CreateStakeMatchScreen({super.key});

  @override
  State<CreateStakeMatchScreen> createState() => _CreateStakeMatchScreenState();
}

class _CreateStakeMatchScreenState extends State<CreateStakeMatchScreen> {
  final StakeMatchService _stakeMatchService = StakeMatchService();
  
  int _stakeAmount = 1000;
  String _difficulty = 'mixed';
  int _numberOfQuestions = 10;
  bool _isCreating = false;

  final List<int> _stakeLevels = [100, 500, 1000, 2000, 5000, 10000];
  final List<String> _difficulties = ['easy', 'medium', 'hard', 'mixed'];
  final List<int> _questionCounts = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final totalCoins = (user?.coins ?? 0) +
        (user?.purchasedCoins ?? 0) +
        (user?.withdrawableCoins ?? 0);

    final commissionRate = user?.commissionRate ?? 10.0;
    final totalPot = _stakeAmount * 2;
    final commission = (totalPot * (commissionRate / 100)).toInt();
    final winnerPayout = totalPot - commission;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Stake Match'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Card(
              color: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Your Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalCoins coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.isVip == true)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '👑 VIP - ${commissionRate.toStringAsFixed(0)}% Commission',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stake Amount
            const Text(
              'Stake Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _stakeLevels.map((amount) {
                final isSelected = _stakeAmount == amount;
                return ChoiceChip(
                  label: Text('$amount'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _stakeAmount = amount);
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Difficulty
            const Text(
              'Difficulty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _difficulties.map((diff) {
                final isSelected = _difficulty == diff;
                return ChoiceChip(
                  label: Text(diff.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _difficulty = diff);
                  },
                  selectedColor: AppTheme.secondaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Number of Questions
            const Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _questionCounts.map((count) {
                final isSelected = _numberOfQuestions == count;
                return ChoiceChip(
                  label: Text('$count'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _numberOfQuestions = count);
                  },
                  selectedColor: AppTheme.accentColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Match Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      '💰 Your Stake',
                      '$_stakeAmount coins',
                    ),
                    _buildSummaryRow(
                      '🎯 Total Pot',
                      '$totalPot coins',
                    ),
                    _buildSummaryRow(
                      '💸 Commission (${commissionRate.toStringAsFixed(0)}%)',
                      '$commission coins',
                      color: Colors.red,
                    ),
                    _buildSummaryRow(
                      '🏆 Winner Gets',
                      '$winnerPayout coins',
                      color: AppTheme.successColor,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your stake will be deducted immediately. Winner gets ${(winnerPayout / _stakeAmount * 100 - 100).toStringAsFixed(0)}% profit!',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: totalCoins >= _stakeAmount && !_isCreating
                  ? _createMatch
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create Stake Match',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            if (totalCoins < _stakeAmount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Insufficient coins! You need ${_stakeAmount - totalCoins} more coins.',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createMatch() async {
    setState(() => _isCreating = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      await _stakeMatchService.createStakeMatch(
        userId: userId,
        stakeAmount: _stakeAmount,
        difficulty: _difficulty,
        numberOfQuestions: _numberOfQuestions,
      );

      // Refresh user data to update coin balance
      await userProvider.refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Stake match created! Waiting for opponent...'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }
}

