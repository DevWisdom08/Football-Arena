import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

class DailyQuizApiService {
  final Dio dio;

  DailyQuizApiService(this.dio);

  Future<Map<String, dynamic>> getDailyQuiz(String userId) async {
    try {
      final response = await dio.get('/game/daily-quiz?userId=$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitDailyQuiz({
    required String userId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await dio.post(
        '/game/daily-quiz/submit',
        data: {'userId': userId, 'answers': answers},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getDailyQuizHistory(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final response = await dio.get(
        '/game/daily-quiz/history/$userId?limit=$limit',
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDailyQuizStats(String userId) async {
    try {
      final response = await dio.get('/game/daily-quiz/stats/$userId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> protectStreak({
    required String userId,
    required String method, // 'coins' or 'vip'
  }) async {
    try {
      final response = await dio.post(
        '/game/daily-quiz/protect-streak',
        data: {'userId': userId, 'method': method},
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

final dailyQuizApiServiceProvider = Provider<DailyQuizApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return DailyQuizApiService(dio);
});
