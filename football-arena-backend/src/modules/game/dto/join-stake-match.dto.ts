import { IsUUID } from 'class-validator';

export class JoinStakeMatchDto {
  @IsUUID()
  matchId: string;
}

