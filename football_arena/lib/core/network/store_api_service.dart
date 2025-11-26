import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class StoreApiService {
  final Dio dio;

  StoreApiService(this.dio);

  Future<Map<String, dynamic>> getStoreItems() async {
    try {
      final response = await dio.get(ApiEndpoints.storeItems);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> purchaseItem({
    required String userId,
    required String itemType,
    required String itemId,
    String paymentMethod = 'coins',
    int? amount,
    int? duration,
    String? transactionId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.storePurchase,
        data: {
          'userId': userId,
          'itemType': itemType,
          'itemId': itemId,
          'paymentMethod': paymentMethod,
          if (amount != null) 'amount': amount,
          if (duration != null) 'duration': duration,
          if (transactionId != null) 'transactionId': transactionId,
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

final storeApiServiceProvider = Provider<StoreApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return StoreApiService(dio);
});

