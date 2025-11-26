import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/users_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/app_bottom_bar.dart';
import '../../../shared/widgets/top_notification.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedType = 'global'; // global, friends, monthly
  String selectedFilter = 'alltime'; // daily, weekly, monthly, alltime
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadLeaderboard();
  }

  Future<void> _loadUserId() async {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      setState(() {
        currentUserId = userData['id'];
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final usersService = ref.read(usersApiServiceProvider);
      final data = await usersService.getLeaderboard(
        limit: 50,
        type: selectedType,
        filter: selectedFilter,
        userId: selectedType == 'friends' ? currentUserId : null,
      );

      setState(() {
        leaderboardData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
        leaderboardData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomBar(currentIndex: 1),
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
              // App bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    const Spacer(),
                    if (errorMessage != null)
                      const Icon(
                        Icons.cloud_off,
                        color: Colors.orange,
                        size: 20,
                      ),
                  ],
                ),
              ),

              // Type Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _TypeChip(
                      label: 'Global',
                      isSelected: selectedType == 'global',
                      onTap: () {
                        setState(() => selectedType = 'global');
                        _loadLeaderboard();
                      },
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Friends',
                      isSelected: selectedType == 'friends',
                      onTap: () {
                        if (currentUserId != null) {
                          setState(() => selectedType = 'friends');
                          _loadLeaderboard();
                        } else {
                          TopNotification.show(
                            context,
                            message: 'Please login to view friends leaderboard',
                            type: NotificationType.warning,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _TypeChip(
                      label: 'Monthly',
                      isSelected: selectedType == 'monthly',
                      onTap: () {
                        setState(() => selectedType = 'monthly');
                        _loadLeaderboard();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All Time',
                        isSelected: selectedFilter == 'alltime',
                        onTap: () {
                          setState(() => selectedFilter = 'alltime');
                          _loadLeaderboard();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Monthly',
                        isSelected: selectedFilter == 'monthly',
                        onTap: () {
                          setState(() => selectedFilter = 'monthly');
                          _loadLeaderboard();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Weekly',
                        isSelected: selectedFilter == 'weekly',
                        onTap: () {
                          setState(() => selectedFilter = 'weekly');
                          _loadLeaderboard();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Daily',
                        isSelected: selectedFilter == 'daily',
                        onTap: () {
                          setState(() => selectedFilter = 'daily');
                          _loadLeaderboard();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadLeaderboard,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Using offline data. Pull to refresh.',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Leaderboard entries
                              if (leaderboardData.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.leaderboard_outlined,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        selectedType == 'friends'
                                            ? 'No friends yet. Add friends to see their rankings!'
                                            : 'No data available',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...leaderboardData.map((user) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _LeaderboardEntry(
                                      rank: user['rank'] ?? 0,
                                      username: user['username'] ?? 'Unknown',
                                      country: user['country'] ?? 'Unknown',
                                      xp:
                                          (user['xp'] ?? user['monthlyXP'] ?? 0)
                                              as int,
                                      monthlyScore: user['monthlyScore'] != null
                                          ? (user['monthlyScore'] as int)
                                          : null,
                                    ),
                                  );
                                }),
                            ],
                          ),
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

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int rank;
  final String username;
  final String country;
  final int xp;
  final int? monthlyScore;

  const _LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.country,
    required this.xp,
    this.monthlyScore,
  });

  @override
  Widget build(BuildContext context) {
    String? trophyIcon;

    if (rank == 1) {
      trophyIcon = 'assets/icons/trophy_gold.png';
    } else if (rank == 2) {
      trophyIcon = 'assets/icons/trophy_silver.png';
    } else if (rank == 3) {
      trophyIcon = 'assets/icons/trophy_bronze.png';
    }

    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Rank with Trophy
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: trophyIcon != null
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: trophyIcon != null
                  ? Image.asset(
                      trophyIcon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  country,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // XP/Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (monthlyScore != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Score: $monthlyScore',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
