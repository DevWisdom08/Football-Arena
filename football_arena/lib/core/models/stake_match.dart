class StakeMatch {
  final String id;
  final String creatorId;
  final String? opponentId;
  final int stakeAmount;
  final int totalPot;
  final double commissionRate;
  final int commissionAmount;
  final int winnerPayout;
  final String status;
  final String? winnerId;
  final int creatorScore;
  final int opponentScore;
  final String matchType;
  final int numberOfQuestions;
  final String? difficulty;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  // Related user data (from join)
  final String? creatorUsername;
  final String? creatorAvatar;
  final String? opponentUsername;
  final String? opponentAvatar;

  StakeMatch({
    required this.id,
    required this.creatorId,
    this.opponentId,
    required this.stakeAmount,
    required this.totalPot,
    required this.commissionRate,
    required this.commissionAmount,
    required this.winnerPayout,
    required this.status,
    this.winnerId,
    required this.creatorScore,
    required this.opponentScore,
    required this.matchType,
    required this.numberOfQuestions,
    this.difficulty,
    required this.createdAt,
    this.completedAt,
    this.creatorUsername,
    this.creatorAvatar,
    this.opponentUsername,
    this.opponentAvatar,
  });

  factory StakeMatch.fromJson(Map<String, dynamic> json) {
    return StakeMatch(
      id: json['id'],
      creatorId: json['creatorId'],
      opponentId: json['opponentId'],
      stakeAmount: json['stakeAmount'],
      totalPot: json['totalPot'],
      commissionRate: (json['commissionRate'] as num).toDouble(),
      commissionAmount: json['commissionAmount'],
      winnerPayout: json['winnerPayout'],
      status: json['status'],
      winnerId: json['winnerId'],
      creatorScore: json['creatorScore'] ?? 0,
      opponentScore: json['opponentScore'] ?? 0,
      matchType: json['matchType'],
      numberOfQuestions: json['numberOfQuestions'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      creatorUsername: json['creator']?['username'],
      creatorAvatar: json['creator']?['avatarUrl'],
      opponentUsername: json['opponent']?['username'],
      opponentAvatar: json['opponent']?['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'opponentId': opponentId,
      'stakeAmount': stakeAmount,
      'totalPot': totalPot,
      'commissionRate': commissionRate,
      'commissionAmount': commissionAmount,
      'winnerPayout': winnerPayout,
      'status': status,
      'winnerId': winnerId,
      'creatorScore': creatorScore,
      'opponentScore': opponentScore,
      'matchType': matchType,
      'numberOfQuestions': numberOfQuestions,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class WithdrawalRequest {
  final String id;
  final String userId;
  final int amount;
  final double amountInUSD;
  final double withdrawalFee;
  final double netAmount;
  final String status;
  final String withdrawalMethod;
  final Map<String, dynamic> paymentDetails;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? processedAt;

  WithdrawalRequest({
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
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'],
      amountInUSD: (json['amountInUSD'] as num).toDouble(),
      withdrawalFee: (json['withdrawalFee'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      status: json['status'],
      withdrawalMethod: json['withdrawalMethod'],
      paymentDetails: json['paymentDetails'] ?? {},
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      processedAt: json['processedAt'] != null 
          ? DateTime.parse(json['processedAt']) 
          : null,
    );
  }
}

class TransactionHistory {
  final String id;
  final String userId;
  final String type;
  final int amount;
  final String coinType;
  final String? description;
  final DateTime createdAt;

  TransactionHistory({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.coinType,
    this.description,
    required this.createdAt,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      amount: json['amount'],
      coinType: json['coinType'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

