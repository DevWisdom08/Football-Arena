import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  username: string;

  @Column({ length: 255, unique: true })
  email: string;

  @Column({ length: 255, nullable: true })
  passwordHash: string;

  @Column({ length: 500, nullable: true })
  avatarUrl: string;

  @Column({ length: 100 })
  country: string;

  @Column({ type: 'date', nullable: true })
  dateOfBirth: Date; // Date of birth for age verification

  @Column({ default: 1 })
  level: number;

  @Column({ default: 0 })
  xp: number;

  @Column({ default: 0 })
  coins: number;

  @Column({ default: 0 })
  withdrawableCoins: number; // Coins won from stake matches (can be withdrawn)

  @Column({ default: 0 })
  purchasedCoins: number; // Coins bought with real money (cannot be withdrawn)

  @Column({ default: 0 })
  totalGames: number;

  @Column({ default: 0 })
  soloGamesPlayed: number;

  @Column({ default: 0 })
  challenge1v1Played: number;

  @Column({ default: 0 })
  teamMatchesPlayed: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  accuracyRate: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  winRate: number;

  @Column({ default: 0 })
  currentStreak: number;

  @Column({ default: 0 })
  longestStreak: number;

  @Column({ default: false })
  isVip: boolean;

  @Column({ nullable: true })
  vipExpiryDate: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 10 })
  commissionRate: number; // Commission rate for stake matches (VIP gets reduced rate)

  @Column({ default: false })
  kycVerified: boolean; // KYC verification status

  @Column({ length: 100, nullable: true })
  kycFullName: string;

  @Column({ type: 'date', nullable: true })
  kycDateOfBirth: Date;

  @Column({ length: 20, nullable: true })
  kycIdNumber: string;

  @Column({ length: 500, nullable: true })
  kycIdPhotoUrl: string;

  @Column({ length: 500, nullable: true })
  kycSelfieUrl: string;

  @Column({ length: 50, nullable: true })
  kycStatus: string; // pending, approved, rejected

  @Column({ default: false })
  isGuest: boolean;

  @Column({ default: false })
  isAdmin: boolean;

  @Column('text', { array: true, default: '{}' })
  badges: string[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ nullable: true })
  lastPlayedAt: Date;

  @Column({ length: 255, nullable: true })
  appleId: string;

  @Column({ length: 255, nullable: true })
  googleId: string;

  @Column({ length: 500, nullable: true })
  socialEmail: string;
}
