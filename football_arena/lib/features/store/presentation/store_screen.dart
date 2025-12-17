import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/store_api_service.dart';
import '../../../core/network/users_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../shared/widgets/top_notification.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  int userCoins = 0;
  String? userId;
  bool isLoading = false;

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
        userCoins = (userData['coins'] ?? 0) as int;
      });
    }
  }

  Future<void> _refreshUserDataFromAPI() async {
    if (userId == null) return;

    try {
      final usersService = ref.read(usersApiServiceProvider);
      final freshUserData = await usersService.getUserById(userId!);
      
      // Update storage with fresh data
      await StorageService.instance.saveUserData(freshUserData);
      
      // Update UI
      setState(() {
        userCoins = (freshUserData['coins'] ?? 0) + 
                    (freshUserData['purchasedCoins'] ?? 0) + 
                    (freshUserData['withdrawableCoins'] ?? 0);
      });
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // DEBUG: Quick way to add test coins for development
  Future<void> _addTestCoins() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      final usersService = ref.read(usersApiServiceProvider);
      
      // Add 10,000 coins for testing
      await usersService.addCoins(
        userId: userId!,
        amount: 10000,
        reason: 'Test coins for development',
      );

      await _refreshUserDataFromAPI();

      if (mounted) {
        TopNotification.show(
          context,
          message: '✅ Added 10,000 test coins!',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context,
          message: 'Error adding test coins: ${e.toString()}',
          type: NotificationType.error,
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _purchaseItem({
    required String itemType,
    required String itemId,
    required String paymentMethod,
    String? transactionId,
  }) async {
    if (userId == null) {
      TopNotification.show(
        context,
        message: context.l10n.pleaseLoginToPurchase,
        type: NotificationType.error,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final storeService = ref.read(storeApiServiceProvider);
      final result = await storeService.purchaseItem(
        userId: userId!,
        itemType: itemType,
        itemId: itemId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
      );

      if (result['success'] == true) {
        TopNotification.show(
          context,
          message: result['message'] ?? context.l10n.purchaseSuccessful,
          type: NotificationType.success,
        );

        // Refresh user data from API to get updated coins
        await _refreshUserDataFromAPI();

        // Also update from result if provided
        if (result['newBalance'] != null) {
          setState(() {
            userCoins = result['newBalance'] as int;
          });
        }
      }
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
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
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    // DEBUG: Quick coins for testing
                    IconButton(
                      onPressed: () => _addTestCoins(),
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Add 10,000 test coins',
                    ),
                    Text(
                      context.l10n.store,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.coinsGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/coin_icon.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$userCoins',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.coinPacks,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Coin packs
                      _StoreItem(
                        title: context.l10n.smallPack,
                        subtitle: context.l10n.coins(500),
                        price: '\$0.99',
                        iconAsset: 'assets/icons/coin_icon.png',
                        gradient: AppColors.coinsGradient,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'coin_pack',
                          itemId: 'small',
                          paymentMethod: 'iap',
                          transactionId:
                              'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StoreItem(
                        title: context.l10n.mediumPack,
                        subtitle: context.l10n.coins(1500),
                        price: '\$2.99',
                        iconAsset: 'assets/icons/coins_dumb.png',
                        gradient: AppColors.coinsGradient,
                        badge: context.l10n.bonus20Percent,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'coin_pack',
                          itemId: 'medium',
                          paymentMethod: 'iap',
                          transactionId:
                              'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StoreItem(
                        title: context.l10n.largePack,
                        subtitle: context.l10n.coins(5000),
                        price: '\$7.99',
                        iconAsset: 'assets/icons/coins_mass.png',
                        gradient: AppColors.coinsGradient,
                        badge: context.l10n.bestValue,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'coin_pack',
                          itemId: 'large',
                          paymentMethod: 'iap',
                          transactionId:
                              'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        context.l10n.vipMembership,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _StoreItem(
                        title: context.l10n.vipMonthly,
                        subtitle: context.l10n.noAds,
                        price: '\$4.99/mo',
                        iconAsset: 'assets/icons/vip.png',
                        gradient: AppColors.primaryGradient,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'vip_subscription',
                          itemId: 'monthly',
                          paymentMethod: 'subscription',
                          transactionId:
                              'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        context.l10n.boosts,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _StoreItem(
                        title: context.l10n.extraTimeBoost,
                        subtitle: context.l10n.plus5Seconds,
                        price: '50',
                        icon: Icons.timer,
                        gradient: AppColors.challenge1v1Gradient,
                        isCoinPrice: true,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'boost',
                          itemId: 'extra_time',
                          paymentMethod: 'coins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StoreItem(
                        title: context.l10n.skipQuestion,
                        subtitle: context.l10n.skipAnyQuestion,
                        price: '30',
                        icon: Icons.skip_next,
                        gradient: AppColors.teamMatchGradient,
                        isCoinPrice: true,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'boost',
                          itemId: 'skip',
                          paymentMethod: 'coins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StoreItem(
                        title: context.l10n.revealWrongOption,
                        subtitle: context.l10n.revealOneWrong,
                        price: '40',
                        icon: Icons.visibility,
                        gradient: AppColors.dailyQuizGradient,
                        isCoinPrice: true,
                        isLoading: isLoading,
                        onPurchase: () => _purchaseItem(
                          itemType: 'boost',
                          itemId: 'reveal_wrong',
                          paymentMethod: 'coins',
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
    );
  }
}

class _StoreItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final IconData? icon;
  final String? iconAsset;
  final Gradient gradient;
  final String? badge;
  final bool isLoading;
  final VoidCallback? onPurchase;
  final bool isCoinPrice;

  const _StoreItem({
    required this.title,
    required this.subtitle,
    required this.price,
    this.icon,
    this.iconAsset,
    required this.gradient,
    this.badge,
    this.isLoading = false,
    this.onPurchase,
    this.isCoinPrice = false,
  });

  Color _getGradientColor() {
    // Extract primary color from gradient for border/glow
    if (gradient == AppColors.coinsGradient) {
      return Colors.amber.shade400;
    } else if (gradient == AppColors.primaryGradient) {
      return AppColors.primary;
    } else if (gradient == AppColors.challenge1v1Gradient) {
      return Colors.blue.shade400;
    } else if (gradient == AppColors.teamMatchGradient) {
      return Colors.green.shade400;
    } else if (gradient == AppColors.dailyQuizGradient) {
      return Colors.orange.shade400;
    }
    return AppColors.primary;
  }

  Gradient _getTransparentGradient() {
    // Create transparent version of gradient for background
    if (gradient is LinearGradient) {
      final linear = gradient as LinearGradient;
      return LinearGradient(
        colors: linear.colors.map((c) => c.withOpacity(0.15)).toList(),
        begin: linear.begin,
        end: linear.end,
      );
    }
    return gradient;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getGradientColor();
    
    return GestureDetector(
      onTap: isLoading ? null : onPurchase,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _getTransparentGradient(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
          // Icon container - no background for coin images
          iconAsset != null
              ? SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    iconAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon ?? Icons.monetization_on,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _getGradientColor().withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon ?? Icons.monetization_on,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColor().withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isCoinPrice
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/coin_icon.png',
                        width: 14,
                        height: 14,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
