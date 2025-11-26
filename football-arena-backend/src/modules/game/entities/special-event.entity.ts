import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('special_events')
export class SpecialEvent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({
    type: 'enum',
    enum: ['doubleXP', 'doubleCoins', 'bonusReward', 'weekendBonus'],
  })
  type: string;

  @Column({ type: 'timestamp' })
  startDate: Date;

  @Column({ type: 'timestamp' })
  endDate: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 1.0 })
  xpMultiplier: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 1.0 })
  coinsMultiplier: number;

  @Column({ default: 0 })
  bonusCoins: number;

  @Column({ default: 0 })
  bonusXp: number;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

