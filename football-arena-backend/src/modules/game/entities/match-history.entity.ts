import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum GameMode {
  SOLO = 'solo',
  CHALLENGE_1V1 = '1v1',
  TEAM_MATCH = 'team',
  DAILY_QUIZ = 'daily',
}

export enum MatchResult {
  WIN = 'win',
  LOSE = 'lose',
  DRAW = 'draw',
}

@Entity('match_history')
export class MatchHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({
    type: 'enum',
    enum: GameMode,
  })
  gameMode: GameMode;

  @Column({
    type: 'enum',
    enum: MatchResult,
    nullable: true,
  })
  result: MatchResult;

  @Column({ default: 0 })
  score: number;

  @Column({ default: 0 })
  correctAnswers: number;

  @Column({ default: 0 })
  totalQuestions: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  accuracy: number;

  @Column({ default: 0 })
  xpGained: number;

  @Column({ default: 0 })
  coinsGained: number;

  @Column({ nullable: true })
  opponentId: string;

  @Column({ nullable: true })
  opponentUsername: string;

  @Column({ nullable: true })
  roomId: string;

  @Column({ type: 'jsonb', nullable: true })
  teamData: any;

  @Column({ type: 'int', nullable: true })
  duration: number; // in seconds

  @CreateDateColumn()
  playedAt: Date;
}

