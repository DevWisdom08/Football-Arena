import 'package:dio/dio.dart';

class FriendsApiService {
  final Dio dio;

  FriendsApiService(this.dio);

  Future<Map<String, dynamic>> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final response = await dio.post(
        '/friends/request',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    try {
      final response = await dio.get('/friends/$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    try {
      final response = await dio.get('/friends/$userId/requests/pending');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> checkFriendship(String userId, String otherUserId) async {
    try {
      final response = await dio.get('/friends/check/$userId/$otherUserId');
      return response.data['areFriends'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final response = await dio.post(
        '/friends/request/$requestId/accept',
        data: {'userId': userId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> rejectFriendRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final response = await dio.post(
        '/friends/request/$requestId/reject',
        data: {'userId': userId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      final response = await dio.delete('/friends/$userId/$friendId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await dio.get('/users/search?q=$query');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 
          error.response?.data['error'] ?? 
          'An error occurred';
      return message;
    } else {
      return error.message ?? 'Network error occurred';
    }
  }
}

