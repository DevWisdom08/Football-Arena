import { IsUUID, IsNumber, Min, Max } from 'class-validator';

export class CompleteStakeMatchDto {
  @IsUUID()
  matchId: string;

  @IsNumber()
  @Min(0)
  creatorScore: number;

  @IsNumber()
  @Min(0)
  opponentScore: number;
}

