import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/withdrawal_api_service.dart';
import '../network/api_client.dart';
import '../../shared/models/withdrawal_model.dart';
import '../../shared/models/transaction_model.dart';

// Provider for WithdrawalApiService
final withdrawalApiProvider = Provider<WithdrawalApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return WithdrawalApiService(dio);
});

// Provider for user's withdrawal history
final userWithdrawalsProvider = FutureProvider.family<List<WithdrawalModel>, String>(
  (ref, userId) async {
    final api = ref.watch(withdrawalApiProvider);
    return await api.getUserWithdrawals(userId);
  },
);

// Provider for user's transaction history
final userTransactionsProvider = FutureProvider.family<List<TransactionModel>, String>(
  (ref, userId) async {
    final api = ref.watch(withdrawalApiProvider);
    return await api.getUserTransactions(userId);
  },
);

// Provider for withdrawal operations
class WithdrawalNotifier extends StateNotifier<AsyncValue<WithdrawalModel?>> {
  WithdrawalNotifier(this.api) : super(const AsyncValue.data(null));
  
  final WithdrawalApiService api;

  Future<void> createWithdrawal({
    required String userId,
    required int amount,
    required String withdrawalMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    state = const AsyncValue.loading();
    try {
      final withdrawal = await api.createWithdrawal({
        'userId': userId,
        'amount': amount,
        'withdrawalMethod': withdrawalMethod,
        'paymentDetails': paymentDetails,
      });
      state = AsyncValue.data(withdrawal);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitKyc({
    required String userId,
    required String fullName,
    required String dateOfBirth,
    required String idNumber,
    required String idPhotoUrl,
    required String selfieUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await api.submitKyc({
        'userId': userId,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'idNumber': idNumber,
        'idPhotoUrl': idPhotoUrl,
        'selfieUrl': selfieUrl,
      });
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelWithdrawal({
    required String withdrawalId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final withdrawal = await api.cancelWithdrawal(withdrawalId, {'userId': userId});
      state = AsyncValue.data(withdrawal);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final withdrawalNotifierProvider = StateNotifierProvider<WithdrawalNotifier, AsyncValue<WithdrawalModel?>>(
  (ref) => WithdrawalNotifier(ref.watch(withdrawalApiProvider)),
);

