import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, MoreThan } from 'typeorm';
import { DailyQuizAttempt } from './entities/daily-quiz.entity';
import { MatchHistory, GameMode, MatchResult } from './entities/match-history.entity';
import { SpecialEvent } from './entities/special-event.entity';
import { Tournament } from './entities/tournament.entity';
import { QuestionsService } from '../questions/questions.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class GameService {
  constructor(
    @InjectRepository(DailyQuizAttempt)
    private dailyQuizRepository: Repository<DailyQuizAttempt>,
    @InjectRepository(MatchHistory)
    private matchHistoryRepository: Repository<MatchHistory>,
    @InjectRepository(SpecialEvent)
    private specialEventRepository: Repository<SpecialEvent>,
    @InjectRepository(Tournament)
    private tournamentRepository: Repository<Tournament>,
    private questionsService: QuestionsService,
    private usersService: UsersService,
  ) {}

  async getDailyQuiz(userId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if user already completed today's quiz
    const existingAttempt = await this.dailyQuizRepository.findOne({
      where: {
        userId,
        quizDate: today,
      },
    });

    if (existingAttempt) {
      return {
        available: false,
        message: 'You have already completed today\'s quiz!',
        attempt: existingAttempt,
        nextAvailable: this.getNextQuizTime(),
      };
    }

    // Get 15 questions for daily quiz (more than solo mode)
    const questions = await this.questionsService.getRandom(15);

    return {
      available: true,
      questions,
      message: 'Daily quiz is ready!',
      rewards: {
        baseXP: 100,
        bonusXP: 50,
        baseCoins: 50,
        bonusCoins: 25,
        totalXP: 150,
        totalCoins: 75,
      },
    };
  }

  async submitDailyQuiz(
    userId: string,
    answers: { questionId: string; answer: string; correct: boolean }[],
  ) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if already submitted today
    const existingAttempt = await this.dailyQuizRepository.findOne({
      where: {
        userId,
        quizDate: today,
      },
    });

    if (existingAttempt) {
      throw new BadRequestException('Daily quiz already completed today');
    }

    const correctAnswers = answers.filter(a => a.correct).length;
    const totalQuestions = answers.length;
    const accuracy = (correctAnswers / totalQuestions) * 100;

    // Calculate rewards (higher than solo mode)
    const baseXP = 100;
    const bonusXP = correctAnswers * 10; // 10 XP per correct answer
    const baseCoins = 50;
    const bonusCoins = Math.floor(correctAnswers / 3) * 10; // 10 coins per 3 correct

    const totalXP = baseXP + bonusXP;
    const totalCoins = baseCoins + bonusCoins;

    // Get user to check current streak
    const user = await this.usersService.findOne(userId);
    const currentStreak = user?.currentStreak || 0;
    
    // Determine if streak would be broken (accuracy < 50%)
    const wouldBreakStreak = accuracy < 50;
    
    // Calculate what the streak was before today (for protection)
    const previousStreak = wouldBreakStreak ? this.getPreviousStreak(user) : currentStreak;

    // Save attempt with previous streak info (for protection)
    const attempt = this.dailyQuizRepository.create({
      userId,
      quizDate: today,
      score: correctAnswers * 100,
      correctAnswers,
      totalQuestions,
      accuracy,
      xpGained: totalXP,
      coinsGained: totalCoins,
      bonusRewardClaimed: true,
      answers,
    });

    await this.dailyQuizRepository.save(attempt);

    // Update user stats
    // Note: If streak would be broken, we'll reset it now, but user can protect it later
    if (user) {
      let newStreak: number;
      
      if (wouldBreakStreak) {
        // Streak broken - reset to 1 (user can protect later to restore previousStreak)
        newStreak = 1;
      } else {
        // Streak continues - increment
        const calculatedStreak = this.calculateStreak(user.lastPlayedAt);
        newStreak = calculatedStreak === 1 ? currentStreak + 1 : calculatedStreak;
      }
      
      await this.usersService.update(userId, {
        totalGames: user.totalGames + 1,
        xp: user.xp + totalXP,
        coins: user.coins + totalCoins,
        currentStreak: newStreak,
        longestStreak: Math.max(user.longestStreak, newStreak),
        lastPlayedAt: new Date(),
      });
    }

    // Fetch updated user data to return
    const updatedUser = await this.usersService.findOne(userId);

    return {
      success: true,
      result: attempt,
      rewards: {
        totalXP,
        totalCoins,
        streak: user ? (wouldBreakStreak ? 1 : (currentStreak + 1)) : 1,
      },
      wouldBreakStreak,
      currentStreak: previousStreak, // Return previous streak for protection
      nextAvailable: this.getNextQuizTime(),
      user: updatedUser, // Return updated user data
    };
  }
  
  private getPreviousStreak(user: any): number {
    if (!user || !user.lastPlayedAt) return 1;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const lastPlayed = new Date(user.lastPlayedAt);
    lastPlayed.setHours(0, 0, 0, 0);
    
    const diffTime = today.getTime() - lastPlayed.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    // If last played was yesterday, the streak before today would be currentStreak
    // (because currentStreak hasn't been incremented yet for today)
    if (diffDays === 0 || diffDays === 1) {
      return user.currentStreak || 1;
    }
    
    // If more than 1 day, streak was already broken
    return 1;
  }

  async protectStreak(
    userId: string,
    method: 'coins' | 'vip',
  ) {
    const user = await this.usersService.findOne(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if user completed today's quiz
    const todayAttempt = await this.dailyQuizRepository.findOne({
      where: {
        userId,
        quizDate: today,
      },
    });

    if (!todayAttempt) {
      throw new BadRequestException('No daily quiz attempt found for today');
    }

    // Check if streak was already broken (accuracy < 50%)
    const accuracy = todayAttempt.accuracy;
    if (accuracy >= 50) {
      throw new BadRequestException('Streak was not broken. No protection needed.');
    }

    // Check if streak is already at 1 (already broken)
    // We need to restore it to the previous streak value
    // Get the streak before today's attempt by checking lastPlayedAt
    const previousStreak = this.calculateStreakBeforeToday(user.lastPlayedAt, user.currentStreak);

    // Check protection method
    if (method === 'coins') {
      const protectionCost = 100; // 100 coins to protect streak
      if (user.coins < protectionCost) {
        throw new BadRequestException('Insufficient coins. Need 100 coins to protect streak.');
      }

      // Deduct coins
      await this.usersService.update(userId, {
        coins: user.coins - protectionCost,
      });
    } else if (method === 'vip') {
      // Check if user is VIP
      if (!user.isVip || (user.vipExpiryDate && new Date(user.vipExpiryDate) < new Date())) {
        throw new BadRequestException('VIP membership required to protect streak for free.');
      }
    } else {
      throw new BadRequestException('Invalid protection method');
    }

    // Restore streak to previous value (before today's failed attempt)
    // The previousStreak is what the streak was before today's attempt
    const restoredStreak = previousStreak > 0 ? previousStreak : 1;
    
    await this.usersService.update(userId, {
      currentStreak: restoredStreak,
      longestStreak: Math.max(user.longestStreak, restoredStreak),
    });

    return {
      success: true,
      message: `Streak protected using ${method === 'coins' ? 'coins' : 'VIP'}`,
      streak: restoredStreak,
      coinsSpent: method === 'coins' ? 100 : 0,
    };
  }

  private calculateStreakBeforeToday(lastPlayedAt: Date | null, currentStreak: number): number {
    if (!lastPlayedAt) return currentStreak;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const lastPlayed = new Date(lastPlayedAt);
    lastPlayed.setHours(0, 0, 0, 0);
    
    const diffTime = today.getTime() - lastPlayed.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    // If last played was yesterday, the streak before today would be currentStreak - 1
    // If last played was today (shouldn't happen), return currentStreak
    if (diffDays === 0) return currentStreak;
    if (diffDays === 1) return Math.max(1, currentStreak - 1);
    
    // If more than 1 day, streak was already broken
    return 1;
  }

  async getDailyQuizHistory(userId: string, limit: number = 30) {
    return await this.dailyQuizRepository.find({
      where: { userId },
      order: { quizDate: 'DESC' },
      take: limit,
    });
  }

  async getDailyQuizStats(userId: string) {
    const attempts = await this.dailyQuizRepository.find({
      where: { userId },
      order: { quizDate: 'DESC' },
    });

    if (attempts.length === 0) {
      return {
        totalAttempts: 0,
        averageAccuracy: 0,
        totalXP: 0,
        totalCoins: 0,
        bestScore: 0,
      };
    }

    const totalXP = attempts.reduce((sum, a) => sum + a.xpGained, 0);
    const totalCoins = attempts.reduce((sum, a) => sum + a.coinsGained, 0);
    const averageAccuracy = attempts.reduce((sum, a) => sum + a.accuracy, 0) / attempts.length;
    const bestScore = Math.max(...attempts.map(a => a.score));

    return {
      totalAttempts: attempts.length,
      averageAccuracy: Number(averageAccuracy.toFixed(2)),
      totalXP,
      totalCoins,
      bestScore,
      recentAttempts: attempts.slice(0, 7),
    };
  }

  private calculateStreak(lastPlayedAt: Date | null): number {
    if (!lastPlayedAt) return 1;

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const lastPlayed = new Date(lastPlayedAt);
    lastPlayed.setHours(0, 0, 0, 0);

    const diffTime = today.getTime() - lastPlayed.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    // Streak continues if played yesterday or today
    if (diffDays === 0) return 1; // Already played today
    if (diffDays === 1) return 1; // Increment happens in calling code
    
    // Streak broken
    return 1;
  }

  private getNextQuizTime(): Date {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    return tomorrow;
  }

  // ==================== SOLO MODE ====================

  async saveSoloModeResult(data: {
    userId: string;
    correctAnswers: number;
    totalQuestions: number;
    accuracy: number;
    xpGained: number;
    coinsGained: number;
    score: number;
    duration?: number;
  }) {
    try {
      // Get user first
      const user = await this.usersService.findOne(data.userId);
      
      // Calculate new stats
      const totalGames = (user.totalGames || 0) + 1;
      const soloGamesPlayed = (user.soloGamesPlayed || 0) + 1;
      
      // Simplified accuracy rate calculation
      const oldTotalCorrect = user.totalGames > 0 
        ? ((user.accuracyRate || 0) / 100) * user.totalGames 
        : 0;
      const newTotalCorrect = oldTotalCorrect + data.correctAnswers;
      const newTotalQuestions = user.totalGames > 0
        ? (user.totalGames * 10) + data.totalQuestions
        : data.totalQuestions;
      const newAccuracyRate = newTotalQuestions > 0
        ? (newTotalCorrect / newTotalQuestions) * 100
        : data.accuracy;

      // Add XP and coins
      const newXp = (user.xp || 0) + data.xpGained;
      const newCoins = (user.coins || 0) + data.coinsGained;

    // Check for level up
    const oldLevel = user.level || 1;
    const newLevel = Math.floor(newXp / 1000) + 1;
    const leveledUp = newLevel > oldLevel;

    // Award achievements
    const badges = await this.awardAchievements(user, {
      correctAnswers: data.correctAnswers,
      totalQuestions: data.totalQuestions,
      accuracy: data.accuracy,
      gameMode: 'solo',
    });

    // Update user in database (single query)
    await this.usersService.update(data.userId, {
      totalGames,
      soloGamesPlayed,
      accuracyRate: newAccuracyRate,
      xp: newXp,
      coins: newCoins,
      level: newLevel,
      badges: badges,
      lastPlayedAt: new Date(),
    });

      // Save match history after user update (non-blocking)
      this.saveMatchHistory({
        userId: data.userId,
        gameMode: GameMode.SOLO,
        score: data.score,
        correctAnswers: data.correctAnswers,
        totalQuestions: data.totalQuestions,
        accuracy: data.accuracy,
        xpGained: data.xpGained,
        coinsGained: data.coinsGained,
        duration: data.duration,
      }).catch(err => console.error('Failed to save match history:', err));

      // Get fresh user data
      const updatedUser = await this.usersService.findOne(data.userId);

      return {
        success: true,
        user: updatedUser,
        leveledUp,
        oldLevel,
        newLevel,
        message: 'Solo mode results saved successfully',
        newBadges: badges.filter(b => !user.badges.includes(b)),
      };
    } catch (error) {
      console.error('Error saving solo mode result:', error);
      throw error;
    }
  }

  // ==================== ACHIEVEMENTS ====================

  private async awardAchievements(
    user: any,
    gameData: {
      correctAnswers: number;
      totalQuestions: number;
      accuracy: number;
      gameMode: string;
    },
  ): Promise<string[]> {
    const currentBadges = new Set<string>(user.badges || []);
    const newlyEarned: string[] = [];

    // First Win (any game mode)
    if (!currentBadges.has('first_win') && user.totalGames === 0) {
      currentBadges.add('first_win');
      newlyEarned.push('first_win');
    }

    // Perfect Score (100% accuracy)
    if (!currentBadges.has('perfect_score') && gameData.accuracy === 100) {
      currentBadges.add('perfect_score');
      newlyEarned.push('perfect_score');
    }

    // 7 Day Streak
    if (!currentBadges.has('7_day_streak') && user.currentStreak >= 7) {
      currentBadges.add('7_day_streak');
      newlyEarned.push('7_day_streak');
    }

    // 100 Games Milestone
    if (!currentBadges.has('100_games') && user.totalGames + 1 >= 100) {
      currentBadges.add('100_games');
      newlyEarned.push('100_games');
    }

    // Log newly earned achievements
    if (newlyEarned.length > 0) {
      console.log(`🏆 New achievements earned: ${newlyEarned.join(', ')}`);
    }

    return Array.from(currentBadges);
  }

  // ==================== MATCH HISTORY ====================

  async saveMatchHistory(data: {
    userId: string;
    gameMode: GameMode;
    result?: MatchResult;
    score: number;
    correctAnswers: number;
    totalQuestions: number;
    accuracy: number;
    xpGained: number;
    coinsGained: number;
    opponentId?: string;
    opponentUsername?: string;
    roomId?: string;
    teamData?: any;
    duration?: number;
  }) {
    const match = this.matchHistoryRepository.create(data);
    return await this.matchHistoryRepository.save(match);
  }

  async getMatchHistory(userId: string, limit: number = 50) {
    return await this.matchHistoryRepository.find({
      where: { userId },
      order: { playedAt: 'DESC' },
      take: limit,
    });
  }

  async getMatchHistoryByMode(userId: string, gameMode: GameMode, limit: number = 20) {
    return await this.matchHistoryRepository.find({
      where: { userId, gameMode },
      order: { playedAt: 'DESC' },
      take: limit,
    });
  }

  async getMatchStats(userId: string) {
    const matches = await this.matchHistoryRepository.find({
      where: { userId },
    });

    if (matches.length === 0) {
      return {
        totalMatches: 0,
        wins: 0,
        losses: 0,
        draws: 0,
        averageAccuracy: 0,
        totalXP: 0,
        totalCoins: 0,
        favoriteMode: null,
      };
    }

    const wins = matches.filter(m => m.result === MatchResult.WIN).length;
    const losses = matches.filter(m => m.result === MatchResult.LOSE).length;
    const draws = matches.filter(m => m.result === MatchResult.DRAW).length;
    const totalXP = matches.reduce((sum, m) => sum + m.xpGained, 0);
    const totalCoins = matches.reduce((sum, m) => sum + m.coinsGained, 0);
    const avgAccuracy = matches.reduce((sum, m) => sum + m.accuracy, 0) / matches.length;

    // Find favorite game mode
    const modeCounts = matches.reduce((acc, m) => {
      acc[m.gameMode] = (acc[m.gameMode] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const favoriteMode = Object.entries(modeCounts).sort(([,a], [,b]) => b - a)[0][0];

    return {
      totalMatches: matches.length,
      wins,
      losses,
      draws,
      winRate: matches.length > 0 ? ((wins / matches.length) * 100).toFixed(2) : 0,
      averageAccuracy: avgAccuracy.toFixed(2),
      totalXP,
      totalCoins,
      favoriteMode,
      byMode: {
        solo: matches.filter(m => m.gameMode === GameMode.SOLO).length,
        challenge1v1: matches.filter(m => m.gameMode === GameMode.CHALLENGE_1V1).length,
        teamMatch: matches.filter(m => m.gameMode === GameMode.TEAM_MATCH).length,
        dailyQuiz: matches.filter(m => m.gameMode === GameMode.DAILY_QUIZ).length,
      },
    };
  }

  // ==================== SPECIAL EVENTS ====================

  async getActiveEvents() {
    const now = new Date();
    const events = await this.specialEventRepository.find({
      where: {
        isActive: true,
        startDate: LessThan(now),
        endDate: MoreThan(now),
      },
      order: {
        startDate: 'ASC',
      },
    });

    return events;
  }

  async getAllEvents() {
    return this.specialEventRepository.find({
      order: {
        startDate: 'DESC',
      },
    });
  }

  async createEvent(eventData: Partial<SpecialEvent>) {
    const event = this.specialEventRepository.create(eventData);
    return this.specialEventRepository.save(event);
  }

  async getEventById(eventId: string) {
    return this.specialEventRepository.findOne({
      where: { id: eventId },
    });
  }

  async getActiveMultipliers() {
    const events = await this.getActiveEvents();
    const multipliers = {
      xp: 1.0,
      coins: 1.0,
    };

    for (const event of events) {
      if (event.xpMultiplier > 1) {
        multipliers.xp *= event.xpMultiplier;
      }
      if (event.coinsMultiplier > 1) {
        multipliers.coins *= event.coinsMultiplier;
      }
    }

    return multipliers;
  }

  // ==================== TOURNAMENTS ====================

  async getAvailableTournaments() {
    const now = new Date();
    return this.tournamentRepository.find({
      where: {
        isActive: true,
        startDate: LessThan(now),
        endDate: MoreThan(now),
      },
      order: {
        startDate: 'ASC',
      },
    });
  }

  async getAllTournaments() {
    return this.tournamentRepository.find({
      order: {
        startDate: 'DESC',
      },
    });
  }

  async createTournament(tournamentData: Partial<Tournament>) {
    const tournament = this.tournamentRepository.create(tournamentData);
    return this.tournamentRepository.save(tournament);
  }

  async getTournamentById(tournamentId: string) {
    return this.tournamentRepository.findOne({
      where: { id: tournamentId },
    });
  }

  async enterTournament(userId: string, tournamentId: string) {
    const tournament = await this.getTournamentById(tournamentId);
    if (!tournament) {
      throw new BadRequestException('Tournament not found');
    }

    if (tournament.currentParticipants >= tournament.maxParticipants) {
      throw new BadRequestException('Tournament is full');
    }

    if (tournament.participantIds.includes(userId)) {
      throw new BadRequestException('You are already registered for this tournament');
    }

    // Get user and check if they have enough coins
    const user = await this.usersService.findOne(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    if (user.coins < tournament.entryFee) {
      throw new BadRequestException('Insufficient coins');
    }

    // Deduct entry fee
    await this.usersService.update(userId, {
      coins: user.coins - tournament.entryFee,
    });

    // Add user to tournament
    tournament.participantIds.push(userId);
    tournament.currentParticipants += 1;
    await this.tournamentRepository.save(tournament);

    return {
      success: true,
      tournament,
      message: `Successfully entered ${tournament.name}`,
    };
  }
}
