import { IsNumber, IsString, IsOptional, Min, Max } from 'class-validator';

export class CreateStakeMatchDto {
  @IsNumber()
  @Min(100)
  stakeAmount: number; // Minimum stake: 100 coins

  @IsString()
  @IsOptional()
  difficulty?: string; // easy, medium, hard, mixed

  @IsNumber()
  @IsOptional()
  @Min(5)
  @Max(20)
  numberOfQuestions?: number; // Default: 10
}

