import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum UnlockableItemType {
  AVATAR = 'avatar',
  BANNER = 'banner',
  ANIMATION = 'animation',
  TITLE = 'title',
  EVENT_ACCESS = 'event_access',
  FEATURE = 'feature',
  BADGE = 'badge',
  THEME = 'theme',
}

export enum UnlockMethod {
  LEVEL = 'level',
  VIP = 'vip',
  COINS = 'coins',
  ACHIEVEMENT = 'achievement',
  PURCHASE = 'purchase',
  SPECIAL = 'special',
}

@Entity('unlockable_items')
export class UnlockableItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100, unique: true })
  name: string;

  @Column({ length: 500 })
  description: string;

  @Column({
    type: 'enum',
    enum: UnlockableItemType,
  })
  itemType: UnlockableItemType;

  @Column({
    type: 'enum',
    enum: UnlockMethod,
    default: UnlockMethod.LEVEL,
  })
  unlockMethod: UnlockMethod;

  @Column({ default: 1 })
  requiredLevel: number;

  @Column({ default: false })
  requiresVip: boolean;

  @Column({ default: 0 })
  requiredCoins: number;

  @Column({ length: 100, nullable: true })
  requiredAchievement: string;

  @Column({ length: 500, nullable: true })
  imageUrl: string;

  @Column({ length: 500, nullable: true })
  thumbnailUrl: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: any; // For item-specific data (e.g., animation config, event details)

  @Column({ default: 0 })
  rarity: number; // 0 = common, 1 = rare, 2 = epic, 3 = legendary

  @Column({ default: 0 })
  sortOrder: number;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

