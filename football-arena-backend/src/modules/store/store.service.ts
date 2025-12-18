import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { TransactionHistory } from '../users/entities/transaction-history.entity';
import { UsersService } from '../users/users.service';

export enum StoreItemType {
  COIN_PACK = 'coin_pack',
  VIP_SUBSCRIPTION = 'vip_subscription',
  VIP_ONE_TIME = 'vip_one_time',
  BOOST = 'boost',
}

export interface PurchaseRequest {
  userId: string;
  itemType: StoreItemType;
  itemId: string;
  amount?: number; // For coin packs
  duration?: number; // For VIP subscriptions (in days)
  paymentMethod: 'coins' | 'iap' | 'subscription';
  transactionId?: string; // For IAP verification
}

@Injectable()
export class StoreService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(TransactionHistory)
    private transactionRepository: Repository<TransactionHistory>,
    private usersService: UsersService,
  ) {}

  // Store items configuration
  private readonly storeItems = {
    coin_packs: {
      small: { coins: 500, price: 0.99, iapId: 'coin_pack_small' },
      medium: { coins: 1500, price: 2.99, iapId: 'coin_pack_medium', bonus: 0.2 },
      large: { coins: 5000, price: 7.99, iapId: 'coin_pack_large', bonus: 0.25 },
    },
    vip: {
      monthly: { price: 4.99, duration: 30, iapId: 'vip_monthly' },
      yearly: { price: 39.99, duration: 365, iapId: 'vip_yearly' },
      lifetime: { price: 99.99, iapId: 'vip_lifetime' },
    },
    boosts: {
      extra_time: { coins: 50, description: '+5 seconds per question' },
      skip: { coins: 30, description: 'Skip any question' },
      reveal_wrong: { coins: 40, description: 'Reveal one wrong option' },
    },
  };

  async purchaseItem(purchaseRequest: PurchaseRequest): Promise<any> {
    try {
    const { userId, itemType, itemId, paymentMethod, transactionId } = purchaseRequest;
      
      console.log('[StoreService] Purchase request:', {
        userId,
        itemType,
        itemId,
        paymentMethod,
      });

      if (!userId || !itemType || !itemId || !paymentMethod) {
        throw new BadRequestException('Missing required fields: userId, itemType, itemId, paymentMethod');
      }
    
    const user = await this.usersService.findOne(userId);
      if (!user) {
        throw new NotFoundException(`User with ID ${userId} not found`);
      }

      // Normalize itemType to match enum values
      const normalizedItemType = itemType.toLowerCase();

      if (normalizedItemType === 'coin_pack' || itemType === StoreItemType.COIN_PACK) {
      return await this.purchaseCoinPack(user, itemId, paymentMethod, transactionId);
      } else if (normalizedItemType === 'vip_subscription' || normalizedItemType === 'vip_one_time' || 
                 itemType === StoreItemType.VIP_SUBSCRIPTION || itemType === StoreItemType.VIP_ONE_TIME) {
        const vipType = normalizedItemType === 'vip_one_time' ? StoreItemType.VIP_ONE_TIME : StoreItemType.VIP_SUBSCRIPTION;
        return await this.purchaseVIP(user, itemId, vipType, paymentMethod, transactionId);
      } else if (normalizedItemType === 'boost' || itemType === StoreItemType.BOOST) {
      return await this.purchaseBoost(user, itemId);
    }

      throw new BadRequestException(`Invalid item type: ${itemType}`);
    } catch (error) {
      console.error('[StoreService] Purchase error:', error);
      throw error;
    }
  }

  private async purchaseCoinPack(
    user: User,
    packId: string,
    paymentMethod: string,
    transactionId?: string,
  ): Promise<any> {
    console.log('[StoreService] Purchasing coin pack:', {
      packId,
      paymentMethod,
      availablePacks: Object.keys(this.storeItems.coin_packs),
    });

    const pack = this.storeItems.coin_packs[packId];
    if (!pack) {
      throw new NotFoundException(`Coin pack '${packId}' not found. Available packs: ${Object.keys(this.storeItems.coin_packs).join(', ')}`);
    }

    if (paymentMethod === 'iap') {
      // In production, verify IAP transaction with Apple/Google
      // For now, we'll trust the transactionId
      if (!transactionId) {
        throw new BadRequestException('Transaction ID required for IAP');
      }
      
      // Verify IAP (mock - implement real verification)
      const verified = await this.verifyIAPTransaction(transactionId, pack.iapId);
      if (!verified) {
        throw new BadRequestException('IAP transaction verification failed');
      }
    }

    let coinsToAdd = pack.coins;
    if (pack.bonus) {
      coinsToAdd = Math.floor(pack.coins * (1 + pack.bonus));
    }

    // Calculate balance before transaction
    const balanceBefore = user.coins + user.withdrawableCoins + user.purchasedCoins;

    // Add as purchased coins (non-withdrawable)
    user.purchasedCoins += coinsToAdd;
    await this.usersRepository.save(user);

    // Record transaction with correct balances
    const balanceAfter = user.coins + user.withdrawableCoins + user.purchasedCoins;
    await this.recordTransactionDirect(
      user.id,
      'purchase',
      coinsToAdd,
      'purchased',
      `Purchased ${packId} coin pack (${coinsToAdd} non-withdrawable coins)`,
      balanceBefore,
      balanceAfter,
    );

    const updatedUser = await this.usersService.findOne(user.id);

    return {
      success: true,
      coinsAdded: coinsToAdd,
      newBalance: updatedUser.coins + updatedUser.purchasedCoins + updatedUser.withdrawableCoins,
      purchasedCoins: updatedUser.purchasedCoins,
      message: `Successfully purchased ${coinsToAdd} coins (non-withdrawable)!`,
    };
  }

  private async purchaseVIP(
    user: User,
    vipId: string,
    itemType: StoreItemType,
    paymentMethod: string,
    transactionId?: string,
  ): Promise<any> {
    const vip = this.storeItems.vip[vipId];
    if (!vip) {
      throw new NotFoundException('VIP package not found');
    }

    if (paymentMethod === 'iap' || paymentMethod === 'subscription') {
      if (!transactionId) {
        throw new BadRequestException('Transaction ID required for IAP');
      }
      
      // Verify IAP (mock - implement real verification)
      const verified = await this.verifyIAPTransaction(transactionId, vip.iapId);
      if (!verified) {
        throw new BadRequestException('IAP transaction verification failed');
      }
    }

    const now = new Date();
    let expiryDate: Date | null = null;

    if (itemType === StoreItemType.VIP_ONE_TIME && vipId === 'lifetime') {
      expiryDate = null; // Lifetime VIP
    } else if (vip.duration) {
      expiryDate = new Date(now.getTime() + vip.duration * 24 * 60 * 60 * 1000);
    }

    // Extend existing VIP if user already has it
    if (user.isVip && user.vipExpiryDate) {
      const currentExpiry = new Date(user.vipExpiryDate);
      if (currentExpiry > now) {
        expiryDate = new Date(currentExpiry.getTime() + (vip.duration || 0) * 24 * 60 * 60 * 1000);
      }
    }

    // Build update object - handle null expiry date for lifetime VIP
    const updateData: Partial<User> = {
      isVip: true,
      commissionRate: 5, // VIP gets reduced commission rate (5% instead of 10%)
    };
    
    // For lifetime VIP (expiryDate is null), we still need to set it explicitly
    // TypeORM requires explicit null assignment for nullable fields
    if (expiryDate === null) {
      // Use undefined to clear the field, or explicitly set null
      (updateData as any).vipExpiryDate = null;
    } else {
      updateData.vipExpiryDate = expiryDate;
    }
    
    await this.usersRepository.update(user.id, updateData);

    const updatedUser = await this.usersService.findOne(user.id);

    return {
      success: true,
      isVip: true,
      vipExpiryDate: expiryDate,
      commissionRate: 5,
      message: `VIP membership activated${expiryDate ? ` until ${expiryDate.toLocaleDateString()}` : ' (Lifetime)'}! You now get reduced commission rates on stake matches.`,
    };
  }

  private async purchaseBoost(user: User, boostId: string): Promise<any> {
    console.log('[StoreService] Purchasing boost:', {
      boostId,
      availableBoosts: Object.keys(this.storeItems.boosts),
      userCoins: user.coins,
    });

    const boost = this.storeItems.boosts[boostId];
    if (!boost) {
      throw new NotFoundException(`Boost '${boostId}' not found. Available boosts: ${Object.keys(this.storeItems.boosts).join(', ')}`);
    }

    const totalCoins = user.coins + user.purchasedCoins;
    if (totalCoins < boost.coins) {
      throw new BadRequestException(`Insufficient coins. Need ${boost.coins}, have ${totalCoins}`);
    }

    // Deduct coins (prioritize purchased coins, then regular coins)
    let remaining = boost.coins;
    
    if (user.purchasedCoins >= remaining) {
      user.purchasedCoins -= remaining;
    } else {
      remaining -= user.purchasedCoins;
      user.purchasedCoins = 0;
      user.coins -= remaining;
    }

    await this.usersRepository.save(user);

    console.log('[StoreService] Boost purchased successfully');

    // In a real app, you'd store boost inventory or apply it immediately
    // For now, we'll just deduct coins and return success

    return {
      success: true,
      boostId,
      boostDescription: boost.description,
      coinsSpent: boost.coins,
      message: `Boost purchased: ${boost.description}`,
    };
  }

  private async verifyIAPTransaction(transactionId: string, productId: string): Promise<boolean> {
    // Mock implementation - in production, verify with Apple/Google servers
    // This should call Apple App Store or Google Play Billing API
    return true; // For now, always return true
  }

  getStoreItems() {
    return {
      coinPacks: this.storeItems.coin_packs,
      vip: this.storeItems.vip,
      boosts: this.storeItems.boosts,
    };
  }

  /**
   * Helper: Record transaction history (with direct balance values)
   */
  private async recordTransactionDirect(
    userId: string,
    type: string,
    amount: number,
    coinType: string,
    description: string,
    balanceBefore: number,
    balanceAfter: number,
  ): Promise<void> {
    const transaction = this.transactionRepository.create({
      userId,
      type,
      amount,
      coinType,
      balanceBefore,
      balanceAfter,
      description,
    });

    await this.transactionRepository.save(transaction);
  }

  /**
   * Helper: Record transaction history (legacy - calculates balance)
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
    const user = await this.usersRepository.findOne({ where: { id: userId } });
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

