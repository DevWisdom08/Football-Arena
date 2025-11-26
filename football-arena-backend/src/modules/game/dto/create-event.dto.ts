export class CreateEventDto {
  name: string;
  description: string;
  type: 'doubleXP' | 'doubleCoins' | 'bonusReward' | 'weekendBonus';
  startDate: Date;
  endDate: Date;
  xpMultiplier?: number;
  coinsMultiplier?: number;
  bonusCoins?: number;
  bonusXp?: number;
  isActive: boolean;
}

export class CreateTournamentDto {
  name: string;
  description: string;
  entryFee: number;
  prizePool: number;
  startDate: Date;
  endDate: Date;
  maxParticipants: number;
  gameMode: 'solo' | '1v1' | 'team';
  questionsCount: number;
}

