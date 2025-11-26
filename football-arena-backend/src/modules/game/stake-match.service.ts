import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { StakeMatch } from './entities/stake-match.entity';
import { User } from '../users/entities/user.entity';
import { TransactionHistory } from '../users/entities/transaction-history.entity';
import { CreateStakeMatchDto } from './dto/create-stake-match.dto';

@Injectable()
export class StakeMatchService {
  constructor(
    @InjectRepository(StakeMatch)
    private stakeMatchRepository: Repository<StakeMatch>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(TransactionHistory)
    private transactionRepository: Repository<TransactionHistory>,
  ) {}

  /**
   * Create a new stake match
   */
  async createStakeMatch(
    creatorId: string,
    createDto: CreateStakeMatchDto,
  ): Promise<StakeMatch> {
    const creator = await this.userRepository.findOne({ where: { id: creatorId } });
    if (!creator) {
      throw new NotFoundException('User not found');
    }

    // Check if user has enough coins (use both coin types)
    const totalCoins = creator.coins + creator.withdrawableCoins + creator.purchasedCoins;
    if (totalCoins < createDto.stakeAmount) {
      throw new BadRequestException('Insufficient coins to create stake match');
    }

    // Get user's commission rate (VIP gets reduced rate)
    const commissionRate = creator.commissionRate || 10;

    // Calculate pot and commission
    const totalPot = createDto.stakeAmount * 2;
    const commissionAmount = Math.floor(totalPot * (commissionRate / 100));
    const winnerPayout = totalPot - commissionAmount;

    // Deduct stake from creator's coins (prioritize purchased coins)
    await this.deductCoins(creator, createDto.stakeAmount, 'stake_match_created');

    // Create stake match
    const stakeMatch = this.stakeMatchRepository.create({
      creatorId,
      stakeAmount: createDto.stakeAmount,
      totalPot,
      commissionRate,
      commissionAmount,
      winnerPayout,
      status: 'waiting',
      numberOfQuestions: createDto.numberOfQuestions || 10,
      difficulty: createDto.difficulty || 'mixed',
    });

    const savedMatch = await this.stakeMatchRepository.save(stakeMatch);

    // Record transaction
    await this.recordTransaction(
      creatorId,
      'stake_match_created',
      -createDto.stakeAmount,
      'both',
      `Created stake match with ${createDto.stakeAmount} coins`,
      savedMatch.id,
      'stake_match',
    );

    return savedMatch;
  }

  /**
   * Join an existing stake match
   */
  async joinStakeMatch(
    opponentId: string,
    matchId: string,
  ): Promise<StakeMatch> {
    const match = await this.stakeMatchRepository.findOne({ 
      where: { id: matchId },
      relations: ['creator'],
    });

    if (!match) {
      throw new NotFoundException('Stake match not found');
    }

    if (match.status !== 'waiting') {
      throw new BadRequestException('Match is not available to join');
    }

    if (match.creatorId === opponentId) {
      throw new BadRequestException('Cannot join your own match');
    }

    const opponent = await this.userRepository.findOne({ where: { id: opponentId } });
    if (!opponent) {
      throw new NotFoundException('User not found');
    }

    // Check if user has enough coins
    const totalCoins = opponent.coins + opponent.withdrawableCoins + opponent.purchasedCoins;
    if (totalCoins < match.stakeAmount) {
      throw new BadRequestException('Insufficient coins to join stake match');
    }

    // Deduct stake from opponent's coins
    await this.deductCoins(opponent, match.stakeAmount, 'stake_match_joined');

    // Update match
    match.opponentId = opponentId;
    match.status = 'active';
    await this.stakeMatchRepository.save(match);

    // Record transaction
    await this.recordTransaction(
      opponentId,
      'stake_match_joined',
      -match.stakeAmount,
      'both',
      `Joined stake match with ${match.stakeAmount} coins`,
      match.id,
      'stake_match',
    );

    return match;
  }

  /**
   * Complete a stake match and distribute winnings
   */
  async completeStakeMatch(
    matchId: string,
    creatorScore: number,
    opponentScore: number,
  ): Promise<StakeMatch> {
    const match = await this.stakeMatchRepository.findOne({ 
      where: { id: matchId },
      relations: ['creator', 'opponent'],
    });

    if (!match) {
      throw new NotFoundException('Stake match not found');
    }

    if (match.status !== 'active') {
      throw new BadRequestException('Match is not active');
    }

    // Determine winner
    let winnerId: string;
    if (creatorScore > opponentScore) {
      winnerId = match.creatorId;
    } else if (opponentScore > creatorScore) {
      winnerId = match.opponentId;
    } else {
      // Draw - refund both players
      await this.refundStakeMatch(match);
      match.status = 'completed';
      match.creatorScore = creatorScore;
      match.opponentScore = opponentScore;
      match.completedAt = new Date();
      return await this.stakeMatchRepository.save(match);
    }

    // Award winnings to winner (as withdrawable coins)
    const winner = await this.userRepository.findOne({ where: { id: winnerId } });
    if (!winner) {
      throw new NotFoundException('Winner not found');
    }
    winner.withdrawableCoins += match.winnerPayout;
    await this.userRepository.save(winner);

    // Record transaction
    await this.recordTransaction(
      winnerId,
      'earned_stake_match',
      match.winnerPayout,
      'withdrawable',
      `Won stake match and earned ${match.winnerPayout} withdrawable coins`,
      match.id,
      'stake_match',
    );

    // Update match
    match.winnerId = winnerId;
    match.status = 'completed';
    match.creatorScore = creatorScore;
    match.opponentScore = opponentScore;
    match.completedAt = new Date();

    return await this.stakeMatchRepository.save(match);
  }

