import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

class GameApiService {
  final Dio dio;

  GameApiService(this.dio);

  Future<List<Map<String, dynamic>>> getMatchHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/game/history/$userId',
        queryParameters: {'limit': limit},
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMatchHistoryByMode({
    required String userId,
    required String mode,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/game/history/$userId/mode/$mode',
        queryParameters: {'limit': limit},
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMatchStats(String userId) async {
    try {
      final response = await dio.get('/game/stats/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitSoloResult({
    required String userId,
    required int correctAnswers,
    required int totalQuestions,
    required int accuracy,
    required int xpGained,
    required int coinsGained,
    required int score,
    int? duration,
  }) async {
    try {
      final response = await dio.post(
        '/game/solo/submit',
        data: {
          'userId': userId,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'accuracy': accuracy,
          'xpGained': xpGained,
          'coinsGained': coinsGained,
          'score': score,
          'duration': duration,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) return message.first;
      return 'An error occurred: ${e.response?.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server response timeout. Please try again.';
    }
    return 'Network error. Please check your connection.';
  }
}

final gameApiServiceProvider = Provider<GameApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return GameApiService(dio);
});

