import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String type; // 'earned_stake_match', 'purchased', 'spent_store', 'withdrawal', 'commission', 'reward', 'refund'
  final int amount; // Positive for credits, negative for debits
  final String coinType; // 'withdrawable', 'purchased', 'both'
  final int balanceBefore;
  final int balanceAfter;
  final String? description;
  final String? relatedEntityId;
  final String? relatedEntityType; // 'stake_match', 'withdrawal', 'purchase', 'store_item'
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.coinType,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.relatedEntityId,
    this.relatedEntityType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;

  String get typeDisplay {
    switch (type) {
      case 'earned_stake_match':
        return 'Won Stake Match';
      case 'purchased':
        return 'Coin Purchase';
      case 'spent_store':
        return 'Store Purchase';
      case 'withdrawal':
        return 'Withdrawal';
      case 'commission':
        return 'Commission Fee';
      case 'reward':
        return 'Reward';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        coinType,
        balanceBefore,
        balanceAfter,
        description,
        relatedEntityId,
        relatedEntityType,
        createdAt,
      ];
}

