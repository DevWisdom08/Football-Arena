import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String country,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'country': country,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> guestLogin() async {
    try {
      final response = await dio.post(ApiEndpoints.guestLogin);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.me);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> appleSignIn({
    required String appleId,
    required String email,
    String? name,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.appleSignIn,
        data: {
          'appleId': appleId,
          'email': email,
          if (name != null) 'name': name,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> googleSignIn({
    required String googleId,
    required String email,
    String? name,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.googleSignIn,
        data: {
          'googleId': googleId,
          'email': email,
          if (name != null) 'name': name,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> upgradeGuestAccount({
    required String userId,
    required String email,
    required String password,
    String? username,
    String? country,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.upgradeGuest,
        data: {
          'userId': userId,
          'email': email,
          'password': password,
          if (username != null) 'username': username,
          if (country != null) 'country': country,
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

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApiService(dio);
});

