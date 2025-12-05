import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/logout_button.dart';
import '../../../shared/widgets/app_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when screen becomes visible again
    // This ensures avatar and country updates from profile edit show immediately
    _loadUserData();
  }

  void _loadUserData() {
    final data = StorageService.instance.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh when widget updates
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
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
        body: Stack(
          children: [
            // Blurred background layer
            // Positioned.fill(
            //   child: BackdropFilter(
            //     filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            //     child: Container(
            //       color: Colors.transparent,
            //     ),
            //   ),
            // ),
            // Content layer
            SafeArea(
              bottom: false, // Let bottom bar handle safe area
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlayerCard(userData: userData),
                    const SizedBox(height: 20),
                    _DailyQuizTile(context),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.gameModes,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.heading),
                    ),
                    const SizedBox(height: 14),
                    _GameModeGrid(context),
                    const SizedBox(height: 14),
                    _StoreBanner(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomBar(currentIndex: 0),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const _PlayerCard({this.userData});

  @override
  Widget build(BuildContext context) {
    // Extract user data with fallbacks
    final username = userData?['username'] ?? 'Guest';
    final level = userData?['level'] ?? 1;
    final country = userData?['country'] ?? 'Unknown';
    final xp = userData?['xp'] ?? 0;
    final nextLevelXp = (level * 1000).toDouble();
    final currentLevelXp = ((level - 1) * 1000).toDouble();
    final xpProgress = nextLevelXp > currentLevelXp
        ? (xp - currentLevelXp) / (nextLevelXp - currentLevelXp)
        : 0.0;
    final xpProgressClamped = xpProgress.clamp(0.0, 1.0);
    const cardRadius = 26.0;
    return CustomCard(
      padding: EdgeInsets.zero,
      borderRadius: cardRadius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_back.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              userData?['avatarUrl'] != null &&
                                  userData!['avatarUrl'].toString().isNotEmpty
                              ? Image.asset(
                                  userData!['avatarUrl'],
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to default icon
                                    return Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.primaryGradient,
                                      ),
                                      child: const Icon(
                                        Icons.sports_soccer,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: const Icon(
                                    Icons.sports_soccer,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level $level - $country',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.push(RouteNames.profile);
                        },
                        icon: const Icon(Icons.person_outline),
                        color: AppColors.primary,
                        tooltip: context.l10n.profile,
                      ),
                      const LogoutButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/xp coin.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.xpProgress,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: xpProgressClamped,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: AppColors.xpGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${xp.toInt()} / ${nextLevelXp.toInt()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _DailyQuizTile(BuildContext context) {
  final dailyQuizData = _ModeTileData(
    iconPath: 'assets/icons/daily_quiz_icon.png',
    title: context.l10n.dailyQuiz,
    subtitle: context.l10n.twoXRewards,
    gradient: AppColors.dailyQuizGradient,
    onTap: () => context.push(RouteNames.dailyQuiz),
  );
  
  return _ModeTile(data: dailyQuizData);
}

Widget _GameModeGrid(BuildContext context) {
  final tiles = [
    _ModeTileData(
      iconPath: 'assets/icons/solo_mode_icon.png',
      title: context.l10n.soloMode,
      subtitle: context.l10n.quickQuiz,
      gradient: AppColors.soloModeGradient,
      onTap: () => context.push(RouteNames.soloMode),
    ),
    _ModeTileData(
      iconPath: 'assets/icons/challenge_1v1_icon.png',
      title: context.l10n.challenge1v1,
      subtitle: context.l10n.duelMode,
      gradient: AppColors.challenge1v1Gradient,
      onTap: () => context.push(RouteNames.challenge1v1),
    ),
    _ModeTileData(
      iconPath: 'assets/icons/team_match_icon.png',
      title: context.l10n.teamMatch,
      subtitle: context.l10n.upTo10Players,
      gradient: AppColors.teamMatchGradient,
      onTap: () => context.push(RouteNames.teamMatch),
    ),
    _ModeTileData(
      iconPath: 'assets/icons/challenge_1v1_icon.png',
      title: '⚔️ Stake Match Arena',
      subtitle: 'Win Real Money',
      gradient: LinearGradient(
        colors: [Colors.green.shade700, Colors.amber.shade700],
      ),
      onTap: () => context.push(RouteNames.stakeMatch),
    ),
    _ModeTileData(
      iconPath: 'assets/icons/coin_icon.png',
      title: '💰 Withdraw Winnings',
      subtitle: 'Cash Out Your Coins',
      gradient: LinearGradient(
        colors: [Colors.purple.shade700, Colors.pink.shade700],
      ),
      onTap: () => context.push(RouteNames.withdrawal),
    ),
  ];

  return Column(
    children: tiles
        .map(
          (tile) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ModeTile(data: tile),
          ),
        )
        .toList(),
  );
}

class _ModeTileData {
  final String? iconPath;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  _ModeTileData({
    this.iconPath,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

class _ModeTile extends StatelessWidget {
  final _ModeTileData data;

  const _ModeTile({required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine background image based on game mode
    String? backgroundImage;
    double? cardHeight;
    final l10n = context.l10n;
    if (data.title == l10n.soloMode) {
      backgroundImage = 'assets/icons/solo_mode.jpg';
      cardHeight = 100;
    } else if (data.title == l10n.challenge1v1) {
      backgroundImage = 'assets/icons/challenge.jpeg';
      cardHeight = 100;
    } else if (data.title == l10n.teamMatch) {
      backgroundImage = 'assets/icons/daily_quiz.jpg';
      cardHeight = 100;
    } else if (data.title == l10n.dailyQuiz) {
      backgroundImage = 'assets/icons/team_match.jpg';
      cardHeight = 100;
    } else if (data.title == '⚔️ Stake Match Arena') {
      backgroundImage = 'assets/images/card1.png';
      cardHeight = 120; // Taller card
    } else if (data.title == '💰 Withdraw Winnings') {
      backgroundImage = 'assets/images/withdraw.png';
      cardHeight = 120; // Same height as Stake Match
    }

    // Determine if this is a tall card that needs smaller content
    final isTallCard = cardHeight != null && cardHeight > 100;
    
    Widget cardContent = Row(
      children: [
        // Icon on the left - Extra large with shadow, no background
        Container(
          width: isTallCard ? 80 : 90,
          height: isTallCard ? 80 : 90,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 4,
              ),
            ],
          ),
          child: data.iconPath != null
              ? Image.asset(
                  data.iconPath!,
                  width: isTallCard ? 80 : 90,
                  height: isTallCard ? 80 : 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.gamepad,
                      color: Colors.white,
                      size: isTallCard ? 60 : 70,
                      shadows: const [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    );
                  },
                )
              : Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: isTallCard ? 60 : 70,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
        ),
        SizedBox(width: isTallCard ? 16 : 20),
        // Text in the middle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  fontSize: isTallCard ? 20 : 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isTallCard ? 2 : 4),
              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: isTallCard ? 14 : 15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        // Arrow on the right
        Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.7),
          size: isTallCard ? 18 : 20,
        ),
      ],
    );

    // If mode has custom background image, use it
    if (backgroundImage != null) {
      return InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: cardHeight ?? 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            padding: EdgeInsets.all(isTallCard ? 16 : 18),
            child: cardContent,
          ),
        ),
      );
    }

    // Fallback to gradient if no custom background
    return CustomCard(
      gradient: data.gradient,
      borderRadius: 20,
      onTap: data.onTap,
      child: cardContent,
    );
  }
}

Widget _StoreBanner(BuildContext context) {
  const radius = 28.0;
  return CustomCard(
    padding: EdgeInsets.zero,
    borderRadius: radius,
    onTap: () => context.push(RouteNames.store),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/card2.png', fit: BoxFit.cover),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.visitStore,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.boostsAndItems,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    context.l10n.open,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
