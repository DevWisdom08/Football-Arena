import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('transaction_history')
export class TransactionHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 50 })
  type: string; // 'earned_stake_match', 'purchased', 'spent_store', 'withdrawal', 'commission', 'reward', 'refund'

  @Column()
  amount: number; // Positive for credits, negative for debits

  @Column({ length: 50 })
  coinType: string; // 'withdrawable', 'purchased', 'both'

  @Column()
  balanceBefore: number;

  @Column()
  balanceAfter: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'uuid', nullable: true })
  relatedEntityId: string; // ID of related stake match, purchase, withdrawal, etc.

  @Column({ length: 50, nullable: true })
  relatedEntityType: string; // 'stake_match', 'withdrawal', 'purchase', 'store_item'

  @CreateDateColumn()
  createdAt: Date;
}

