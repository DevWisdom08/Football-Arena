import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('daily_quiz_schedules')
export class DailyQuizSchedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'date' })
  scheduledDate: Date;

  @Column({ type: 'time', nullable: true })
  scheduledTime: string; // HH:mm format

  @Column({ default: 15 })
  questionCount: number;

  @Column({ type: 'simple-array', nullable: true })
  categoryFilters: string[]; // Optional category filters

  @Column({ type: 'simple-array', nullable: true })
  difficultyFilters: string[]; // Optional difficulty filters

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

