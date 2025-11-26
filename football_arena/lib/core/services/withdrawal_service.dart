import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stake_match.dart';
import '../config/api_config.dart';

class WithdrawalService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Submit KYC verification
  Future<Map<String, dynamic>> submitKyc({
    required String userId,
    required String fullName,
    required String dateOfBirth,
    required String idNumber,
    required String idPhotoUrl,
    required String selfieUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/withdrawals/kyc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'idNumber': idNumber,
          'idPhotoUrl': idPhotoUrl,
          'selfieUrl': selfieUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit KYC: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting KYC: $e');
    }
  }

  // Create withdrawal request
  Future<WithdrawalRequest> createWithdrawal({
    required String userId,
    required int amount,
    required String withdrawalMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/withdrawals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'withdrawalMethod': withdrawalMethod,
          'paymentDetails': paymentDetails,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return WithdrawalRequest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create withdrawal: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating withdrawal: $e');
    }
  }

  // Get user's withdrawal history
  Future<List<WithdrawalRequest>> getUserWithdrawals(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/withdrawals/my-withdrawals/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WithdrawalRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load withdrawals');
      }
    } catch (e) {
      throw Exception('Error loading withdrawals: $e');
    }
  }

  // Get user's transaction history
  Future<List<TransactionHistory>> getUserTransactions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/withdrawals/transactions/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionHistory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error loading transactions: $e');
    }
  }

  // Cancel withdrawal
  Future<void> cancelWithdrawal({
    required String userId,
    required String withdrawalId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/withdrawals/$withdrawalId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel withdrawal');
      }
    } catch (e) {
      throw Exception('Error cancelling withdrawal: $e');
    }
  }
}

