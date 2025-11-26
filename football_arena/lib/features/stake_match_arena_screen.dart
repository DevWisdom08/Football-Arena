import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/stake_match.dart';
import '../core/services/stake_match_service.dart';
import '../core/providers/user_provider.dart';
import '../shared/app_theme.dart';
import 'create_stake_match_screen.dart';
import 'stake_match_lobby_screen.dart';

class StakeMatchArenaScreen extends StatefulWidget {
  const StakeMatchArenaScreen({super.key});

  @override
  State<StakeMatchArenaScreen>  createState() => _StakeMatchArenaScreenState();
}

class _StakeMatchArenaScreenState extends State<StakeMatchArenaScreen> with SingleTickerProviderStateMixin {
  final StakeMatchService _stakeMatchService = StakeMatchService();
  List<StakeMatch> _availableMatches = [];
  List<StakeMatch> _myMatches = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      final available = await _stakeMatchService.getAvailableMatches();
      final myMatches = await _stakeMatchService.getUserMatches(userId);

      setState(() {
        _availableMatches = available;
        _myMatches = myMatches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading matches: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('⚔️ Stake Match Arena'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Available Matches'),
            Tab(text: 'My Matches'),
          ],
        ),
      ),
      body: Column(
        children: [
          // User Balance Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCoinBalance(
                  '💎 Purchased',
                  user?.purchasedCoins ?? 0,
                  'Can\'t withdraw',
                ),
                _buildCoinBalance(
                  '💰 Withdrawable',
                  user?.withdrawableCoins ?? 0,
                  'Can withdraw',
                ),
              ],
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableMatchesTab(),
                _buildMyMatchesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStakeMatchScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppTheme.successColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Match', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCoinBalance(String label, int amount, String subtitle) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableMatchesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No available matches',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to create a stake match!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableMatches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(_availableMatches[index], isAvailable: true);
        },
      ),
    );
  }

  Widget _buildMyMatchesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No match history',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myMatches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(_myMatches[index], isAvailable: false);
        },
      ),
    );
  }

  Widget _buildMatchCard(StakeMatch match, {required bool isAvailable}) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? '';
    final isMyMatch = match.creatorId == userId;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (match.status) {
      case 'waiting':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Waiting';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusIcon = Icons.play_arrow;
        statusText = 'Active';
        break;
      case 'completed':
        statusColor = match.winnerId == userId ? AppTheme.successColor : Colors.red;
        statusIcon = match.winnerId == userId ? Icons.emoji_events : Icons.cancel;
        statusText = match.winnerId == userId ? 'Won' : 'Lost';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          if (isAvailable && !isMyMatch) {
            _showJoinDialog(match);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StakeMatchLobbyScreen(match: match),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${match.numberOfQuestions} Questions',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: match.creatorAvatar != null
                        ? NetworkImage(match.creatorAvatar!)
                        : null,
                    child: match.creatorAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.creatorUsername ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (match.status == 'completed')
                          Text(
                            'Score: ${match.creatorScore}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  if (match.status != 'waiting')
                    const Icon(Icons.sports_mma, color: Colors.grey),
                  if (match.status != 'waiting') const SizedBox(width: 8),
                  if (match.opponentUsername != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            match.opponentUsername!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          if (match.status == 'completed')
                            Text(
                              'Score: ${match.opponentScore}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  if (match.opponentUsername != null) const SizedBox(width: 8),
                  if (match.opponentAvatar != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(match.opponentAvatar!),
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  _buildInfoChip('💰 Stake', '${match.stakeAmount} coins'),
                  const SizedBox(width: 8),
                  _buildInfoChip('🏆 Prize', '${match.winnerPayout} coins'),
                  const Spacer(),
                  Text(
                    '${match.commissionRate.toStringAsFixed(0)}% fee',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(StakeMatch match) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final totalCoins = (userProvider.user?.coins ?? 0) +
        (userProvider.user?.purchasedCoins ?? 0) +
        (userProvider.user?.withdrawableCoins ?? 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Stake Match'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stake: ${match.stakeAmount} coins'),
            Text('Prize: ${match.winnerPayout} coins'),
            Text('Commission: ${match.commissionRate.toStringAsFixed(0)}%'),
            const SizedBox(height: 16),
            Text(
              'Your balance: $totalCoins coins',
              style: TextStyle(
                color: totalCoins >= match.stakeAmount
                    ? AppTheme.successColor
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalCoins < match.stakeAmount)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Insufficient coins!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: totalCoins >= match.stakeAmount
                ? () async {
                    Navigator.pop(context);
                    _joinMatch(match);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _joinMatch(StakeMatch match) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      final updatedMatch = await _stakeMatchService.joinStakeMatch(
        userId: userId,
        matchId: match.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined match!')),
        );
        
        _loadData();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StakeMatchLobbyScreen(match: updatedMatch),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining match: $e')),
        );
      }
    }
  }
}

