import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { UnlockableItem } from './unlockable-item.entity';

@Entity('user_unlocks')
export class UserUnlock {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  itemId: string;

  @Column({ default: false })
  isUnlocked: boolean;

  @Column({ nullable: true })
  unlockedAt: Date;

  @Column({ length: 50, nullable: true })
  unlockMethod: string; // 'level', 'coins', 'vip', 'achievement', etc.

  @Column({ default: false })
  isEquipped: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => UnlockableItem)
  @JoinColumn({ name: 'itemId' })
  item: UnlockableItem;
}

