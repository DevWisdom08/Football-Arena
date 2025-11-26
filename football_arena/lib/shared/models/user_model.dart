import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String country;
  final int level;
  final int xp;
  final int coins;
  final int withdrawableCoins;
  final int purchasedCoins;
  final int totalGames;
  final int soloGamesPlayed;
  final int challenge1v1Played;
  final int teamMatchesPlayed;
  final double accuracyRate;
  final double winRate;
  final int currentStreak;
  final int longestStreak;
  final bool isVip;
  final DateTime? vipExpiryDate;
  final double commissionRate;
  final bool kycVerified;
  final String? kycStatus;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final List<String> badges;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.country,
    required this.level,
    required this.xp,
    required this.coins,
    this.withdrawableCoins = 0,
    this.purchasedCoins = 0,
    this.totalGames = 0,
    this.soloGamesPlayed = 0,
    this.challenge1v1Played = 0,
    this.teamMatchesPlayed = 0,
    this.accuracyRate = 0.0,
    this.winRate = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isVip = false,
    this.vipExpiryDate,
    this.commissionRate = 10.0,
    this.kycVerified = false,
    this.kycStatus,
    required this.createdAt,
    required this.lastPlayedAt,
    this.badges = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? country,
    int? level,
    int? xp,
    int? coins,
    int? withdrawableCoins,
    int? purchasedCoins,
    int? totalGames,
    int? soloGamesPlayed,
    int? challenge1v1Played,
    int? teamMatchesPlayed,
    double? accuracyRate,
    double? winRate,
    int? currentStreak,
    int? longestStreak,
    bool? isVip,
    DateTime? vipExpiryDate,
    double? commissionRate,
    bool? kycVerified,
    String? kycStatus,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    List<String>? badges,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      withdrawableCoins: withdrawableCoins ?? this.withdrawableCoins,
      purchasedCoins: purchasedCoins ?? this.purchasedCoins,
      totalGames: totalGames ?? this.totalGames,
      soloGamesPlayed: soloGamesPlayed ?? this.soloGamesPlayed,
      challenge1v1Played: challenge1v1Played ?? this.challenge1v1Played,
      teamMatchesPlayed: teamMatchesPlayed ?? this.teamMatchesPlayed,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      winRate: winRate ?? this.winRate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isVip: isVip ?? this.isVip,
      vipExpiryDate: vipExpiryDate ?? this.vipExpiryDate,
      commissionRate: commissionRate ?? this.commissionRate,
      kycVerified: kycVerified ?? this.kycVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      badges: badges ?? this.badges,
    );
  }

  int get xpToNextLevel {
    // Simple formula: each level requires 1000 XP
    return ((level + 1) * 1000);
  }

  double get xpProgress {
    final currentLevelXp = level * 1000;
    final xpInCurrentLevel = xp - currentLevelXp;
    final xpNeededForLevel = 1000;
    return xpInCurrentLevel / xpNeededForLevel;
  }

  int get totalCoins => coins + withdrawableCoins + purchasedCoins;

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        avatarUrl,
        country,
        level,
        xp,
        coins,
        withdrawableCoins,
        purchasedCoins,
        totalGames,
        soloGamesPlayed,
        challenge1v1Played,
        teamMatchesPlayed,
        accuracyRate,
        winRate,
        currentStreak,
        longestStreak,
        isVip,
        vipExpiryDate,
        commissionRate,
        kycVerified,
        kycStatus,
        createdAt,
        lastPlayedAt,
        badges,
      ];
}

