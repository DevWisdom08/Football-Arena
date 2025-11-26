import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/coins_api_service.dart';
import '../network/users_api_service.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/top_notification.dart';

/// Service for handling rewarded ads
/// Note: This is a mock implementation. Replace with actual ad network integration
class RewardedAdsService {
  final CoinsApiService coinsService;
  final UsersApiService usersService;
  final Dio dio;
  
  RewardedAdsService(this.coinsService, this.usersService, this.dio);

  /// Show rewarded ad and give rewards on completion
  /// Returns true if ad was watched successfully
  Future<bool> showRewardedAd({
    required BuildContext context,
    required String rewardType, // 'coins', 'xp', or 'both'
    int coinsReward = 25,
    int xpReward = 50,
  }) async {
    try {
      // Mock ad watching - replace with actual ad network
      // For now, simulate ad watching with a dialog
      final watched = await _showMockAdDialog(context);
      
      if (!watched) {
        return false;
      }

      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        TopNotification.show(
          context,
          message: 'Please login to earn rewards',
          type: NotificationType.error,
        );
        return false;
      }

      // Give rewards based on type
      int coinsToAdd = 0;
      int xpToAdd = 0;

      if (rewardType == 'coins' || rewardType == 'both') {
        coinsToAdd = coinsReward;
      }
      if (rewardType == 'xp' || rewardType == 'both') {
        xpToAdd = xpReward;
      }

      // Add coins
      if (coinsToAdd > 0) {
        await coinsService.addCoins(
          userId: userId,
          amount: coinsToAdd,
          reason: 'rewarded_ad_coins',
        );
      }

      // Add XP (and check for level up) - use backend endpoint
      if (xpToAdd > 0) {
        try {
          final response = await dio.post(
            '/users/$userId/xp/add',
            data: {
              'amount': xpToAdd,
              'reason': 'rewarded_ad_xp',
            },
          );
          
          final result = response.data;
          if (result['leveledUp'] == true) {
            final levelUpReward = result['levelUpReward'] ?? 0;
            _showLevelUpDialog(context, result['user']['level'], levelUpReward);
            
            // Update local data with level up
            final userData = StorageService.instance.getUserData();
            if (userData != null) {
              userData['level'] = result['user']['level'];
              userData['xp'] = result['user']['xp'];
              userData['coins'] = result['user']['coins'];
              StorageService.instance.saveUserData(userData);
            }
          } else {
            // Just update XP
            final userData = StorageService.instance.getUserData();
            if (userData != null) {
              userData['xp'] = result['user']['xp'];
              StorageService.instance.saveUserData(userData);
            }
          }
        } catch (e) {
          // Fallback: just add XP without level check
          final userData = StorageService.instance.getUserData();
          if (userData != null) {
            userData['xp'] = (userData['xp'] ?? 0) + xpToAdd;
            StorageService.instance.saveUserData(userData);
          }
        }
      }

      // Update local user data
      final userData = StorageService.instance.getUserData();
      if (userData != null) {
        if (coinsToAdd > 0) {
          userData['coins'] = (userData['coins'] ?? 0) + coinsToAdd;
        }
        if (xpToAdd > 0) {
          userData['xp'] = (userData['xp'] ?? 0) + xpToAdd;
        }
        StorageService.instance.saveUserData(userData);
      }

      // Show success message
      TopNotification.show(
        context,
        message: coinsToAdd > 0 && xpToAdd > 0
            ? 'Earned $coinsToAdd coins and $xpToAdd XP!'
            : coinsToAdd > 0
                ? 'Earned $coinsToAdd coins!'
                : 'Earned $xpToAdd XP!',
        type: NotificationType.success,
      );

      return true;
    } catch (e) {
      TopNotification.show(
        context,
        message: 'Failed to claim reward: ${e.toString()}',
        type: NotificationType.error,
      );
      return false;
    }
  }


  /// Show level up celebration dialog
  void _showLevelUpDialog(BuildContext context, int newLevel, int coinsReward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'Level Up!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You reached Level $newLevel!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/coin_icon.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$coinsReward Coins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Awesome!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mock ad dialog (replace with actual ad network)
  Future<bool> _showMockAdDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Watch Ad',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 60, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Watch a short ad to earn rewards!',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Note: This is a mock ad. Replace with actual ad network integration.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    ) ?? false;
  }
}

final rewardedAdsServiceProvider = Provider<RewardedAdsService>((ref) {
  final dio = ref.watch(dioProvider);
  final coinsService = CoinsApiService(dio);
  final usersService = UsersApiService(dio);
  return RewardedAdsService(coinsService, usersService, dio);
});

