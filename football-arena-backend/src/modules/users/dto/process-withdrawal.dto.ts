import { IsUUID, IsString, IsOptional } from 'class-validator';

export class ProcessWithdrawalDto {
  @IsUUID()
  withdrawalId: string;

  @IsString()
  action: string; // approve, reject

  @IsString()
  @IsOptional()
  rejectionReason?: string;

  @IsString()
  @IsOptional()
  transactionId?: string; // External payment transaction ID
}

