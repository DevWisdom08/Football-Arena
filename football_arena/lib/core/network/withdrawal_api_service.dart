import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../shared/models/withdrawal_model.dart';
import '../../shared/models/transaction_model.dart';

part 'withdrawal_api_service.g.dart';

@RestApi()
abstract class WithdrawalApiService {
  factory WithdrawalApiService(Dio dio, {String baseUrl}) = _WithdrawalApiService;

  /// Submit KYC verification
  @POST('/withdrawals/kyc')
  Future<Map<String, dynamic>> submitKyc(
    @Body() Map<String, dynamic> kycData,
  );

  /// Create a withdrawal request
  @POST('/withdrawals')
  Future<WithdrawalModel> createWithdrawal(
    @Body() Map<String, dynamic> data,
  );

  /// Get user's withdrawal history
  @GET('/withdrawals/my-withdrawals/{userId}')
  Future<List<WithdrawalModel>> getUserWithdrawals(
    @Path('userId') String userId,
  );

  /// Get user's transaction history
  @GET('/withdrawals/transactions/{userId}')
  Future<List<TransactionModel>> getUserTransactions(
    @Path('userId') String userId,
  );

  /// Cancel a withdrawal
  @DELETE('/withdrawals/{id}')
  Future<WithdrawalModel> cancelWithdrawal(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  /// Get pending withdrawals (admin only)
  @GET('/withdrawals/pending')
  Future<List<WithdrawalModel>> getPendingWithdrawals();

  /// Get all withdrawals (admin only)
  @GET('/withdrawals/all')
  Future<List<WithdrawalModel>> getAllWithdrawals(
    @Query('limit') int? limit,
  );
}

