import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../network/coins_api_service.dart';
import '../services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TournamentService {
  final Dio dio;
  final CoinsApiService coinsService;

  TournamentService(this.dio, this.coinsService);

  /// Check if user can enter tournament (has enough coins)
  Future<bool> canEnterTournament(String tournamentId, int entryFee) async {
    final userId = StorageService.instance.getUserId();
    if (userId == null) return false;

    try {
      final userData = StorageService.instance.getUserData();
      final userCoins = userData?['coins'] ?? 0;
      return userCoins >= entryFee;
    } catch (e) {
      return false;
    }
  }

  /// Enter tournament by paying entry fee via backend API
  Future<Map<String, dynamic>> enterTournament({
    required String tournamentId,
    required int entryFee,
    required String tournamentName,
  }) async {
    final userId = StorageService.instance.getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Check if user has enough coins
    final canEnter = await canEnterTournament(tournamentId, entryFee);
    if (!canEnter) {
      throw Exception('Insufficient coins. Need $entryFee coins to enter.');
    }

    try {
      // Call backend API to enter tournament
      final response = await dio.post(
        '/game/tournaments/$tournamentId/enter',
        data: {'userId': userId},
      );

      final result = response.data;

      // Update local user data
      final userData = StorageService.instance.getUserData();
      if (userData != null) {
        userData['coins'] = (userData['coins'] ?? 0) - entryFee;
        StorageService.instance.saveUserData(userData);
      }

      return {
        'success': result['success'] ?? true,
        'tournamentId': tournamentId,
        'tournamentName': tournamentName,
        'entryFee': entryFee,
        'message': result['message'] ?? 'Successfully entered $tournamentName',
      };
    } catch (e) {
      throw Exception('Failed to enter tournament: ${e.toString()}');
    }
  }

  /// Get available tournaments from backend API
  Future<List<Map<String, dynamic>>> getAvailableTournaments() async {
    try {
      final response = await dio.get('/game/tournaments/available');
      final List<dynamic> tournamentsJson = response.data;
      
      return tournamentsJson.map((json) {
        return {
          'id': json['id'],
          'name': json['name'],
          'description': json['description'] ?? '',
          'entryFee': json['entryFee'] ?? 0,
          'prizePool': json['prizePool'] ?? 0,
          'startDate': DateTime.parse(json['startDate']),
          'endDate': DateTime.parse(json['endDate']),
          'participants': json['currentParticipants'] ?? 0,
          'maxParticipants': json['maxParticipants'] ?? 100,
          'gameMode': json['gameMode'] ?? 'solo',
          'questionsCount': json['questionsCount'] ?? 10,
        };
      }).toList();
    } catch (e) {
      // If API fails, return empty list
      // ignore: avoid_print
      debugPrint('Failed to fetch tournaments: $e');
      return [];
    }
  }
}

final tournamentServiceProvider = Provider<TournamentService>((ref) {
  final dio = ref.watch(dioProvider);
  final coinsService = CoinsApiService(dio);
  return TournamentService(dio, coinsService);
});

