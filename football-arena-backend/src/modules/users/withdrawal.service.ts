import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { WithdrawalRequest } from './entities/withdrawal-request.entity';
import { TransactionHistory } from './entities/transaction-history.entity';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { SubmitKycDto } from './dto/submit-kyc.dto';
import { ProcessWithdrawalDto } from './dto/process-withdrawal.dto';

@Injectable()
export class WithdrawalService {
  // Conversion rate: 1000 coins = $1 USD
  private readonly COINS_TO_USD_RATE = 1000;
  
  // Withdrawal fee: 5%
  private readonly WITHDRAWAL_FEE_PERCENTAGE = 5;

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(WithdrawalRequest)
    private withdrawalRepository: Repository<WithdrawalRequest>,
    @InjectRepository(TransactionHistory)
    private transactionRepository: Repository<TransactionHistory>,
  ) {}

  /**
   * Submit KYC verification
   */
  async submitKyc(userId: string, kycDto: SubmitKycDto): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.kycVerified) {
      throw new BadRequestException('KYC already verified');
    }

    // Update user with KYC data
    user.kycFullName = kycDto.fullName;
    user.kycDateOfBirth = new Date(kycDto.dateOfBirth);
    user.kycIdNumber = kycDto.idNumber;
    user.kycIdPhotoUrl = kycDto.idPhotoUrl;
    user.kycSelfieUrl = kycDto.selfieUrl;
    user.kycStatus = 'pending';

    return await this.userRepository.save(user);
  }

  /**
   * Approve or reject KYC (admin only)
   */
  async processKyc(
    userId: string,
    approved: boolean,
    adminId: string,
  ): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (approved) {
      user.kycVerified = true;
      user.kycStatus = 'approved';
    } else {
      user.kycVerified = false;
      user.kycStatus = 'rejected';
    }

    return await this.userRepository.save(user);
  }

  /**
   * Create a withdrawal request
   */
  async createWithdrawal(
    userId: string,
    withdrawalDto: CreateWithdrawalDto,
  ): Promise<WithdrawalRequest> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check KYC verification
    if (!user.kycVerified) {
      throw new BadRequestException('KYC verification required before withdrawal');
    }

    // Check age (must be 18+)
    if (user.kycDateOfBirth) {
      const age = this.calculateAge(user.kycDateOfBirth);
      if (age < 18) {
        throw new BadRequestException('Must be 18+ to withdraw');
      }
    }

    // Check if user has enough withdrawable coins
    if (user.withdrawableCoins < withdrawalDto.amount) {
      throw new BadRequestException('Insufficient withdrawable coins');
    }

    // Check minimum withdrawal
    if (withdrawalDto.amount < 10000) {
      throw new BadRequestException('Minimum withdrawal is 10,000 coins ($10)');
    }

    // Calculate amounts
    const amountInUSD = withdrawalDto.amount / this.COINS_TO_USD_RATE;
    const withdrawalFee = amountInUSD * (this.WITHDRAWAL_FEE_PERCENTAGE / 100);
    const netAmount = amountInUSD - withdrawalFee;

    // Deduct coins immediately
    user.withdrawableCoins -= withdrawalDto.amount;
    await this.userRepository.save(user);

    // Create withdrawal request
    const withdrawal = this.withdrawalRepository.create({
      userId,
      amount: withdrawalDto.amount,
      amountInUSD,
      withdrawalFee,
      netAmount,
      withdrawalMethod: withdrawalDto.withdrawalMethod,
      paymentDetails: withdrawalDto.paymentDetails,
      status: 'pending',
    });

    const savedWithdrawal = await this.withdrawalRepository.save(withdrawal);

    // Record transaction
    await this.recordTransaction(
      userId,
      'withdrawal',
      -withdrawalDto.amount,
      'withdrawable',
      `Withdrawal request: ${withdrawalDto.amount} coins → $${netAmount.toFixed(2)} via ${withdrawalDto.withdrawalMethod}`,
      savedWithdrawal.id,
      'withdrawal',
    );

    return savedWithdrawal;
  }

  /**
   * Process withdrawal request (admin only)
   */
  async processWithdrawal(
    processDto: ProcessWithdrawalDto,
    adminId: string,
  ): Promise<WithdrawalRequest> {
    const withdrawal = await this.withdrawalRepository.findOne({
      where: { id: processDto.withdrawalId },
      relations: ['user'],
    });

    if (!withdrawal) {
      throw new NotFoundException('Withdrawal request not found');
    }

    if (withdrawal.status !== 'pending') {
      throw new BadRequestException('Withdrawal already processed');
    }

    if (processDto.action === 'approve') {
      withdrawal.status = 'approved';
      withdrawal.processedBy = adminId;
      withdrawal.processedAt = new Date();
      
      if (processDto.transactionId) {
        withdrawal.transactionId = processDto.transactionId;
        withdrawal.status = 'completed';
        withdrawal.completedAt = new Date();
      }
    } else if (processDto.action === 'reject') {
      withdrawal.status = 'rejected';
      withdrawal.processedBy = adminId;
      withdrawal.processedAt = new Date();
      withdrawal.rejectionReason = processDto.rejectionReason || 'No reason provided';

      // Refund coins to user
      const user = await this.userRepository.findOne({ where: { id: withdrawal.userId } });
      if (!user) {
        throw new NotFoundException('User not found for refund');
      }
      user.withdrawableCoins += withdrawal.amount;
      await this.userRepository.save(user);

      // Record refund transaction
      await this.recordTransaction(
        withdrawal.userId,
        'refund',
        withdrawal.amount,
        'withdrawable',
        `Withdrawal rejected and refunded: ${processDto.rejectionReason}`,
        withdrawal.id,
        'withdrawal',
      );
    }

    return await this.withdrawalRepository.save(withdrawal);
  }

  /**
   * Complete withdrawal (mark as completed after payment sent)
   */
  async completeWithdrawal(
    withdrawalId: string,
    transactionId: string,
    adminId: string,
  ): Promise<WithdrawalRequest> {
    const withdrawal = await this.withdrawalRepository.findOne({
      where: { id: withdrawalId },
    });

    if (!withdrawal) {
      throw new NotFoundException('Withdrawal request not found');
    }

    if (withdrawal.status !== 'approved') {
      throw new BadRequestException('Withdrawal must be approved first');
    }

    withdrawal.status = 'completed';
    withdrawal.transactionId = transactionId;
    withdrawal.completedAt = new Date();

    return await this.withdrawalRepository.save(withdrawal);
  }

  /**
   * Cancel withdrawal request (user can cancel pending requests)
   */
  async cancelWithdrawal(userId: string, withdrawalId: string): Promise<WithdrawalRequest> {
    const withdrawal = await this.withdrawalRepository.findOne({
      where: { id: withdrawalId },
    });

    if (!withdrawal) {
      throw new NotFoundException('Withdrawal request not found');
    }

    if (withdrawal.userId !== userId) {
      throw new BadRequestException('Not authorized');
    }

    if (withdrawal.status !== 'pending') {
      throw new BadRequestException('Can only cancel pending withdrawals');
    }

    withdrawal.status = 'cancelled';

    // Refund coins
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found for refund');
    }
    user.withdrawableCoins += withdrawal.amount;
    await this.userRepository.save(user);

    // Record refund transaction
    await this.recordTransaction(
      userId,
      'refund',
      withdrawal.amount,
      'withdrawable',
      'Withdrawal cancelled by user',
      withdrawal.id,
      'withdrawal',
    );

    return await this.withdrawalRepository.save(withdrawal);
  }

  /**
   * Get user's withdrawal history
   */
  async getUserWithdrawals(userId: string): Promise<WithdrawalRequest[]> {
    return await this.withdrawalRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get all pending withdrawals (admin only)
   */
  async getPendingWithdrawals(): Promise<WithdrawalRequest[]> {
    return await this.withdrawalRepository.find({
      where: { status: 'pending' },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });
  }

  /**
   * Get all withdrawals (admin only)
   */
  async getAllWithdrawals(limit: number = 100): Promise<WithdrawalRequest[]> {
    return await this.withdrawalRepository.find({
      relations: ['user'],
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  /**
   * Get user's transaction history
   */
  async getUserTransactions(userId: string): Promise<TransactionHistory[]> {
    return await this.transactionRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  /**
   * Helper: Calculate age from date of birth
   */
  private calculateAge(dateOfBirth: Date): number {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
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

