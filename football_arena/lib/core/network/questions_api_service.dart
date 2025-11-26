import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class QuestionsApiService {
  final Dio dio;

  QuestionsApiService(this.dio);

  Future<List<Map<String, dynamic>>> getRandomQuestions({
    int count = 10,
    String? difficulty,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.randomQuestions(count: count, difficulty: difficulty),
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsByCategory({
    required String category,
    int count = 10,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.questionsByCategory(category, count: count),
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    try {
      final response = await dio.get(ApiEndpoints.questions);
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> seedQuestions() async {
    try {
      final response = await dio.post(ApiEndpoints.seedQuestions);
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

final questionsApiServiceProvider = Provider<QuestionsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return QuestionsApiService(dio);
});

