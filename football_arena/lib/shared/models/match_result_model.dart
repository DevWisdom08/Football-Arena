import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'match_result_model.g.dart';

enum MatchType {
  solo,
  challenge1v1,
  teamMatch,
  dailyQuiz,
}

enum MatchStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

@JsonSerializable()
class MatchResultModel extends Equatable {
  final String id;
  final String userId;
  final MatchType matchType;
  final MatchStatus status;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracyRate;
  final int totalScore;
  final int xpGained;
  final int coinsGained;
  final int timeTaken; // in seconds
  final bool isWinner;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata; // For storing additional data

  const MatchResultModel({
    required this.id,
    required this.userId,
    required this.matchType,
    required this.status,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracyRate,
    required this.totalScore,
    required this.xpGained,
    required this.coinsGained,
    required this.timeTaken,
    this.isWinner = false,
    required this.startedAt,
    this.completedAt,
    this.metadata,
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) =>
      _$MatchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchResultModelToJson(this);

  MatchResultModel copyWith({
    String? id,
    String? userId,
    MatchType? matchType,
    MatchStatus? status,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    double? accuracyRate,
    int? totalScore,
    int? xpGained,
    int? coinsGained,
    int? timeTaken,
    bool? isWinner,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MatchResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchType: matchType ?? this.matchType,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      totalScore: totalScore ?? this.totalScore,
      xpGained: xpGained ?? this.xpGained,
      coinsGained: coinsGained ?? this.coinsGained,
      timeTaken: timeTaken ?? this.timeTaken,
      isWinner: isWinner ?? this.isWinner,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        matchType,
        status,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        accuracyRate,
        totalScore,
        xpGained,
        coinsGained,
        timeTaken,
        isWinner,
        startedAt,
        completedAt,
        metadata,
      ];
}

