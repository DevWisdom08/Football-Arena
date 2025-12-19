import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import {
  FraudAlert,
  FraudAlertType,
  FraudAlertSeverity,
  FraudAlertStatus,
} from './entities/fraud-alert.entity';
import { User } from '../users/entities/user.entity';
import { TransactionHistory } from '../users/entities/transaction-history.entity';
import { WithdrawalRequest } from '../users/entities/withdrawal-request.entity';

@Injectable()
export class FraudDetectionService {
  private readonly logger = new Logger(FraudDetectionService.name);

  // Fraud detection thresholds
  private readonly RAPID_BETTING_THRESHOLD = 10; // 10 games in 5 minutes
  private readonly RAPID_BETTING_WINDOW = 5 * 60 * 1000; // 5 minutes
  private readonly LARGE_WITHDRAWAL_THRESHOLD = 50000; // 50,000 coins
  private readonly HIGH_WIN_RATE_THRESHOLD = 0.85; // 85% win rate
  private readonly MIN_GAMES_FOR_WIN_RATE_CHECK = 20;
  private readonly MAX_DAILY_WITHDRAWALS = 5;
  private readonly SUSPICIOUS_WITHDRAWAL_RATIO = 0.9; // Withdraw >90% of balance

  constructor(
    @InjectRepository(FraudAlert)
    private fraudAlertRepository: Repository<FraudAlert>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(TransactionHistory)
    private transactionRepository: Repository<TransactionHistory>,
    @InjectRepository(WithdrawalRequest)
    private withdrawalRepository: Repository<WithdrawalRequest>,
  ) {}

  /**
   * Create a fraud alert
   */
  async createAlert(
    userId: string,
    type: FraudAlertType,
    severity: FraudAlertSeverity,
    description: string,
    metadata?: any,
  ): Promise<FraudAlert> {
    const alert = this.fraudAlertRepository.create({
      userId,
      type,
      severity,
      description,
      metadata,
      status: FraudAlertStatus.PENDING,
    });

    const savedAlert = await this.fraudAlertRepository.save(alert);

    this.logger.warn(
      `🚨 Fraud Alert Created: ${type} - User: ${userId} - Severity: ${severity}`,
    );

    return savedAlert;
  }

  /**
   * Check for rapid betting patterns
   */
  async checkRapidBetting(userId: string): Promise<void> {
    const recentTime = new Date(Date.now() - this.RAPID_BETTING_WINDOW);

    const recentGames = await this.transactionRepository.count({
      where: {
        userId,
        type: 'stake_match_entry',
        createdAt: MoreThan(recentTime),
      },
    });

    if (recentGames >= this.RAPID_BETTING_THRESHOLD) {
      await this.createAlert(
        userId,
        FraudAlertType.RAPID_BETTING,
        FraudAlertSeverity.MEDIUM,
        `User played ${recentGames} games in 5 minutes`,
        { gameCount: recentGames, windowMinutes: 5 },
      );
    }
  }

