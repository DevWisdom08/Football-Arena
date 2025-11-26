import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'withdrawal_model.g.dart';

@JsonSerializable()
class WithdrawalModel extends Equatable {
  final String id;
  final String userId;
  final int amount; // Amount in withdrawable coins
  final double amountInUSD; // Amount in USD (1000 coins = $1)
  final double withdrawalFee; // Fee charged
  final double netAmount; // Amount user receives after fee
  final String status; // pending, approved, processing, completed, rejected, cancelled
  final String withdrawalMethod; // paypal, bank_transfer, mobile_money, crypto
  final Map<String, dynamic> paymentDetails; // Payment details
  final String? rejectionReason;
  final String? processedBy;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? transactionId;
  final DateTime createdAt;

  const WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.amountInUSD,
    required this.withdrawalFee,
    required this.netAmount,
    required this.status,
    required this.withdrawalMethod,
    required this.paymentDetails,
    this.rejectionReason,
    this.processedBy,
    this.processedAt,
    this.completedAt,
    this.transactionId,
    required this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalModelFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalModelToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'processing':
        return 'Processing Payment';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        amountInUSD,
        withdrawalFee,
        netAmount,
        status,
        withdrawalMethod,
        paymentDetails,
        rejectionReason,
        processedBy,
        processedAt,
        completedAt,
        transactionId,
        createdAt,
      ];
}

