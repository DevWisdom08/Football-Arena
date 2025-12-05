import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/network/users_api_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_bottom_bar.dart';
import '../../../shared/widgets/top_notification.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String selectedAvatar = 'Classic';

  final List<_AvatarItem> avatars = const [
    _AvatarItem(
      id: 'default',
      name: 'Default',
      imagePath: null,
      thumbPath: null,
      requiredLevel: 1,
      isDefaultIcon: true,
    ),
    _AvatarItem(
      id: 'classic',
      name: 'Classic',
      imagePath: 'assets/avatars/classic.png',
      thumbPath: 'assets/avatars/classic_thumb.png',
      requiredLevel: 1,
    ),
    _AvatarItem(
      id: 'neon_blaze',
      name: 'Neon Blaze',
      imagePath: 'assets/avatars/neon_blaze.png',
      thumbPath: 'assets/avatars/neon_blaze_thumb.png',
      requiredLevel: 5,
    ),
    _AvatarItem(
      id: 'kings_gold',
      name: 'Kings Gold',
      imagePath: 'assets/avatars/kings_gold.png',
      thumbPath: 'assets/avatars/kings_gold_thumb.png',
      requiredLevel: 10,
    ),
    _AvatarItem(
      id: 'galaxy',
      name: 'Galaxy',
      imagePath: 'assets/avatars/galaxy.png',
      thumbPath: 'assets/avatars/galaxy_thumb.png',
      requiredLevel: 15,
    ),
    _AvatarItem(
      id: 'legendary',
      name: 'Legendary',
      imagePath: 'assets/avatars/legendary.png',
      thumbPath: 'assets/avatars/legendary_thumb.png',
      requiredLevel: 20,
      requiresVip: true,
    ),
    _AvatarItem(
      id: 'champion',
      name: 'Champion',
      imagePath: 'assets/avatars/champion.png',
      thumbPath: 'assets/avatars/champion_thumb.png',
      requiredLevel: 1,
      requiresCoins: true,
      coinCost: 500,
    ),
    _AvatarItem(
      id: 'elite',
      name: 'Elite',
      imagePath: 'assets/avatars/elite.png',
      thumbPath: 'assets/avatars/elite_thumb.png',
      requiredLevel: 1,
      requiresCoins: true,
      coinCost: 1000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = StorageService.instance.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  List<_Achievement> _getAllAchievements() {
    return const [
      _Achievement(
        id: 'first_win',
        imagePath: 'assets/icons/first_win.png',
        title: 'First Win',
        description: 'Win your first match',
        color: Colors.blue,
      ),
      _Achievement(
        id: 'perfect_score',
        imagePath: 'assets/icons/perfect_score.png',
        title: 'Perfect',
        description: 'Get 100% accuracy',
        color: Colors.orange,
      ),
      _Achievement(
        id: '7_day_streak',
        imagePath: 'assets/icons/7_day_streak.png',
        title: '7 Days',
        description: 'Play for 7 days straight',
        color: Colors.red,
      ),
      _Achievement(
        id: '100_games',
        imagePath: 'assets/icons/100_games.png',
        title: '100 Games',
        description: 'Play 100 games',
        color: Colors.purple,
      ),
    ];
  }

  List<_Achievement> _getEarnedAchievements(Map<String, dynamic>? userData) {
    if (userData == null) return [];

    final userBadges = userData['badges'];
    List<String> badges = [];

    if (userBadges is List) {
      badges = userBadges.map((e) => e.toString()).toList();
    } else if (userBadges is String && userBadges.isNotEmpty) {
      badges = userBadges.split(',');
    }

    final allAchievements = _getAllAchievements();
    return allAchievements.where((achievement) {
      return badges.contains(achievement.id);
    }).toList();
  }

  Widget _buildAchievementsRow(Map<String, dynamic>? userData) {
    final earnedAchievements = _getEarnedAchievements(userData);

    if (earnedAchievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, color: Colors.white38, size: 32),
            SizedBox(width: 12),
            Text(
              'No achievements earned yet.\nPlay games to earn badges!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: earnedAchievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AchievementCard(
              imagePath: achievement.imagePath,
              title: achievement.title,
              color: achievement.color,
              isEarned: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Set<String> _getPurchasedAvatarIds() {
    final purchased = userData?['purchasedAvatars'];
    if (purchased is List) {
      return purchased.map((e) => e.toString()).toSet();
    }
    if (purchased is String && purchased.isNotEmpty) {
      return purchased.split(',').toSet();
    }
    return {};
  }

  Future<void> _selectAvatar(_AvatarItem item) async {
    final userLevel = userData?['level'] ?? 1;
    final isVip = userData?['isVip'] ?? false;
    final userCoins = userData?['coins'] ?? 0;
    final purchased = _getPurchasedAvatarIds();
    final alreadyPurchased = purchased.contains(item.id);

    final levelLocked = userLevel < item.requiredLevel;
    final vipLocked = item.requiresVip && !isVip;
    final coinsLocked =
        item.requiresCoins && !alreadyPurchased && userCoins < item.coinCost;

    if (levelLocked) {
      TopNotification.show(
        context,
        message: 'Reach level ${item.requiredLevel} to unlock ${item.name}.',
        type: NotificationType.warning,
      );
      return;
    }

    if (vipLocked) {
      TopNotification.show(
        context,
        message: 'Requires VIP to equip ${item.name}.',
        type: NotificationType.warning,
      );
      return;
    }

    if (coinsLocked) {
      TopNotification.show(
        context,
        message: 'Need ${item.coinCost} coins. You have $userCoins coins.',
        type: NotificationType.warning,
      );
      return;
    }

    // If coin-locked and not purchased, confirm purchase and deduct coins
    if (item.requiresCoins && !alreadyPurchased) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Purchase Avatar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'Spend ${item.coinCost} ?? to unlock ${item.name}?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Unlock'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      final updatedCoins = userCoins - item.coinCost;
      if (updatedCoins < 0) {
        TopNotification.show(
          context,
          message: 'Not enough coins.',
          type: NotificationType.error,
        );
        return;
      }

      purchased.add(item.id);
      userData ??= {};
      userData!['coins'] = updatedCoins;
      userData!['purchasedAvatars'] = purchased.toList();
    }

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Save to backend (coins deduction and avatar selection)
      final usersService = ref.read(usersApiServiceProvider);
      final updateData = <String, dynamic>{};
      
      // Only set avatarUrl if not default icon
      if (!item.isDefaultIcon && item.imagePath != null) {
        updateData['avatarUrl'] = item.imagePath;
      } else if (item.isDefaultIcon) {
        updateData['avatarUrl'] = ''; // Empty string for default
      }

      // If purchasing with coins, also update coins and purchased list
      if (item.requiresCoins && !alreadyPurchased) {
        updateData['coins'] = userData!['coins'];
        updateData['purchasedAvatars'] = purchased.join(',');
      }

      final updatedUser = await usersService.updateUser(userId, updateData);

      // Update local data with backend response
      setState(() {
        selectedAvatar = item.name;
        userData = updatedUser;
      });

      // Save to local storage
      await StorageService.instance.saveUserData(updatedUser);

      if (!mounted) return;

      TopNotification.show(
        context,
        message: item.requiresCoins && !alreadyPurchased
            ? '${item.name} unlocked and equipped! Saved to server.'
            : '${item.name} equipped!',
        type: NotificationType.success,
      );
    } catch (e) {
      if (!mounted) return;

      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = userData?['username'] ?? 'Guest';
    final level = userData?['level'] ?? 1;
    final country = userData?['country'] ?? 'Unknown';
    final xp = userData?['xp'] ?? 0;
    final totalGames = userData?['totalGames'] ?? 0;
    final userCoins = userData?['coins'] ?? 0;
    final streak = userData?['currentStreak'] ?? 0;

    final accuracyRaw = userData?['accuracyRate'] ?? 0.0;
    final accuracyRate = accuracyRaw is String
        ? double.tryParse(accuracyRaw) ?? 0.0
        : (accuracyRaw is int ? accuracyRaw.toDouble() : accuracyRaw as double);

    final winRateRaw = userData?['winRate'] ?? 0.0;
    final winRate = winRateRaw is String
        ? double.tryParse(winRateRaw) ?? 0.0
        : (winRateRaw is int ? winRateRaw.toDouble() : winRateRaw as double);

    final isVip = userData?['isVip'] ?? false;
    final purchasedAvatars = _getPurchasedAvatarIds();

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      bottomNavigationBar: const AppBottomBar(currentIndex: 4),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Profile Header (No AppBar)
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Top Gradient Overlay
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        // Back & Settings Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () => context.go(RouteNames.home),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () =>
                                      context.push(RouteNames.settings),
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Avatar
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 4,
                                  ),
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: ClipOval(
                                  child:
                                      userData?['avatarUrl'] != null &&
                                          userData!['avatarUrl']
                                              .toString()
                                              .isNotEmpty
                                      ? Image.asset(
                                          userData!['avatarUrl'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) {
                                            return const Icon(
                                              Icons.person,
                                              size: 70,
                                              color: Colors.white,
                                            );
                                          },
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              // Edit Button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(RouteNames.profileEdit),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Level & Country Chips
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Level $level',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
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
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    country,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isVip)
                              const Chip(
                                avatar: Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                label: Text('VIP'),
                                backgroundColor: Colors.amber,
                                labelStyle: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini Stats Row
                      Row(
                        children: [
                          _MiniStatChip(
                            icon: Icons.monetization_on,
                            value: userCoins.toString(),
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          _MiniStatChip(
                            icon: Icons.local_fire_department,
                            value: '$streak',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _MiniStatChip(
                            icon: Icons.auto_awesome,
                            value: xp.toString(),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Section Title
                      const Text(
                        'Game Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              icon: Icons.videogame_asset,
                              value: totalGames.toString(),
                              label: 'Played',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              icon: Icons.emoji_events,
                              value: '${winRate.toStringAsFixed(0)}%',
                              label: 'Win Rate',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.green.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400.withOpacity(0.15),
                              Colors.purple.shade700.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.purple.shade400.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InlineStatItem(
                              icon: Icons.trending_up,
                              value: '${accuracyRate.toStringAsFixed(0)}%',
                              label: 'Accuracy',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _InlineStatItem(
                              icon: Icons.military_tech,
                              value: '$totalGames',
                              label: 'Total Games',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Avatars Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Avatars',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${avatars.where((a) => level >= a.requiredLevel).length}/${avatars.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate optimal avatar size to fit screen
                          final availableWidth = constraints.maxWidth;
                          final spacing = 12.0;
                          final itemsPerRow = 4;
                          final totalSpacing = spacing * (itemsPerRow - 1);
                          final itemWidth = (availableWidth - totalSpacing) / itemsPerRow;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: avatars.map((avatar) {
                              return SizedBox(
                                width: itemWidth,
                                child: _AvatarTile(
                                  item: avatar,
                                  selected: selectedAvatar == avatar.name,
                                  userLevel: level,
                                  isVip: isVip,
                                  isPurchased: purchasedAvatars.contains(avatar.id),
                                  onTap: () => _selectAvatar(avatar),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Achievements Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_getEarnedAchievements(userData).length}/${_getAllAchievements().length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAchievementsRow(userData),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.people,
                              title: 'Friends',
                              onTap: () => context.push(RouteNames.friends),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.purple.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.purple.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.history,
                              title: 'History',
                              onTap: () => context.push(RouteNames.history),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.orange.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.leaderboard,
                              title: 'Leaderboard',
                              onTap: () => context.push(RouteNames.leaderboard),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.amber.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.amber.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.store,
                              title: 'Store',
                              onTap: () => context.push(RouteNames.store),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              iconColor: Colors.green.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Logout',
                        type: ButtonType.outlined,
                        icon: Icons.logout,
                        onPressed: () async {
                          await StorageService.instance.removeAuthToken();
                          if (context.mounted) {
                            context.go(RouteNames.login);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
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

// Mini Stat Chip Widget
class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stat Box Widget
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Gradient? gradient;
  final Color? iconColor;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    this.gradient,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: (gradient as LinearGradient)
                    .colors
                    .map((c) => c.withOpacity(0.15))
                    .toList(),
                begin: (gradient as LinearGradient).begin,
                end: (gradient as LinearGradient).end,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (iconColor ?? Colors.white).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Inline Stat Item
class _InlineStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InlineStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? iconColor;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.gradient,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(
                  colors: (gradient as LinearGradient)
                      .colors
                      .map((c) => c.withOpacity(0.15))
                      .toList(),
                  begin: (gradient as LinearGradient).begin,
                  end: (gradient as LinearGradient).end,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Achievement Data Model
class _Achievement {
  final String id;
  final String imagePath;
  final String title;
  final String description;
  final Color color;

  const _Achievement({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.color,
  });
}

// Achievement Card Widget
class _AchievementCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color color;
  final bool isEarned;

  const _AchievementCard({
    required this.imagePath,
    required this.title,
    required this.color,
    this.isEarned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEarned
              ? [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)]
              : [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned
              ? color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                color: isEarned ? null : Colors.white.withValues(alpha: 0.2),
                colorBlendMode: isEarned ? null : BlendMode.modulate,
                errorBuilder: (c, e, s) => Icon(
                  Icons.emoji_events,
                  size: 50,
                  color: isEarned ? color : Colors.white38,
                ),
              ),
              if (!isEarned)
                Positioned.fill(
                  child: Icon(
                    Icons.lock,
                    size: 24,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isEarned ? Colors.white : Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Avatar Item Model
class _AvatarItem {
  final String id;
  final String name;
  final String? imagePath;
  final String? thumbPath;
  final int requiredLevel;
  final bool requiresVip;
  final bool requiresCoins;
  final int coinCost;
  final bool isDefaultIcon;

  const _AvatarItem({
    required this.id,
    required this.name,
    this.imagePath,
    this.thumbPath,
    required this.requiredLevel,
    this.requiresVip = false,
    this.requiresCoins = false,
    this.coinCost = 0,
    this.isDefaultIcon = false,
  });
}

// Avatar Tile Widget
class _AvatarTile extends StatelessWidget {
  final _AvatarItem item;
  final bool selected;
  final int userLevel;
  final bool isVip;
  final bool isPurchased;
  final VoidCallback onTap;

  const _AvatarTile({
    required this.item,
    required this.selected,
    required this.userLevel,
    required this.isVip,
    required this.isPurchased,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked =
        userLevel < item.requiredLevel ||
        (item.requiresVip && !isVip) ||
        (item.requiresCoins && !isPurchased);
    final unlockedBackground = const Color(0xFF0F1328);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: locked ? Colors.black26 : unlockedBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.white.withOpacity(0.7) : Colors.white12,
            width: selected ? 2.4 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 18,
                    spreadRadius: 4,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Avatar Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: locked ? Colors.white12 : AppColors.primary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    item.isDefaultIcon || item.thumbPath == null
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          )
                        : Image.asset(
                            item.thumbPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                    if (locked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 18,
                              ),
                              if (item.requiresCoins &&
                                  !isPurchased &&
                                  item.coinCost > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icons/coin_icon.png',
                                        width: 9,
                                        height: 9,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.monetization_on,
                                          color: Colors.white70,
                                          size: 9,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.coinCost}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: locked ? Colors.white38 : Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (locked) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: item.requiresVip
                      ? Colors.amber.withOpacity(0.25)
                      : item.requiresCoins
                      ? AppColors.primary.withOpacity(0.25)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item.requiresVip
                      ? 'VIP'
                      : item.requiresCoins
                      ? '${item.coinCost}'
                      : 'Lv${item.requiredLevel}',
                  style: TextStyle(
                    fontSize: 8,
                    color: item.requiresVip
                        ? Colors.amber
                        : item.requiresCoins
                        ? AppColors.primary
                        : Colors.white54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
