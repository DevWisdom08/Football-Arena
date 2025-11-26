import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class UsersApiService {
  final Dio dio;

  UsersApiService(this.dio);

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.userById(id));
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({
    int limit = 50,
    String type = 'global',
    String filter = 'alltime',
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'type': type,
        'filter': filter,
      };
      if (userId != null) {
        queryParams['userId'] = userId;
      }
      
      final response = await dio.get(
        ApiEndpoints.leaderboard(limit: limit),
        queryParameters: queryParams,
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(ApiEndpoints.userById(id), data: data);
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

final usersApiServiceProvider = Provider<UsersApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersApiService(dio);
});

