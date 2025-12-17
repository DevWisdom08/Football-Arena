import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stake_match.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class StakeMatchApiService {
  final Dio dio;

  StakeMatchApiService(this.dio);

  /// Create a new stake match
  Future<StakeMatch> createStakeMatch({
    required String userId,
    required int stakeAmount,
    String? difficulty,
    int? numberOfQuestions,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.stakeMatches,
        data: {
          'userId': userId,
          'stakeAmount': stakeAmount,
          'difficulty': difficulty ?? 'mixed',
          'numberOfQuestions': numberOfQuestions ?? 10,
        },
      );

      return StakeMatch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all available stake matches
  Future<List<StakeMatch>> getAvailableMatches() async {
    try {
      final response = await dio.get('${ApiEndpoints.stakeMatches}/available');

      final List<dynamic> data = response.data;
      return data.map((json) => StakeMatch.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's stake matches
  Future<List<StakeMatch>> getUserMatches(String userId) async {
    try {
      final response = await dio.get('${ApiEndpoints.stakeMatches}/user/$userId');

      final List<dynamic> data = response.data;
      return data.map((json) => StakeMatch.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Join a stake match
  Future<StakeMatch> joinStakeMatch({
    required String userId,
    required String matchId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.stakeMatches}/$matchId/join',
        data: {'userId': userId},
      );

      return StakeMatch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel a stake match
  Future<void> cancelStakeMatch({
    required String userId,
    required String matchId,
    required String reason,
  }) async {
    try {
      await dio.delete(
        '${ApiEndpoints.stakeMatches}/$matchId',
        data: {
          'userId': userId,
          'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete a stake match with scores
  Future<StakeMatch> completeStakeMatch({
    required String matchId,
    required int myScore,
    required bool isCreator,
  }) async {
    try {
      // In a real implementation with real-time gameplay,
      // both players would submit their scores separately
      // For now, we'll submit with placeholder opponent score
      final response = await dio.post(
        '${ApiEndpoints.stakeMatches}/complete',
        data: {
          'matchId': matchId,
          'creatorScore': isCreator ? myScore : 0,
          'opponentScore': isCreator ? 0 : myScore,
        },
      );

      return StakeMatch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'An error occurred';
      return Exception(message);
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else {
      return Exception('Network error. Please try again.');
    }
  }
}

final stakeMatchApiServiceProvider = Provider<StakeMatchApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return StakeMatchApiService(dio);
});
