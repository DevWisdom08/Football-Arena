import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('stake_matches')
export class StakeMatch {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  creatorId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'creatorId' })
  creator: User;

  @Column({ type: 'uuid', nullable: true })
  opponentId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'opponentId' })
  opponent: User;

  @Column()
  stakeAmount: number; // Amount each player bets

  @Column({ default: 0 })
  totalPot: number; // Total pot (stakeAmount * 2)

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  commissionRate: number; // Commission percentage

  @Column({ default: 0 })
  commissionAmount: number; // Commission taken by platform

  @Column({ default: 0 })
  winnerPayout: number; // Amount winner receives after commission

  @Column({ length: 50, default: 'waiting' })
  status: string; // waiting, active, completed, cancelled

  @Column({ type: 'uuid', nullable: true })
  winnerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'winnerId' })
  winner: User;

  @Column({ default: 0 })
  creatorScore: number;

  @Column({ default: 0 })
  opponentScore: number;

  @Column({ default: false })
  creatorFinished: boolean;

  @Column({ default: false })
  opponentFinished: boolean;

  @Column({ type: 'jsonb', nullable: true })
  questions: any[]; // Store questions for both players to use the same set

  @Column({ length: 50, default: 'football_quiz' })
  matchType: string; // football_quiz, trivia, etc.

  @Column({ default: 10 })
  numberOfQuestions: number;

  @Column({ length: 50, nullable: true })
  difficulty: string; // easy, medium, hard, mixed

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ nullable: true })
  completedAt: Date;

  @Column({ nullable: true })
  cancelledAt: Date;

  @Column({ type: 'text', nullable: true })
  cancellationReason: string;
}

