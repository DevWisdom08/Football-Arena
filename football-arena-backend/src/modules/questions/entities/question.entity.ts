import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum QuestionType {
  MULTIPLE_CHOICE = 'multipleChoice',
  TRUE_FALSE = 'trueFalse',
  IMAGE_BASED = 'imageBased',
  MEDIA_BASED = 'mediaBased',
}

export enum QuestionDifficulty {
  EASY = 'easy',
  MEDIUM = 'medium',
  HARD = 'hard',
}

@Entity('questions')
export class Question {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'text' })
  text: string;

  @Column({ type: 'text', nullable: true })
  textAr: string;

  @Column({
    type: 'enum',
    enum: QuestionType,
    default: QuestionType.MULTIPLE_CHOICE,
  })
  type: QuestionType;

  @Column({ type: 'jsonb' })
  options: string[];

  @Column({ type: 'jsonb', nullable: true })
  optionsAr: string[];

  @Column({ length: 255 })
  correctAnswer: string;

  @Column({
    type: 'enum',
    enum: QuestionDifficulty,
    default: QuestionDifficulty.MEDIUM,
  })
  difficulty: QuestionDifficulty;

  @Column('text', { array: true, default: '{}' })
  categories: string[];

  @Column({ length: 500, nullable: true })
  imageUrl: string;

  @Column({ length: 500, nullable: true })
  videoUrl: string;

  @Column({ type: 'text', nullable: true })
  explanation: string;

  @Column({ type: 'text', nullable: true })
  explanationAr: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