  /**
   * Check withdrawal for suspicious patterns
   */
  async checkWithdrawal(
    userId: string,
    amount: number,
  ): Promise<{ allowed: boolean; reason?: string }> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      return { allowed: false, reason: 'User not found' };
    }

    // Check for large withdrawal
    if (amount >= this.LARGE_WITHDRAWAL_THRESHOLD) {
      await this.createAlert(
        userId,
        FraudAlertType.LARGE_TRANSACTION,
        FraudAlertSeverity.HIGH,
        `Large withdrawal attempt: ${amount} coins`,
        { amount, userBalance: user.withdrawableCoins },
      );
    }

    // Check withdrawal ratio (attempting to withdraw most of balance)
    const totalBalance =
      user.coins + user.purchasedCoins + user.withdrawableCoins;
    const withdrawalRatio = amount / totalBalance;

    if (
      withdrawalRatio >= this.SUSPICIOUS_WITHDRAWAL_RATIO &&
      totalBalance > 10000
    ) {
      await this.createAlert(
        userId,
        FraudAlertType.SUSPICIOUS_WITHDRAWAL,
        FraudAlertSeverity.MEDIUM,
        `Attempting to withdraw ${(withdrawalRatio * 100).toFixed(1)}% of total balance`,
        { amount, totalBalance, ratio: withdrawalRatio },
      );
    }

    // Check daily withdrawal limit
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayWithdrawals = await this.withdrawalRepository.count({
      where: {
        userId,
        createdAt: MoreThan(today),
      },
    });

    if (todayWithdrawals >= this.MAX_DAILY_WITHDRAWALS) {
      await this.createAlert(
        userId,
        FraudAlertType.UNUSUAL_ACTIVITY,
        FraudAlertSeverity.HIGH,
        `Exceeded daily withdrawal limit: ${todayWithdrawals + 1} attempts`,
        { todayWithdrawals, limit: this.MAX_DAILY_WITHDRAWALS },
      );

      return {
        allowed: false,
        reason: `Daily withdrawal limit reached (${this.MAX_DAILY_WITHDRAWALS} per day)`,
      };
    }

    return { allowed: true };
  }

  /**
   * Check for abnormal win rate
   */
  async checkWinRate(userId: string): Promise<void> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) return;

    const totalGames = user.gamesPlayed || 0;
    const wins = user.gamesWon || 0;

    if (totalGames < this.MIN_GAMES_FOR_WIN_RATE_CHECK) {
      return; // Not enough data
    }

    const winRate = wins / totalGames;

    if (winRate >= this.HIGH_WIN_RATE_THRESHOLD) {
      await this.createAlert(
        userId,
        FraudAlertType.WIN_RATE_ANOMALY,
        FraudAlertSeverity.HIGH,
        `Abnormally high win rate: ${(winRate * 100).toFixed(1)}%`,
        { totalGames, wins, winRate },
      );
    }
  }

  /**
   * Check for multiple accounts from same device/IP
   * Note: This requires IP tracking to be implemented
   */
  async checkMultipleAccounts(
    userId: string,
    ipAddress?: string,
  ): Promise<void> {
    if (!ipAddress) return;

    // This is a placeholder - would need to track user IPs in the database
    // For now, log a warning if IP tracking is needed
    this.logger.debug(
      `IP tracking for multiple account detection not yet implemented for user ${userId}`,
    );
  }

  /**
   * Get all fraud alerts
   */
  async getAllAlerts(
    status?: FraudAlertStatus,
    severity?: FraudAlertSeverity,
  ): Promise<FraudAlert[]> {
    const where: any = {};
    if (status) where.status = status;
    if (severity) where.severity = severity;

    return await this.fraudAlertRepository.find({
      where,
      relations: ['user'],
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  /**
   * Get user's fraud alerts
   */
  async getUserAlerts(userId: string): Promise<FraudAlert[]> {
    return await this.fraudAlertRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Update alert status
   */
  async updateAlert(
    alertId: string,
    status: FraudAlertStatus,
    reviewedBy: string,
    reviewNotes?: string,
  ): Promise<FraudAlert> {
    const alert = await this.fraudAlertRepository.findOne({
      where: { id: alertId },
    });

    if (!alert) {
      throw new Error('Alert not found');
    }

    alert.status = status;
    alert.reviewedBy = reviewedBy;
    alert.reviewedAt = new Date();
    if (reviewNotes) alert.reviewNotes = reviewNotes;

    return await this.fraudAlertRepository.save(alert);
  }

  /**
   * Check if user is flagged for fraud
   */
  async isUserFlagged(userId: string): Promise<boolean> {
    const criticalAlerts = await this.fraudAlertRepository.count({
      where: {
        userId,
        severity: FraudAlertSeverity.CRITICAL,
        status: FraudAlertStatus.PENDING,
      },
    });

    return criticalAlerts > 0;
  }

  /**
   * Get fraud statistics
   */
  async getFraudStats(): Promise<any> {
    const totalAlerts = await this.fraudAlertRepository.count();
    const pendingAlerts = await this.fraudAlertRepository.count({
      where: { status: FraudAlertStatus.PENDING },
    });
    const criticalAlerts = await this.fraudAlertRepository.count({
      where: { severity: FraudAlertSeverity.CRITICAL },
    });

    const alertsByType = await this.fraudAlertRepository
      .createQueryBuilder('alert')
      .select('alert.type', 'type')
      .addSelect('COUNT(*)', 'count')
      .groupBy('alert.type')
      .getRawMany();

    return {
      totalAlerts,
      pendingAlerts,
      criticalAlerts,
      alertsByType,
    };
  }

  /**
   * Run comprehensive fraud check on user
   */
  async runFraudCheck(userId: string, ipAddress?: string): Promise<void> {
    await Promise.all([
      this.checkRapidBetting(userId),
      this.checkWinRate(userId),
      this.checkMultipleAccounts(userId, ipAddress),
    ]);
  }
}

