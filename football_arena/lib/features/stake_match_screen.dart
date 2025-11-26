import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/models/user_model.dart';
import '../shared/models/stake_match_model.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';

class StakeMatchScreen extends ConsumerStatefulWidget {
  const StakeMatchScreen({super.key});

  @override
  ConsumerState<StakeMatchScreen> createState() => _StakeMatchScreenState();
}

class _StakeMatchScreenState extends ConsumerState<StakeMatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStakeAmount = 1000;

  final List<int> _stakeAmounts = [500, 1000, 2500, 5000, 10000, 25000];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from storage
    final userData = StorageService.instance.getUserData();
    final user = userData != null ? UserModel(
      id: userData['id'] ?? '',
      username: userData['username'] ?? 'Guest',
      email: userData['email'] ?? '',
      country: userData['country'] ?? 'Unknown',
      level: userData['level'] ?? 1,
      xp: userData['xp'] ?? 0,
      coins: userData['coins'] ?? 0,
      withdrawableCoins: userData['withdrawableCoins'] ?? 0,
      purchasedCoins: userData['purchasedCoins'] ?? 0,
      commissionRate: userData['commissionRate']?.toDouble() ?? 10.0,
      kycVerified: userData['kycVerified'] ?? false,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    ) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          '⚔️ Stake Match Arena',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Matches'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCoinBalance(user),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAvailableMatches(user),
                      _buildMyMatches(user),
                      _buildHistory(user),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMatchDialog(context, user!),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Match'),
      ),
    );
  }

  Widget _buildCoinBalance(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCoinStat('Total Coins', user.totalCoins.toString()),
          _buildCoinStat(
            'Withdrawable',
            user.withdrawableCoins.toString(),
            color: Colors.greenAccent,
          ),
          _buildCoinStat(
            'Purchased',
            user.purchasedCoins.toString(),
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCoinStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.monetization_on,
              color: color ?? Colors.yellowAccent,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableMatches(UserModel user) {
    // Mock data for now - replace with actual API call
    final availableMatches = <StakeMatchModel>[];

    if (availableMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No matches available',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new match to challenge others!',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableMatches.length,
      itemBuilder: (context, index) {
        final match = availableMatches[index];
        return _buildMatchCard(match, user, isAvailable: true);
      },
    );
  }

  Widget _buildMyMatches(UserModel user) {
    // Mock data - replace with actual API call
    final myMatches = <StakeMatchModel>[];

    if (myMatches.isEmpty) {
      return Center(
        child: Text(
          'No active matches',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myMatches.length,
      itemBuilder: (context, index) {
        final match = myMatches[index];
        return _buildMatchCard(match, user, isActive: true);
      },
    );
  }

  Widget _buildHistory(UserModel user) {
    // Mock data - replace with actual API call
    final history = <StakeMatchModel>[];

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No match history',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final match = history[index];
        return _buildMatchCard(match, user, isHistory: true);
      },
    );
  }

  Widget _buildMatchCard(
    StakeMatchModel match,
    UserModel user, {
    bool isAvailable = false,
    bool isActive = false,
    bool isHistory = false,
  }) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.yellowAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${match.stakeAmount} coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(match.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pot: ${match.totalPot} coins',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Winner Gets: ${match.winnerPayout} coins',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Commission: ${match.commissionRate}%',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () => _joinMatch(match, user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Join Match'),
                  ),
                if (isActive)
                  ElevatedButton(
                    onPressed: () => _playMatch(match),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                    ),
                    child: const Text('Play Now'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateMatchDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Create Stake Match',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select stake amount:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _stakeAmounts.map((amount) {
                    final isSelected = amount == _selectedStakeAmount;
                    final canAfford = user.totalCoins >= amount;

                    return ChoiceChip(
                      label: Text('$amount'),
                      selected: isSelected,
                      onSelected: canAfford
                          ? (selected) {
                              setState(() {
                                _selectedStakeAmount = amount;
                              });
                            }
                          : null,
                      selectedColor: AppColors.primary,
                      backgroundColor: canAfford
                          ? AppColors.background
                          : Colors.grey.shade800,
                      labelStyle: TextStyle(
                        color: canAfford ? Colors.white : Colors.white38,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Your stake:',
                        '$_selectedStakeAmount coins',
                      ),
                      _buildInfoRow(
                        'Total pot:',
                        '${_selectedStakeAmount * 2} coins',
                      ),
                      _buildInfoRow('Commission:', '${user.commissionRate}%'),
                      Divider(color: Colors.white24),
                      _buildInfoRow(
                        'Winner gets:',
                        '${(_selectedStakeAmount * 2 * (1 - user.commissionRate / 100)).toInt()} coins',
                        highlight: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createMatch(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Create Match'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.greenAccent : Colors.white70,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.greenAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _createMatch(UserModel user) {
    // TODO: Implement API call to create stake match
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Creating stake match with $_selectedStakeAmount coins...',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _joinMatch(StakeMatchModel match, UserModel user) {
    if (user.totalCoins < match.stakeAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins to join this match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Join Stake Match',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Join this match with ${match.stakeAmount} coins?\n\nWinner gets ${match.winnerPayout} coins!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement API call to join match
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joining match...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _playMatch(StakeMatchModel match) {
    // Navigate to quiz game with stake match mode
    context.push('/solo-mode'); // TODO: Pass stake match ID
  }
}
