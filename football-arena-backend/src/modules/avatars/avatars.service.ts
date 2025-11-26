import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Avatar, AvatarUnlockType } from './entities/avatar.entity';
import { UserAvatar } from './entities/user-avatar.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class AvatarsService {
  constructor(
    @InjectRepository(Avatar)
    private avatarRepository: Repository<Avatar>,
    @InjectRepository(UserAvatar)
    private userAvatarRepository: Repository<UserAvatar>,
    private usersService: UsersService,
  ) {}

  async getAllAvatars(): Promise<Avatar[]> {
    return await this.avatarRepository.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC', name: 'ASC' },
    });
  }

  async getAvatarById(id: string): Promise<Avatar> {
    const avatar = await this.avatarRepository.findOne({ where: { id } });
    if (!avatar) {
      throw new NotFoundException(`Avatar with ID ${id} not found`);
    }
    return avatar;
  }

  async getUserAvatars(userId: string): Promise<UserAvatar[]> {
    return await this.userAvatarRepository.find({
      where: { userId },
      relations: ['avatar'],
      order: { createdAt: 'DESC' },
    });
  }

  async getUserUnlockedAvatars(userId: string): Promise<Avatar[]> {
    const userAvatars = await this.userAvatarRepository.find({
      where: { userId, isUnlocked: true },
      relations: ['avatar'],
    });
    return userAvatars.map(ua => ua.avatar);
  }

  async getEquippedAvatar(userId: string): Promise<Avatar | null> {
    const userAvatar = await this.userAvatarRepository.findOne({
      where: { userId, isEquipped: true },
      relations: ['avatar'],
    });
    return userAvatar?.avatar || null;
  }

  async checkAndUnlockAvatars(userId: string): Promise<Avatar[]> {
    const user = await this.usersService.findOne(userId);
    const allAvatars = await this.getAllAvatars();
    const userAvatars = await this.getUserAvatars(userId);
    const unlockedAvatarIds = new Set(
      userAvatars.filter(ua => ua.isUnlocked).map(ua => ua.avatarId),
    );

    const newlyUnlocked: Avatar[] = [];

    for (const avatar of allAvatars) {
      // Skip if already unlocked
      if (unlockedAvatarIds.has(avatar.id)) continue;

      // Check unlock conditions
      let shouldUnlock = false;
      let unlockMethod = '';

      switch (avatar.unlockType) {
        case AvatarUnlockType.DEFAULT:
          shouldUnlock = true;
          unlockMethod = 'default';
          break;

        case AvatarUnlockType.LEVEL:
          if (user.level >= avatar.requiredLevel) {
            shouldUnlock = true;
            unlockMethod = 'level';
          }
          break;

        case AvatarUnlockType.VIP:
          if (user.isVip && (!user.vipExpiryDate || new Date(user.vipExpiryDate) > new Date())) {
            shouldUnlock = true;
            unlockMethod = 'vip';
          }
          break;

        case AvatarUnlockType.ACHIEVEMENT:
          if (avatar.requiredAchievement && user.badges.includes(avatar.requiredAchievement)) {
            shouldUnlock = true;
            unlockMethod = 'achievement';
          }
          break;

        case AvatarUnlockType.COINS:
        case AvatarUnlockType.SPECIAL:
          // These require manual unlock via purchase or admin action
          break;
      }

      if (shouldUnlock) {
        // Create or update user avatar record
        let userAvatar = await this.userAvatarRepository.findOne({
          where: { userId, avatarId: avatar.id },
        });

        if (!userAvatar) {
          userAvatar = this.userAvatarRepository.create({
            userId,
            avatarId: avatar.id,
            isUnlocked: true,
            unlockedAt: new Date(),
            unlockMethod,
            isEquipped: false,
          });
        } else {
          userAvatar.isUnlocked = true;
          userAvatar.unlockedAt = new Date();
          userAvatar.unlockMethod = unlockMethod;
        }

        await this.userAvatarRepository.save(userAvatar);
        newlyUnlocked.push(avatar);
      }
    }

    return newlyUnlocked;
  }

  async unlockAvatarWithCoins(userId: string, avatarId: string): Promise<Avatar> {
    const user = await this.usersService.findOne(userId);
    const avatar = await this.getAvatarById(avatarId);

    if (avatar.unlockType !== AvatarUnlockType.COINS) {
      throw new BadRequestException('This avatar cannot be unlocked with coins');
    }

    // Check if already unlocked
    const existingUserAvatar = await this.userAvatarRepository.findOne({
      where: { userId, avatarId },
    });

    if (existingUserAvatar?.isUnlocked) {
      throw new BadRequestException('Avatar is already unlocked');
    }

    // Check if user has enough coins
    if (user.coins < avatar.requiredCoins) {
      throw new BadRequestException(
        `Insufficient coins. Need ${avatar.requiredCoins} coins to unlock this avatar.`,
      );
    }

    // Deduct coins
    await this.usersService.update(userId, {
      coins: user.coins - avatar.requiredCoins,
    });

    // Unlock avatar
    let userAvatar = existingUserAvatar;
    if (!userAvatar) {
      userAvatar = this.userAvatarRepository.create({
        userId,
        avatarId,
        isUnlocked: true,
        unlockedAt: new Date(),
        unlockMethod: 'coins',
        isEquipped: false,
      });
    } else {
      userAvatar.isUnlocked = true;
      userAvatar.unlockedAt = new Date();
      userAvatar.unlockMethod = 'coins';
    }

    await this.userAvatarRepository.save(userAvatar);

    return avatar;
  }

  async equipAvatar(userId: string, avatarId: string): Promise<Avatar> {
    const avatar = await this.getAvatarById(avatarId);

    // Check if user has unlocked this avatar
    const userAvatar = await this.userAvatarRepository.findOne({
      where: { userId, avatarId },
    });

    if (!userAvatar || !userAvatar.isUnlocked) {
      // Check if it's a default avatar or if user meets unlock conditions
      const user = await this.usersService.findOne(userId);
      let canEquip = false;

      if (avatar.unlockType === AvatarUnlockType.DEFAULT) {
        canEquip = true;
      } else if (avatar.unlockType === AvatarUnlockType.LEVEL && user.level >= avatar.requiredLevel) {
        canEquip = true;
      } else if (avatar.unlockType === AvatarUnlockType.VIP && user.isVip) {
        canEquip = true;
      }

      if (!canEquip) {
        throw new BadRequestException('Avatar is not unlocked. Unlock it first to equip.');
      }

      // Auto-unlock if conditions are met
      if (!userAvatar) {
        const newUserAvatar = this.userAvatarRepository.create({
          userId,
          avatarId,
          isUnlocked: true,
          unlockedAt: new Date(),
          unlockMethod: avatar.unlockType,
          isEquipped: false,
        });
        await this.userAvatarRepository.save(newUserAvatar);
      }
    }

    // Unequip all other avatars
    await this.userAvatarRepository.update(
      { userId, isEquipped: true },
      { isEquipped: false },
    );

    // Equip this avatar
    if (userAvatar) {
      userAvatar.isEquipped = true;
      await this.userAvatarRepository.save(userAvatar);
    } else {
      const newUserAvatar = this.userAvatarRepository.create({
        userId,
        avatarId,
        isUnlocked: true,
        unlockedAt: new Date(),
        unlockMethod: avatar.unlockType,
        isEquipped: true,
      });
      await this.userAvatarRepository.save(newUserAvatar);
    }

    // Update user's avatarUrl
    await this.usersService.update(userId, {
      avatarUrl: avatar.imageUrl,
    });

    return avatar;
  }

  async createAvatar(avatarData: Partial<Avatar>): Promise<Avatar> {
    const avatar = this.avatarRepository.create(avatarData);
    return await this.avatarRepository.save(avatar);
  }

  async updateAvatar(id: string, avatarData: Partial<Avatar>): Promise<Avatar> {
    await this.getAvatarById(id);
    await this.avatarRepository.update(id, avatarData);
    return this.getAvatarById(id);
  }

  async deleteAvatar(id: string): Promise<void> {
    await this.getAvatarById(id);
    await this.avatarRepository.update(id, { isActive: false });
  }

  async seedDefaultAvatars(): Promise<void> {
    const defaultAvatars = [
      {
        name: 'Classic',
        imageUrl: 'assets/avatars/classic.png',
        thumbnailUrl: 'assets/avatars/classic_thumb.png',
        description: 'The classic football avatar',
        unlockType: AvatarUnlockType.DEFAULT,
        requiredLevel: 1,
        requiredCoins: 0,
        rarity: 0,
        sortOrder: 1,
      },
      {
        name: 'Neon Blaze',
        imageUrl: 'assets/avatars/neon_blaze.png',
        thumbnailUrl: 'assets/avatars/neon_blaze_thumb.png',
        description: 'Unlock at level 5',
        unlockType: AvatarUnlockType.LEVEL,
        requiredLevel: 5,
        requiredCoins: 0,
        rarity: 1,
        sortOrder: 2,
      },
      {
        name: 'Kings Gold',
        imageUrl: 'assets/avatars/kings_gold.png',
        thumbnailUrl: 'assets/avatars/kings_gold_thumb.png',
        description: 'Unlock at level 10',
        unlockType: AvatarUnlockType.LEVEL,
        requiredLevel: 10,
        requiredCoins: 0,
        rarity: 2,
        sortOrder: 3,
      },
      {
        name: 'Galaxy',
        imageUrl: 'assets/avatars/galaxy.png',
        thumbnailUrl: 'assets/avatars/galaxy_thumb.png',
        description: 'Unlock at level 15',
        unlockType: AvatarUnlockType.LEVEL,
        requiredLevel: 15,
        requiredCoins: 0,
        rarity: 2,
        sortOrder: 4,
      },
      {
        name: 'Legendary',
        imageUrl: 'assets/avatars/legendary.png',
        thumbnailUrl: 'assets/avatars/legendary_thumb.png',
        description: 'VIP exclusive avatar',
        unlockType: AvatarUnlockType.VIP,
        requiredLevel: 20,
        requiredCoins: 0,
        rarity: 3,
        sortOrder: 5,
      },
      {
        name: 'Champion',
        imageUrl: 'assets/avatars/champion.png',
        thumbnailUrl: 'assets/avatars/champion_thumb.png',
        description: 'Purchase with 500 coins',
        unlockType: AvatarUnlockType.COINS,
        requiredLevel: 1,
        requiredCoins: 500,
        rarity: 2,
        sortOrder: 6,
      },
      {
        name: 'Elite',
        imageUrl: 'assets/avatars/elite.png',
        thumbnailUrl: 'assets/avatars/elite_thumb.png',
        description: 'Purchase with 1000 coins',
        unlockType: AvatarUnlockType.COINS,
        requiredLevel: 1,
        requiredCoins: 1000,
        rarity: 3,
        sortOrder: 7,
      },
    ];

    for (const avatarData of defaultAvatars) {
      const existing = await this.avatarRepository.findOne({
        where: { name: avatarData.name },
      });

      if (!existing) {
        await this.createAvatar(avatarData);
      }
    }
  }
}

