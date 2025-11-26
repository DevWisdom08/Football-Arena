import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UnlockableItem, UnlockableItemType, UnlockMethod } from './entities/unlockable-item.entity';
import { UserUnlock } from './entities/user-unlock.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class UnlocksService {
  constructor(
    @InjectRepository(UnlockableItem)
    private unlockableItemRepository: Repository<UnlockableItem>,
    @InjectRepository(UserUnlock)
    private userUnlockRepository: Repository<UserUnlock>,
    private usersService: UsersService,
  ) {}

  async getAllUnlockableItems(): Promise<UnlockableItem[]> {
    return await this.unlockableItemRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC', requiredLevel: 'ASC', name: 'ASC' },
    });
  }

  async getUnlockableItemById(id: string): Promise<UnlockableItem> {
    const item = await this.unlockableItemRepository.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Unlockable item with ID ${id} not found`);
    }
    return item;
  }

  async getUserUnlocks(userId: string): Promise<UserUnlock[]> {
    return await this.userUnlockRepository.find({
      where: { userId },
      relations: ['item'],
      order: { createdAt: 'DESC' },
    });
  }

  async getUserUnlockedItems(userId: string): Promise<UnlockableItem[]> {
    const userUnlocks = await this.userUnlockRepository.find({
      where: { userId, isUnlocked: true },
      relations: ['item'],
    });
    return userUnlocks.map(uu => uu.item);
  }

  async getUnlockedItemsByType(userId: string, itemType: UnlockableItemType): Promise<UnlockableItem[]> {
    const userUnlocks = await this.userUnlockRepository.find({
      where: { userId, isUnlocked: true },
      relations: ['item'],
    });
    return userUnlocks
      .map(uu => uu.item)
      .filter(item => item.itemType === itemType);
  }

  async getUpcomingUnlocks(userId: string): Promise<{
    unlocked: UnlockableItem[];
    upcoming: UnlockableItem[];
    locked: UnlockableItem[];
  }> {
    const user = await this.usersService.findOne(userId);
    const allItems = await this.getAllUnlockableItems();
    const userUnlocks = await this.getUserUnlocks(userId);
    const unlockedItemIds = new Set(
      userUnlocks.filter(uu => uu.isUnlocked).map(uu => uu.itemId),
    );

    const unlocked: UnlockableItem[] = [];
    const upcoming: UnlockableItem[] = [];
    const locked: UnlockableItem[] = [];

    for (const item of allItems) {
      if (unlockedItemIds.has(item.id)) {
        unlocked.push(item);
      } else if (this.canUnlock(user, item)) {
        upcoming.push(item);
      } else {
        locked.push(item);
      }
    }

    return { unlocked, upcoming, locked };
  }

  private canUnlock(user: any, item: UnlockableItem): boolean {
    // Check level requirement
    if (item.unlockMethod === UnlockMethod.LEVEL) {
      return user.level >= item.requiredLevel && (!item.requiresVip || user.isVip);
    }

    // Check VIP requirement
    if (item.requiresVip && !user.isVip) {
      return false;
    }

    // Check achievement requirement
    if (item.unlockMethod === UnlockMethod.ACHIEVEMENT && item.requiredAchievement) {
      return user.badges.includes(item.requiredAchievement);
    }

    return false;
  }

  async checkAndUnlockItems(userId: string): Promise<UnlockableItem[]> {
    const user = await this.usersService.findOne(userId);
    const allItems = await this.getAllUnlockableItems();
    const userUnlocks = await this.getUserUnlocks(userId);
    const unlockedItemIds = new Set(
      userUnlocks.filter(uu => uu.isUnlocked).map(uu => uu.itemId),
    );

    const newlyUnlocked: UnlockableItem[] = [];

    for (const item of allItems) {
      // Skip if already unlocked
      if (unlockedItemIds.has(item.id)) continue;

      // Check unlock conditions
      let shouldUnlock = false;
      let unlockMethod = '';

      if (item.unlockMethod === UnlockMethod.LEVEL) {
        if (user.level >= item.requiredLevel && (!item.requiresVip || user.isVip)) {
          shouldUnlock = true;
          unlockMethod = 'level';
        }
      } else if (item.unlockMethod === UnlockMethod.VIP) {
        if (user.isVip && (!user.vipExpiryDate || new Date(user.vipExpiryDate) > new Date())) {
          shouldUnlock = true;
          unlockMethod = 'vip';
        }
      } else if (item.unlockMethod === UnlockMethod.ACHIEVEMENT) {
        if (item.requiredAchievement && user.badges.includes(item.requiredAchievement)) {
          shouldUnlock = true;
          unlockMethod = 'achievement';
        }
      }

      if (shouldUnlock) {
        // Create or update user unlock record
        let userUnlock = await this.userUnlockRepository.findOne({
          where: { userId, itemId: item.id },
        });

        if (!userUnlock) {
          userUnlock = this.userUnlockRepository.create({
            userId,
            itemId: item.id,
            isUnlocked: true,
            unlockedAt: new Date(),
            unlockMethod,
            isEquipped: false,
          });
        } else {
          userUnlock.isUnlocked = true;
          userUnlock.unlockedAt = new Date();
          userUnlock.unlockMethod = unlockMethod;
        }

        await this.userUnlockRepository.save(userUnlock);
        newlyUnlocked.push(item);
      }
    }

    return newlyUnlocked;
  }

  async unlockItemWithCoins(userId: string, itemId: string): Promise<UnlockableItem> {
    const user = await this.usersService.findOne(userId);
    const item = await this.getUnlockableItemById(itemId);

    if (item.unlockMethod !== UnlockMethod.COINS && item.unlockMethod !== UnlockMethod.PURCHASE) {
      throw new BadRequestException('This item cannot be unlocked with coins');
    }

    // Check if already unlocked
    const existingUserUnlock = await this.userUnlockRepository.findOne({
      where: { userId, itemId },
    });

    if (existingUserUnlock?.isUnlocked) {
      throw new BadRequestException('Item is already unlocked');
    }

    // Check if user has enough coins
    if (user.coins < item.requiredCoins) {
      throw new BadRequestException(
        `Insufficient coins. Need ${item.requiredCoins} coins to unlock this item.`,
      );
    }

    // Deduct coins
    await this.usersService.update(userId, {
      coins: user.coins - item.requiredCoins,
    });

    // Unlock item
    let userUnlock = existingUserUnlock;
    if (!userUnlock) {
      userUnlock = this.userUnlockRepository.create({
        userId,
        itemId,
        isUnlocked: true,
        unlockedAt: new Date(),
        unlockMethod: 'coins',
        isEquipped: false,
      });
    } else {
      userUnlock.isUnlocked = true;
      userUnlock.unlockedAt = new Date();
      userUnlock.unlockMethod = 'coins';
    }

    await this.userUnlockRepository.save(userUnlock);

    return item;
  }

  async getItemsByLevel(level: number): Promise<UnlockableItem[]> {
    return await this.unlockableItemRepository.find({
      where: {
        isActive: true,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: level,
      },
      order: { sortOrder: 'ASC' },
    });
  }

  async getItemsUnlockedAtLevel(level: number): Promise<UnlockableItem[]> {
    return await this.unlockableItemRepository.find({
      where: {
        isActive: true,
        unlockMethod: UnlockMethod.LEVEL,
      },
      order: { requiredLevel: 'ASC', sortOrder: 'ASC' },
    }).then(items => items.filter(item => item.requiredLevel <= level));
  }

  async getNextLevelUnlocks(currentLevel: number, limit: number = 5): Promise<UnlockableItem[]> {
    return await this.unlockableItemRepository.find({
      where: {
        isActive: true,
        unlockMethod: UnlockMethod.LEVEL,
      },
      order: { requiredLevel: 'ASC', sortOrder: 'ASC' },
    }).then(items => 
      items
        .filter(item => item.requiredLevel > currentLevel)
        .slice(0, limit)
    );
  }

  // Admin methods
  async createUnlockableItem(itemData: Partial<UnlockableItem>): Promise<UnlockableItem> {
    const item = this.unlockableItemRepository.create(itemData);
    return await this.unlockableItemRepository.save(item);
  }

  async updateUnlockableItem(id: string, itemData: Partial<UnlockableItem>): Promise<UnlockableItem> {
    await this.getUnlockableItemById(id);
    await this.unlockableItemRepository.update(id, itemData);
    return this.getUnlockableItemById(id);
  }

  async deleteUnlockableItem(id: string): Promise<void> {
    await this.getUnlockableItemById(id);
    await this.unlockableItemRepository.update(id, { isActive: false });
  }

  async seedDefaultItems(): Promise<void> {
    const defaultItems = [
      {
        name: 'Galaxy Banner',
        description: 'Unlock at level 15',
        itemType: UnlockableItemType.BANNER,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 15,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 2,
        sortOrder: 1,
      },
      {
        name: 'Premium Celebration Animation',
        description: 'Unlock at level 18',
        itemType: UnlockableItemType.ANIMATION,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 18,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 2,
        sortOrder: 2,
      },
      {
        name: 'Weekend Elite Events Access',
        description: 'Unlock at level 25',
        itemType: UnlockableItemType.EVENT_ACCESS,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 25,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 3,
        sortOrder: 3,
      },
      {
        name: 'Champion Title',
        description: 'Unlock at level 30',
        itemType: UnlockableItemType.TITLE,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 30,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 2,
        sortOrder: 4,
      },
      {
        name: 'Master Title',
        description: 'Unlock at level 50',
        itemType: UnlockableItemType.TITLE,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 50,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 3,
        sortOrder: 5,
      },
      {
        name: 'Legend Title',
        description: 'Unlock at level 100',
        itemType: UnlockableItemType.TITLE,
        unlockMethod: UnlockMethod.LEVEL,
        requiredLevel: 100,
        requiresVip: false,
        requiredCoins: 0,
        rarity: 3,
        sortOrder: 6,
      },
    ];

    for (const itemData of defaultItems) {
      const existing = await this.unlockableItemRepository.findOne({
        where: { name: itemData.name },
      });

      if (!existing) {
        await this.createUnlockableItem(itemData);
      }
    }
  }
}

