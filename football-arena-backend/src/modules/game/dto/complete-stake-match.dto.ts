import { IsUUID, IsNumber, Min, Max } from 'class-validator';

export class CompleteStakeMatchDto {
  @IsUUID()
  matchId: string;

  @IsUUID()
  userId: string;

  @IsNumber()
  @Min(0)
  score: number;
}

