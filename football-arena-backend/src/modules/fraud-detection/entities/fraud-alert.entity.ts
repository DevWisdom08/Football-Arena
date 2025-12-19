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

export enum FraudAlertType {
  MULTIPLE_ACCOUNTS = 'multiple_accounts',
  SUSPICIOUS_WITHDRAWAL = 'suspicious_withdrawal',
  RAPID_BETTING = 'rapid_betting',
  WIN_RATE_ANOMALY = 'win_rate_anomaly',
  UNUSUAL_ACTIVITY = 'unusual_activity',
  LARGE_TRANSACTION = 'large_transaction',
  CHARGEBACK_RISK = 'chargeback_risk',
  VPN_USAGE = 'vpn_usage',
  ACCOUNT_TAKEOVER = 'account_takeover',
}

export enum FraudAlertSeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export enum FraudAlertStatus {
  PENDING = 'pending',
  REVIEWING = 'reviewing',
  RESOLVED = 'resolved',
  FALSE_POSITIVE = 'false_positive',
  CONFIRMED = 'confirmed',
}

@Entity('fraud_alerts')
export class FraudAlert {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({
    type: 'enum',
    enum: FraudAlertType,
  })
  type: FraudAlertType;

  @Column({
    type: 'enum',
    enum: FraudAlertSeverity,
    default: FraudAlertSeverity.LOW,
  })
  severity: FraudAlertSeverity;

  @Column({
    type: 'enum',
    enum: FraudAlertStatus,
    default: FraudAlertStatus.PENDING,
  })
  status: FraudAlertStatus;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: any;

  @Column({ nullable: true })
  reviewedBy: string;

  @Column({ type: 'timestamp', nullable: true })
  reviewedAt: Date;

  @Column({ type: 'text', nullable: true })
  reviewNotes: string;

  @Column({ default: false })
  actionTaken: boolean;

  @Column({ type: 'text', nullable: true })
  actionDescription: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

