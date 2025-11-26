import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum AvatarUnlockType {
  DEFAULT = 'default', // Always unlocked
  LEVEL = 'level', // Unlocked by reaching a level
  VIP = 'vip', // Unlocked by VIP membership
  COINS = 'coins', // Unlocked by purchasing with coins
  ACHIEVEMENT = 'achievement', // Unlocked by achievement
  SPECIAL = 'special', // Special event or admin-granted
}

@Entity('avatars')
export class Avatar {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100, unique: true })
  name: string;

  @Column({ length: 500 })
  imageUrl: string;

  @Column({ length: 500, nullable: true })
  thumbnailUrl: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: AvatarUnlockType,
    default: AvatarUnlockType.DEFAULT,
  })
  unlockType: AvatarUnlockType;

  @Column({ default: 1 })
  requiredLevel: number; // For LEVEL unlock type

  @Column({ default: 0 })
  requiredCoins: number; // For COINS unlock type

  @Column({ length: 100, nullable: true })
  requiredAchievement: string; // For ACHIEVEMENT unlock type

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 0 })
  rarity: number; // 0 = common, 1 = rare, 2 = epic, 3 = legendary

  @Column({ default: 0 })
  sortOrder: number; // For display ordering

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

