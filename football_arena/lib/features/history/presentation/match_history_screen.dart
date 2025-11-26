import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/game_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/app_bottom_bar.dart';
import '../../../core/extensions/localization_extensions.dart';

class MatchHistoryScreen extends ConsumerStatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  ConsumerState<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends ConsumerState<MatchHistoryScreen> {
  String selectedFilter = 'All';
  List<Map<String, dynamic>> matchHistory = [];
  bool isLoading = false;
  String? errorMessage;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      setState(() {
        userId = userData['id'];
      });
      _loadMatchHistory();
    } else {
      setState(() {
        errorMessage = 'Please login to view match history';
      });
    }
  }

  Future<void> _loadMatchHistory() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final gameService = ref.read(gameApiServiceProvider);
      List<Map<String, dynamic>> data;

      if (selectedFilter == 'All') {
        data = await gameService.getMatchHistory(userId: userId!, limit: 50);
      } else {
        final mode = _getModeFromFilter(selectedFilter);
        if (mode != null) {
          data = await gameService.getMatchHistoryByMode(
            userId: userId!,
            mode: mode,
            limit: 50,
          );
        } else {
          data = await gameService.getMatchHistory(userId: userId!, limit: 50);
        }
      }

      setState(() {
        matchHistory = data.map((match) => _formatMatchData(match)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
        matchHistory = [];
      });
    }
  }

  String? _getModeFromFilter(String filter) {
    switch (filter) {
      case 'Solo':
        return 'solo';
      case '1v1':
        return '1v1';
      case 'Team':
        return 'team';
      case 'Daily':
        return 'daily_quiz';
      default:
        return null;
    }
  }

  Map<String, dynamic> _formatMatchData(Map<String, dynamic> match) {
    final gameMode = match['gameMode'] ?? 'Unknown';
    final result = match['result'] ?? 'Completed';
    final playedAt = match['playedAt'] ?? DateTime.now().toIso8601String();

    // Format date
    final date = DateTime.tryParse(playedAt);
    String dateStr = 'Unknown';
    if (date != null) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        dateStr =
            'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        dateStr =
            'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        dateStr = '${difference.inDays} days ago';
      } else {
        dateStr = '${date.day}/${date.month}/${date.year}';
      }
    }

    // Get icon and color based on game mode
    IconData icon;
    Color color;
    switch (gameMode.toString().toLowerCase()) {
      case 'daily_quiz':
      case 'daily quiz':
        icon = Icons.calendar_today;
        color = Colors.purple;
        break;
      case '1v1':
      case 'challenge':
        icon = Icons.emoji_events;
        color = Colors.red;
        break;
      case 'team':
      case 'team_match':
        icon = Icons.groups;
        color = Colors.orange;
        break;
      case 'solo':
      case 'solo_mode':
        icon = Icons.bolt;
        color = Colors.blue;
        break;
      default:
        icon = Icons.sports_soccer;
        color = Colors.green;
    }

    return {
      'gameMode': _formatGameModeName(gameMode.toString()),
      'result': _formatResult(result.toString(), match),
      'score': match['score'] ?? 0,
      'accuracy':
          ((match['correctAnswers'] ?? 0) /
                  (match['totalQuestions'] ?? 1) *
                  100)
              .round(),
      'xpGained': match['xpGained'] ?? 0,
      'coinsGained': match['coinsGained'] ?? 0,
      'date': dateStr,
      'icon': icon,
      'color': color,
      'opponent': match['opponentUsername'],
      'opponentId': match['opponentId'],
    };
  }

  String _formatGameModeName(String mode) {
    switch (mode.toLowerCase()) {
      case 'daily_quiz':
        return 'Daily Quiz';
      case '1v1':
      case 'challenge':
        return '1v1 Challenge';
      case 'team':
      case 'team_match':
        return 'Team Match';
      case 'solo':
      case 'solo_mode':
        return 'Solo Mode';
      default:
        return mode;
    }
  }

  String _formatResult(String result, Map<String, dynamic> match) {
    if (result.toLowerCase() == 'win') {
      if (match['teamData'] != null) {
        return 'Win - ${match['teamData']['teamName'] ?? 'Team'}';
      }
      return 'Win';
    } else if (result.toLowerCase() == 'loss') {
      return 'Loss';
    } else if (result.toLowerCase() == 'draw') {
      return 'Draw';
    }
    return 'Completed';
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Match History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Solo'),
                    _buildFilterChip('1v1'),
                    _buildFilterChip('Team'),
                    _buildFilterChip('Daily'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Match list
              Expanded(child: _buildMatchList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 3),
    );
  }

  Widget _buildMatchList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMatchHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (matchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              context.l10n.noMatches,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Play games to see your match history',
              style: TextStyle(fontSize: 14, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatchHistory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: matchHistory.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMatchCard(matchHistory[index]),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
          _loadMatchHistory();
        },
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final isWin = match['result'].toString().contains('Win');
    final color = match['color'] as Color;

    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(match['icon'], color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['gameMode'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      match['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isWin
                      ? Colors.green.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWin ? Colors.green : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                  match['result'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isWin ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          if (match['opponent'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white54, size: 16),
                const SizedBox(width: 6),
                Text(
                  'vs ${match['opponent']}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Accuracy', '${match['accuracy']}%'),
              _buildStat('XP', '+${match['xpGained']}'),
              _buildStat('Coins', '+${match['coinsGained']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}
