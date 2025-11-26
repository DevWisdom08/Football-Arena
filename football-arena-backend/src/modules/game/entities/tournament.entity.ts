import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('tournaments')
export class Tournament {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ default: 50 })
  entryFee: number;

  @Column({ default: 500 })
  prizePool: number;

  @Column({ type: 'timestamp' })
  startDate: Date;

  @Column({ type: 'timestamp' })
  endDate: Date;

  @Column({ default: 100 })
  maxParticipants: number;

  @Column({ default: 0 })
  currentParticipants: number;

  @Column({
    type: 'enum',
    enum: ['solo', '1v1', 'team'],
    default: 'solo',
  })
  gameMode: string;

  @Column({ default: 10 })
  questionsCount: number;

  @Column({ default: true })
  isActive: boolean;

  @Column('text', { array: true, default: '{}' })
  participantIds: string[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