  /**
   * Cancel a stake match and refund creator
   */
  async cancelStakeMatch(
    matchId: string,
    userId: string,
  ): Promise<StakeMatch> {
    const match = await this.stakeMatchRepository.findOne({ where: { id: matchId } });

    if (!match) {
      throw new NotFoundException('Stake match not found');
    }

    if (match.creatorId !== userId) {
      throw new BadRequestException('Only the creator can cancel the match');
    }

    if (match.status !== 'waiting') {
      throw new BadRequestException('Can only cancel matches that are waiting');
    }

    // Refund creator
    const creator = await this.userRepository.findOne({ where: { id: match.creatorId } });
    if (!creator) {
      throw new NotFoundException('Creator not found');
    }
    creator.purchasedCoins += match.stakeAmount; // Refund as purchased coins
    await this.userRepository.save(creator);

    // Record transaction
    await this.recordTransaction(
      match.creatorId,
      'refund',
      match.stakeAmount,
      'purchased',
      `Refund for cancelled stake match`,
      match.id,
      'stake_match',
    );

    // Update match
    match.status = 'cancelled';
    match.cancelledAt = new Date();
    match.cancellationReason = 'Cancelled by creator';

    return await this.stakeMatchRepository.save(match);
  }

  /**
   * Get all available stake matches (waiting status)
   */
  async getAvailableMatches(limit: number = 20): Promise<StakeMatch[]> {
    return await this.stakeMatchRepository.find({
      where: { status: 'waiting' },
      relations: ['creator'],
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  /**
   * Get user's stake match history
   */
  async getUserStakeMatches(userId: string): Promise<StakeMatch[]> {
    return await this.stakeMatchRepository
      .createQueryBuilder('match')
      .leftJoinAndSelect('match.creator', 'creator')
      .leftJoinAndSelect('match.opponent', 'opponent')
      .leftJoinAndSelect('match.winner', 'winner')
      .where('match.creatorId = :userId OR match.opponentId = :userId', { userId })
      .orderBy('match.createdAt', 'DESC')
      .take(50)
      .getMany();
  }

  /**
   * Get stake match by ID
   */
  async getStakeMatchById(matchId: string): Promise<StakeMatch> {
    const match = await this.stakeMatchRepository.findOne({
      where: { id: matchId },
      relations: ['creator', 'opponent', 'winner'],
    });

    if (!match) {
      throw new NotFoundException('Stake match not found');
    }

    return match;
  }

  /**
   * Helper: Deduct coins from user (prioritize purchased coins)
   */
  private async deductCoins(user: User, amount: number, reason: string): Promise<void> {
    let remaining = amount;

    // First, use purchased coins (non-withdrawable)
    if (user.purchasedCoins > 0) {
      const fromPurchased = Math.min(user.purchasedCoins, remaining);
      user.purchasedCoins -= fromPurchased;
      remaining -= fromPurchased;
    }

    // Then, use regular coins
    if (remaining > 0 && user.coins > 0) {
      const fromCoins = Math.min(user.coins, remaining);
      user.coins -= fromCoins;
      remaining -= fromCoins;
    }

    // Finally, use withdrawable coins (if necessary)
    if (remaining > 0 && user.withdrawableCoins > 0) {
      const fromWithdrawable = Math.min(user.withdrawableCoins, remaining);
      user.withdrawableCoins -= fromWithdrawable;
      remaining -= fromWithdrawable;
    }

    if (remaining > 0) {
      throw new BadRequestException('Insufficient coins');
    }

    await this.userRepository.save(user);
  }

  /**
   * Helper: Refund both players in case of draw
   */
  private async refundStakeMatch(match: StakeMatch): Promise<void> {
    const creator = await this.userRepository.findOne({ where: { id: match.creatorId } });
    const opponent = await this.userRepository.findOne({ where: { id: match.opponentId } });

    if (!creator || !opponent) {
      throw new NotFoundException('Players not found for refund');
    }

    // Refund as purchased coins (non-withdrawable)
    creator.purchasedCoins += match.stakeAmount;
    opponent.purchasedCoins += match.stakeAmount;

    await this.userRepository.save(creator);
    await this.userRepository.save(opponent);

    // Record transactions
    await this.recordTransaction(
      match.creatorId,
      'refund',
      match.stakeAmount,
      'purchased',
      'Refund due to draw',
      match.id,
      'stake_match',
    );

    await this.recordTransaction(
      match.opponentId,
      'refund',
      match.stakeAmount,
      'purchased',
      'Refund due to draw',
      match.id,
      'stake_match',
    );
  }

  /**
   * Helper: Record transaction history
   */
  private async recordTransaction(
    userId: string,
    type: string,
    amount: number,
    coinType: string,
    description: string,
    relatedEntityId: string,
    relatedEntityType: string,
  ): Promise<void> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found for transaction');
    }
    const totalBalance = user.coins + user.withdrawableCoins + user.purchasedCoins;

    const transaction = this.transactionRepository.create({
      userId,
      type,
      amount,
      coinType,
      balanceBefore: totalBalance - amount,
      balanceAfter: totalBalance,
      description,
      relatedEntityId,
      relatedEntityType,
    });

    await this.transactionRepository.save(transaction);
  }
}

