import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/models/user_model.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../core/network/stake_match_api_service.dart';
import '../core/models/stake_match.dart';
import '../core/routes/route_names.dart';

class StakeMatchScreen extends ConsumerStatefulWidget {
  const StakeMatchScreen({super.key});

  @override
  ConsumerState<StakeMatchScreen> createState() => _StakeMatchScreenState();
}

class _StakeMatchScreenState extends ConsumerState<StakeMatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStakeAmount = 1000;
  bool _isLoading = false;
  List<StakeMatch> _availableMatches = [];
  List<StakeMatch> _myMatches = [];
  List<StakeMatch> _historyMatches = [];

  final List<int> _stakeAmounts = [500, 1000, 2500, 5000, 10000, 25000];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) return;

      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);
      
      final available = await stakeMatchService.getAvailableMatches();
      final userMatches = await stakeMatchService.getUserMatches(userId);
      
      setState(() {
        _availableMatches = available;
        _myMatches = userMatches.where((m) => 
          m.status == 'waiting' || m.status == 'active'
        ).toList();
        _historyMatches = userMatches.where((m) => 
          m.status == 'completed' || m.status == 'cancelled'
        ).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading matches: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
    // Helper to safely parse commissionRate
    double parseCommissionRate(dynamic value) {
      if (value == null) return 10.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 10.0;
      return 10.0;
    }

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
      commissionRate: parseCommissionRate(userData['commissionRate']),
      kycVerified: userData['kycVerified'] ?? false,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    ) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                Colors.amber.shade700.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: const Text(
            '⚔️ Stake Match Arena',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Available'),
                Tab(text: 'My Matches'),
                Tab(text: 'History'),
              ],
            ),
          ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Colors.amber.shade700],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateMatchDialog(context, user!),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text(
            'Create Match',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinBalance(UserModel user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.amber.shade700.withOpacity(0.15),
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
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCoinStat('Total Coins', user.totalCoins.toString()),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildCoinStat(
            'Withdrawable',
            user.withdrawableCoins.toString(),
            color: Colors.greenAccent,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on,
              color: color ?? AppColors.primary,
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableMatches.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableMatches.length,
        itemBuilder: (context, index) {
          final match = _availableMatches[index];
          return _buildRealMatchCard(match, user, isAvailable: true);
        },
      ),
    );
  }

  Widget _buildMyMatches(UserModel user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myMatches.isEmpty) {
      return Center(
        child: Text(
          'No active matches',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myMatches.length,
        itemBuilder: (context, index) {
          final match = _myMatches[index];
          return _buildRealMatchCard(match, user, isActive: true);
        },
      ),
    );
  }

  Widget _buildHistory(UserModel user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyMatches.isEmpty) {
      return Center(
        child: Text(
          'No match history',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyMatches.length,
        itemBuilder: (context, index) {
          final match = _historyMatches[index];
          return _buildRealMatchCard(match, user, isHistory: true);
        },
      ),
    );
  }

  Widget _buildRealMatchCard(
    StakeMatch match,
    UserModel user, {
    bool isAvailable = false,
    bool isActive = false,
    bool isHistory = false,
  }) {
    final statusColor = _getStatusColor(match.status);
    final userId = user.id;
    final isCreator = match.creatorId == userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.primary,
                    size: 24,
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
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(0.7),
                    width: 1,
                  ),
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
          const SizedBox(height: 8),
          if (match.creatorUsername != null || match.opponentUsername != null) ...[
            Text(
              'Creator: ${match.creatorUsername ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (match.opponentUsername != null)
              Text(
                'Opponent: ${match.opponentUsername}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
          ],
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.2)),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Winner Gets: ${match.winnerPayout} coins',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Commission: ${match.commissionRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAvailable && !isCreator)
                OutlinedButton(
                  onPressed: () => _joinRealMatch(match, user),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Join Match'),
                ),
              if (isActive && match.opponentId != null)
                OutlinedButton(
                  onPressed: () => _playMatch(match),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Play Now'),
                ),
              if (isActive && isCreator && match.opponentId == null)
                OutlinedButton(
                  onPressed: () => _cancelMatch(match),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ],
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
                          ? AppColors.cardBackground
                          : Colors.grey.shade800,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (canAfford ? Colors.white24 : Colors.white12),
                        width: 1.5,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : (canAfford ? Colors.white : Colors.white38),
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
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        Colors.amber.shade700.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
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
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Create Match',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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

  Future<void> _createMatch(UserModel user) async {
    if (user.totalCoins < _selectedStakeAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);
      await stakeMatchService.createStakeMatch(
        userId: user.id,
        stakeAmount: _selectedStakeAmount,
        difficulty: 'mixed',
        numberOfQuestions: 10,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Match created successfully! 🎮',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        // Reload matches to show the new match
        await _loadMatches();

        // Switch to "My Matches" tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRealMatch(StakeMatch match, UserModel user) async {
    if (user.totalCoins < match.stakeAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins to join this match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Join',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);
      await stakeMatchService.joinStakeMatch(
        userId: user.id,
        matchId: match.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Match joined! Get ready to play! 🎮',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );

        await _loadMatches();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelMatch(StakeMatch match) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Cancel Match',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this match?\n\nYour stake will be refunded.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) return;

      final stakeMatchService = ref.read(stakeMatchApiServiceProvider);
      await stakeMatchService.cancelStakeMatch(
        userId: userId,
        matchId: match.id,
        reason: 'User cancelled',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match cancelled and coins refunded'),
            backgroundColor: Colors.orange,
          ),
        );

        await _loadMatches();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _playMatch(StakeMatch match) {
    final userId = StorageService.instance.getUserId();
    final isCreator = match.creatorId == userId;

    // Determine opponent details
    final opponentId = isCreator ? match.opponentId ?? '' : match.creatorId;
    final opponentUsername = isCreator 
        ? (match.opponentUsername ?? 'Opponent')
        : (match.creatorUsername ?? 'Creator');

    // Navigate to stake match game
    context.push(
      RouteNames.stakeMatchGame,
      extra: {
        'matchId': match.id,
        'opponentId': opponentId,
        'opponentUsername': opponentUsername,
        'stakeAmount': match.stakeAmount,
        'difficulty': match.difficulty ?? 'mixed',
        'questionCount': match.numberOfQuestions,
      },
    );
  }
}
