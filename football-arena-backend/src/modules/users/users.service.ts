import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual, Between, In } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { MatchHistory } from '../game/entities/match-history.entity';
import { Friendship } from '../friends/entities/friend.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(MatchHistory)
    private matchHistoryRepository: Repository<MatchHistory>,
    @InjectRepository(Friendship)
    private friendshipRepository: Repository<Friendship>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(createUserDto);
    return await this.usersRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    const users = await this.usersRepository.find({
      order: { xp: 'DESC' },
      take: 100,
    });
    // Validate VIP status for all users
    for (const user of users) {
      await this.validateVipStatus(user);
    }
    return users;
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    // Validate VIP status before returning
    await this.validateVipStatus(user);
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    const user = await this.usersRepository.findOne({ where: { email } });
    if (user) {
      await this.validateVipStatus(user);
    }
    return user;
  }

  async findBySocialEmail(socialEmail: string): Promise<User | null> {
    const user = await this.usersRepository.findOne({ 
      where: { socialEmail } 
    });
    if (user) {
      await this.validateVipStatus(user);
    }
    return user;
  }

  async findByAppleId(appleId: string): Promise<User | null> {
    const user = await this.usersRepository.findOne({ where: { appleId } });
    if (user) {
      await this.validateVipStatus(user);
    }
    return user;
  }

  async findByGoogleId(googleId: string): Promise<User | null> {
    const user = await this.usersRepository.findOne({ where: { googleId } });
    if (user) {
      await this.validateVipStatus(user);
    }
    return user;
  }

  async searchUsers(query: string, limit: number = 10): Promise<User[]> {
    const users = await this.usersRepository
      .createQueryBuilder('user')
      .where('user.username ILIKE :query OR user.email ILIKE :query', {
        query: `%${query}%`,
      })
      .take(limit)
      .getMany();

    // Validate VIP status for all users
    for (const user of users) {
      await this.validateVipStatus(user);
    }
    return users;
  }

  /**
   * Validates and updates VIP status based on expiry date
   */
  async validateVipStatus(user: User): Promise<void> {
    if (!user.isVip) return;

    // If no expiry date, it's lifetime VIP - always valid
    if (!user.vipExpiryDate) return;

    // Check if VIP has expired
    const now = new Date();
    if (new Date(user.vipExpiryDate) < now) {
      // VIP expired - update user
      const updateData: any = {
        isVip: false,
      };
      updateData.vipExpiryDate = null;
      await this.usersRepository.update(user.id, updateData);
    }
  }

  /**
   * Get VIP status information for a user
   */
  async getVipStatus(userId: string): Promise<{
    isVip: boolean;
    isActive: boolean;
    vipExpiryDate: Date | null;
    daysRemaining: number | null;
    isLifetime: boolean;
  }> {
    const user = await this.findOne(userId);
    
    const isLifetime = user.isVip && !user.vipExpiryDate;
    let daysRemaining: number | null = null;
    let isActive = user.isVip;

    if (user.isVip && user.vipExpiryDate) {
      const now = new Date();
      const expiry = new Date(user.vipExpiryDate);
      const diffTime = expiry.getTime() - now.getTime();
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
      
      if (diffDays > 0) {
        daysRemaining = diffDays;
        isActive = true;
      } else {
        // Expired - update status
        const updateData: any = {
          isVip: false,
        };
        updateData.vipExpiryDate = null;
        await this.usersRepository.update(userId, updateData);
        isActive = false;
      }
    }

    return {
      isVip: user.isVip,
      isActive,
      vipExpiryDate: user.vipExpiryDate,
      daysRemaining,
      isLifetime,
    };
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    await this.findOne(id);
    await this.usersRepository.update(id, updateUserDto);
    const updatedUser = await this.findOne(id);
    
    // Auto-check avatar unlocks after user update (if avatars module is available)
    // This will be called by AvatarsService when needed
    return updatedUser;
  }

  async uploadAvatar(id: string, file: Express.Multer.File): Promise<User> {
    const user = await this.findOne(id);
    
    // Convert image to base64
    const base64Image = `data:${file.mimetype};base64,${file.buffer.toString('base64')}`;
    
    // Store base64 string in avatarUrl field
    user.avatarUrl = base64Image;
    
    await this.usersRepository.save(user);
    
    return user;
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.usersRepository.remove(user);
  }

  async getLeaderboard(
    limit: number = 50,
    type: 'global' | 'friends' | 'monthly' = 'global',
    filter: 'daily' | 'weekly' | 'monthly' | 'alltime' = 'alltime',
    userId?: string,
  ): Promise<any[]> {
    const now = new Date();
    let startDate: Date | null = null;

    // Calculate filter date range
    if (filter === 'daily') {
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else if (filter === 'weekly') {
      const dayOfWeek = now.getDay();
      startDate = new Date(now);
      startDate.setDate(now.getDate() - dayOfWeek);
      startDate.setHours(0, 0, 0, 0);
    } else if (filter === 'monthly') {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    if (type === 'friends' && userId) {
      // Get friends leaderboard
      const friendships = await this.friendshipRepository.find({
        where: [{ user1Id: userId }, { user2Id: userId }],
      });

      const friendIds = friendships.map(f => 
        f.user1Id === userId ? f.user2Id : f.user1Id
      );
      friendIds.push(userId); // Include current user

      let query = this.usersRepository
        .createQueryBuilder('user')
        .where('user.id IN (:...friendIds)', { friendIds })
        .andWhere('user.isGuest = false')
        .orderBy('user.xp', 'DESC')
        .limit(limit);

      if (startDate && filter !== 'alltime') {
        // For time-filtered friends leaderboard, we need to calculate XP gained in period
        // This is a simplified version - in production, you'd track XP changes
        query = query.andWhere('user.updatedAt >= :startDate', { startDate });
      }

      const users = await query.getMany();
      return users.map((user, index) => ({
        ...user,
        rank: index + 1,
      }));
    } else if (type === 'monthly') {
      // Monthly Challenges Leaderboard - based on match performance this month
      const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
      
      const matchStats = await this.matchHistoryRepository
        .createQueryBuilder('match')
        .select('match.userId', 'userId')
        .addSelect('SUM(match.xpGained)', 'totalXP')
        .addSelect('SUM(match.score)', 'totalScore')
        .addSelect('COUNT(match.id)', 'matchesPlayed')
        .where('match.playedAt >= :monthStart', { monthStart })
        .groupBy('match.userId')
        .orderBy('totalXP', 'DESC')
        .addOrderBy('totalScore', 'DESC')
        .limit(limit)
        .getRawMany();

      const userIds = matchStats.map(stat => stat.userId);
      const users = userIds.length > 0 
        ? await this.usersRepository.find({ where: { id: In(userIds) } })
        : [];

      return matchStats.map((stat, index) => {
        const user = users.find(u => u.id === stat.userId);
        return {
          ...user,
          rank: index + 1,
          monthlyXP: parseInt(stat.totalXP) || 0,
          monthlyScore: parseInt(stat.totalScore) || 0,
          monthlyMatches: parseInt(stat.matchesPlayed) || 0,
        };
      });
    } else {
      // Global leaderboard
      let query = this.usersRepository
        .createQueryBuilder('user')
        .where('user.isGuest = false')
        .orderBy('user.xp', 'DESC')
        .limit(limit);

      if (startDate && filter !== 'alltime') {
        // For time-filtered, use updatedAt as proxy (in production, track XP changes)
        query = query.andWhere('user.updatedAt >= :startDate', { startDate });
      }

      const users = await query.getMany();
      return users.map((user, index) => ({
        ...user,
        rank: index + 1,
      }));
    }
  }

  async spendCoins(userId: string, amount: number, reason: string): Promise<User> {
    const user = await this.findOne(userId);
    if (user.coins < amount) {
      throw new Error('Insufficient coins');
    }
    await this.usersRepository.update(userId, {
      coins: user.coins - amount,
    });
    return this.findOne(userId);
  }

  async addCoins(userId: string, amount: number, reason: string): Promise<User> {
    const user = await this.findOne(userId);
    await this.usersRepository.update(userId, {
      coins: user.coins + amount,
    });
    return this.findOne(userId);
  }

  async addXP(userId: string, amount: number, reason: string): Promise<{ user: User; leveledUp: boolean; levelUpReward: number }> {
    const user = await this.findOne(userId);
    const oldLevel = user.level;
    const newXP = user.xp + amount;
    const newLevel = Math.floor(newXP / 1000) + 1;
    
    let levelUpReward = 0;
    if (newLevel > oldLevel) {
      levelUpReward = newLevel * 10; // 10 coins per level
      await this.usersRepository.update(userId, {
        xp: newXP,
        level: newLevel,
        coins: user.coins + levelUpReward,
      });
    } else {
      await this.usersRepository.update(userId, {
        xp: newXP,
      });
    }
    
    const updatedUser = await this.findOne(userId);
    return {
      user: updatedUser,
      leveledUp: newLevel > oldLevel,
      levelUpReward,
    };
  }
}
