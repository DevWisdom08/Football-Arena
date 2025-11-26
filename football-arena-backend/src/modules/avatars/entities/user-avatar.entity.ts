import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Avatar } from './avatar.entity';

@Entity('user_avatars')
export class UserAvatar {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  avatarId: string;

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

  @ManyToOne(() => Avatar)
  @JoinColumn({ name: 'avatarId' })
  avatar: Avatar;
}

