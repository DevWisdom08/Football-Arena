import 'package:dio/dio.dart';

class CoinsApiService {
  final Dio dio;

  CoinsApiService(this.dio);

  /// Spend coins for a specific reason (boost, energy, tournament, etc.)
  Future<Map<String, dynamic>> spendCoins({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/users/$userId/coins/spend',
        data: {'amount': amount, 'reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add coins (for refills, rewards, etc.)
  Future<Map<String, dynamic>> addCoins({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/users/$userId/coins/add',
        data: {'amount': amount, 'reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final message =
          error.response?.data['message'] ??
          error.response?.data['error'] ??
          'An error occurred';
      return message;
    } else {
      return error.message ?? 'Network error occurred';
    }
  }
}
