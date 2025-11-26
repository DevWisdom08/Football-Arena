import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'stake_match_model.g.dart';

@JsonSerializable()
class StakeMatchModel extends Equatable {
  final String id;
  final String creatorId;
  final String? opponentId;
  final int stakeAmount;
  final int totalPot;
  final double commissionRate;
  final int commissionAmount;
  final int winnerPayout;
  final String status; // waiting, active, completed, cancelled
  final String? winnerId;
  final int creatorScore;
  final int opponentScore;
  final String matchType;
  final int numberOfQuestions;
  final String? difficulty;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Optional user details (populated when fetched with relations)
  final Map<String, dynamic>? creator;
  final Map<String, dynamic>? opponent;
  final Map<String, dynamic>? winner;

  const StakeMatchModel({
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
    this.creatorScore = 0,
    this.opponentScore = 0,
    this.matchType = 'football_quiz',
    this.numberOfQuestions = 10,
    this.difficulty,
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.creator,
    this.opponent,
    this.winner,
  });

  factory StakeMatchModel.fromJson(Map<String, dynamic> json) =>
      _$StakeMatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$StakeMatchModelToJson(this);

  bool get isWaiting => status == 'waiting';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String getOpponentName(String currentUserId) {
    if (creator != null && creator!['id'] == currentUserId) {
      return opponent?['username'] ?? 'Unknown';
    }
    return creator?['username'] ?? 'Unknown';
  }

  bool isUserCreator(String userId) => creatorId == userId;
  bool isUserOpponent(String userId) => opponentId == userId;
  bool isUserWinner(String userId) => winnerId == userId;

  @override
  List<Object?> get props => [
    id,
    creatorId,
    opponentId,
    stakeAmount,
    totalPot,
    commissionRate,
    commissionAmount,
    winnerPayout,
    status,
    winnerId,
    creatorScore,
    opponentScore,
    matchType,
    numberOfQuestions,
    difficulty,
    createdAt,
    completedAt,
    cancelledAt,
    cancellationReason,
  ];
}
