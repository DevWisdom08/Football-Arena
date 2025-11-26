import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('daily_quiz_attempts')
export class DailyQuizAttempt {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'date' })
  quizDate: Date;

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

  @Column({ default: false })
  bonusRewardClaimed: boolean;

  @Column({ type: 'jsonb', nullable: true })
  answers: any[];

  @CreateDateColumn()
  completedAt: Date;
}

