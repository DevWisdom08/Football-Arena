import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('withdrawal_requests')
export class WithdrawalRequest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  amount: number; // Amount in withdrawable coins

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amountInUSD: number; // Amount in USD (1000 coins = $1)

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  withdrawalFee: number; // Fee charged

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  netAmount: number; // Amount user receives after fee

  @Column({ length: 50, default: 'pending' })
  status: string; // pending, approved, processing, completed, rejected, cancelled

  @Column({ length: 50 })
  withdrawalMethod: string; // paypal, bank_transfer, mobile_money, crypto

  @Column({ type: 'json' })
  paymentDetails: any; // Store payment details (email, bank account, wallet address, etc.)

  @Column({ type: 'text', nullable: true })
  rejectionReason: string;

  @Column({ type: 'uuid', nullable: true })
  processedBy: string; // Admin who processed the request

  @Column({ nullable: true })
  processedAt: Date;

  @Column({ nullable: true })
  completedAt: Date;

  @Column({ length: 255, nullable: true })
  transactionId: string; // External payment transaction ID

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

