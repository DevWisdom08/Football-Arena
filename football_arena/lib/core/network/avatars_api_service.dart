import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

class AvatarsApiService {
  final Dio dio;

  AvatarsApiService(this.dio);

  /// Get all available avatars
  Future<List<Map<String, dynamic>>> getAllAvatars() async {
    try {
      final response = await dio.get('/avatars');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's unlocked avatars
  Future<List<Map<String, dynamic>>> getUserUnlockedAvatars(String userId) async {
    try {
      final response = await dio.get('/avatars/user/$userId/unlocked');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's equipped avatar
  Future<Map<String, dynamic>?> getEquippedAvatar(String userId) async {
    try {
      final response = await dio.get('/avatars/user/$userId/equipped');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Equip an avatar
  Future<Map<String, dynamic>> equipAvatar({
    required String userId,
    required String avatarId,
  }) async {
    try {
      final response = await dio.post('/avatars/user/$userId/equip/$avatarId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unlock an avatar with coins
  Future<Map<String, dynamic>> unlockAvatarWithCoins({
    required String userId,
    required String avatarId,
  }) async {
    try {
      final response = await dio.post('/avatars/user/$userId/unlock/$avatarId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check and unlock avatars based on user level
  Future<List<Map<String, dynamic>>> checkAndUnlockAvatars(String userId) async {
    try {
      final response = await dio.post('/avatars/user/$userId/check-unlocks');
      return List<Map<String, dynamic>>.from(response.data);
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

final avatarsApiServiceProvider = Provider<AvatarsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AvatarsApiService(dio);
});

