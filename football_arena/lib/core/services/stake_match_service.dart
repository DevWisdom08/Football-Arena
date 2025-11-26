import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stake_match.dart';
import '../config/api_config.dart';

class StakeMatchService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Create a new stake match
  Future<StakeMatch> createStakeMatch({
    required String userId,
    required int stakeAmount,
    String difficulty = 'mixed',
    int numberOfQuestions = 10,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stake-matches'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'stakeAmount': stakeAmount,
          'difficulty': difficulty,
          'numberOfQuestions': numberOfQuestions,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return StakeMatch.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create stake match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating stake match: $e');
    }
  }

  // Get available stake matches
  Future<List<StakeMatch>> getAvailableMatches({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stake-matches/available?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StakeMatch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load available matches');
      }
    } catch (e) {
      throw Exception('Error loading available matches: $e');
    }
  }

  // Join a stake match
  Future<StakeMatch> joinStakeMatch({
    required String userId,
    required String matchId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stake-matches/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'matchId': matchId,
        }),
      );

      if (response.statusCode == 200) {
        return StakeMatch.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to join stake match: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error joining stake match: $e');
    }
  }

  // Complete a stake match
  Future<StakeMatch> completeStakeMatch({
    required String matchId,
    required int creatorScore,
    required int opponentScore,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stake-matches/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'matchId': matchId,
          'creatorScore': creatorScore,
          'opponentScore': opponentScore,
        }),
      );

      if (response.statusCode == 200) {
        return StakeMatch.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to complete stake match');
      }
    } catch (e) {
      throw Exception('Error completing stake match: $e');
    }
  }

  // Cancel a stake match
  Future<void> cancelStakeMatch({
    required String userId,
    required String matchId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/stake-matches/$matchId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel stake match');
      }
    } catch (e) {
      throw Exception('Error cancelling stake match: $e');
    }
  }

  // Get user's stake match history
  Future<List<StakeMatch>> getUserMatches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stake-matches/my-matches/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StakeMatch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user matches');
      }
    } catch (e) {
      throw Exception('Error loading user matches: $e');
    }
  }

  // Get stake match by ID
  Future<StakeMatch> getStakeMatchById(String matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stake-matches/$matchId'),
      );

      if (response.statusCode == 200) {
        return StakeMatch.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load stake match');
      }
    } catch (e) {
      throw Exception('Error loading stake match: $e');
    }
  }
}

