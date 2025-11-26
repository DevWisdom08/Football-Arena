import { PartialType } from '@nestjs/swagger';
import { CreateUserDto } from './create-user.dto';
import { IsString, IsNumber, IsBoolean, IsOptional, IsArray, IsDate } from 'class-validator';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  @IsOptional()
  @IsNumber()
  level?: number;

  @IsOptional()
  @IsNumber()
  xp?: number;

  @IsOptional()
  @IsNumber()
  coins?: number;

  @IsOptional()
  @IsNumber()
  withdrawableCoins?: number;

  @IsOptional()
  @IsNumber()
  purchasedCoins?: number;

  @IsOptional()
  @IsNumber()
  totalGames?: number;

  @IsOptional()
  @IsNumber()
  soloGamesPlayed?: number;

  @IsOptional()
  @IsNumber()
  challenge1v1Played?: number;

  @IsOptional()
  @IsNumber()
  teamMatchesPlayed?: number;

  @IsOptional()
  @IsNumber()
  accuracyRate?: number;

  @IsOptional()
  @IsNumber()
  winRate?: number;

  @IsOptional()
  @IsNumber()
  currentStreak?: number;

  @IsOptional()
  @IsNumber()
  longestStreak?: number;

  @IsOptional()
  @IsBoolean()
  isVip?: boolean;

  @IsOptional()
  vipExpiryDate?: Date;

  @IsOptional()
  @IsNumber()
  commissionRate?: number;

  @IsOptional()
  @IsBoolean()
  kycVerified?: boolean;

  @IsOptional()
  @IsString()
  kycFullName?: string;

  @IsOptional()
  kycDateOfBirth?: Date;

  @IsOptional()
  @IsString()
  kycIdNumber?: string;

  @IsOptional()
  @IsString()
  kycIdPhotoUrl?: string;

  @IsOptional()
  @IsString()
  kycSelfieUrl?: string;

  @IsOptional()
  @IsString()
  kycStatus?: string;

  @IsOptional()
  @IsArray()
  badges?: string[];

  @IsOptional()
  lastPlayedAt?: Date;

  @IsOptional()
  @IsString()
  socialEmail?: string;
}
