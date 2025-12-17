import { IsNumber, IsString, Min } from 'class-validator';

export class AddCoinsDto {
  @IsNumber()
  @Min(1)
  amount: number;

  @IsString()
  reason: string;
}

