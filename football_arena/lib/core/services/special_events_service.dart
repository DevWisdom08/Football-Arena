import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../network/coins_api_service.dart';
import '../network/users_api_service.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/top_notification.dart';

/// Special event types
enum EventType {
  doubleXP, // Double XP for all games
  doubleCoins, // Double coins for all games
  bonusReward, // Special bonus rewards
  weekendBonus, // Weekend special event
}

/// Special event model
class SpecialEvent {
  final String id;
  final EventType type;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> rewards; // {coins: int, xp: int}

  SpecialEvent({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.rewards,
  });

  factory SpecialEvent.fromJson(Map<String, dynamic> json) {
    EventType eventType;
    switch (json['type']) {
      case 'doubleXP':
        eventType = EventType.doubleXP;
        break;
      case 'doubleCoins':
        eventType = EventType.doubleCoins;
        break;
      case 'bonusReward':
        eventType = EventType.bonusReward;
        break;
      case 'weekendBonus':
        eventType = EventType.weekendBonus;
        break;
      default:
        eventType = EventType.bonusReward;
    }

    return SpecialEvent(
      id: json['id'],
      type: eventType,
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      rewards: {
        'xpMultiplier': (json['xpMultiplier'] ?? 1.0).toDouble(),
        'coinsMultiplier': (json['coinsMultiplier'] ?? 1.0).toDouble(),
        'bonusCoins': json['bonusCoins'] ?? 0,
        'bonusXp': json['bonusXp'] ?? 0,
      },
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDate);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }
}

class SpecialEventsService {
  final Dio dio;
  final CoinsApiService coinsService;
  final UsersApiService usersService;

  SpecialEventsService(this.dio, this.coinsService, this.usersService);

  /// Get active special events from backend API
  Future<List<SpecialEvent>> getActiveEvents() async {
    try {
      final response = await dio.get('/game/events/active');
      final List<dynamic> eventsJson = response.data;
      return eventsJson.map((json) => SpecialEvent.fromJson(json)).toList();
    } catch (e) {
      // If API fails, return empty list
      // ignore: avoid_print
      debugPrint('Failed to fetch active events: $e');
      return [];
    }
  }

  /// Claim event bonus reward
  Future<bool> claimEventReward({
    required BuildContext context,
    required String eventId,
    required int coinsReward,
    required int xpReward,
  }) async {
    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        TopNotification.show(
          context,
          message: 'Please login to claim rewards',
          type: NotificationType.error,
        );
        return false;
      }

      // Check if already claimed today
      final lastClaimKey = 'event_${eventId}_last_claim';
      final lastClaim = StorageService.instance.getString(lastClaimKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastClaim == today) {
        TopNotification.show(
          context,
          message: 'You already claimed this reward today!',
          type: NotificationType.warning,
        );
        return false;
      }

      // Add coins
      if (coinsReward > 0) {
        await coinsService.addCoins(
          userId: userId,
          amount: coinsReward,
          reason: 'special_event_$eventId',
        );
      }

      // Add XP
      if (xpReward > 0) {
        final userData = StorageService.instance.getUserData();
        if (userData != null) {
          final oldXP = userData['xp'] ?? 0;
          final newXP = oldXP + xpReward;
          await usersService.updateUser(userId, {'xp': newXP});

          // Check for level up
          final oldLevel = userData['level'] ?? 1;
          final newLevel = (newXP ~/ 1000) + 1;

          if (newLevel > oldLevel) {
            final levelUpCoins = newLevel * 10;
            await coinsService.addCoins(
              userId: userId,
              amount: levelUpCoins,
              reason: 'level_up_reward',
            );
            await usersService.updateUser(userId, {'level': newLevel});

            userData['level'] = newLevel;
            userData['coins'] =
                (userData['coins'] ?? 0) + coinsReward + levelUpCoins;
          } else {
            userData['coins'] = (userData['coins'] ?? 0) + coinsReward;
          }

          userData['xp'] = newXP;
          StorageService.instance.saveUserData(userData);
        }
      }

      // Mark as claimed
      StorageService.instance.setString(lastClaimKey, today);

      if (context.mounted) {
        TopNotification.show(
          context,
          message: 'Event reward claimed! +$coinsReward coins, +$xpReward XP',
          type: NotificationType.success,
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        TopNotification.show(
          context,
          message: 'Failed to claim reward: ${e.toString()}',
          type: NotificationType.error,
        );
      }
      return false;
    }
  }

  /// Get multiplier for current active events from backend API
  Future<Map<String, double>> getActiveMultipliers() async {
    try {
      final response = await dio.get('/game/events/multipliers/active');
      final data = response.data;
      return {
        'xp': (data['xp'] ?? 1.0).toDouble(),
        'coins': (data['coins'] ?? 1.0).toDouble(),
      };
    } catch (e) {
      // If API fails, return default multipliers
      // ignore: avoid_print
      debugPrint('Failed to fetch active multipliers: $e');
      return {'xp': 1.0, 'coins': 1.0};
    }
  }
}

final specialEventsServiceProvider = Provider<SpecialEventsService>((ref) {
  final dio = ref.watch(dioProvider);
  final coinsService = CoinsApiService(dio);
  final usersService = UsersApiService(dio);
  return SpecialEventsService(dio, coinsService, usersService);
});
