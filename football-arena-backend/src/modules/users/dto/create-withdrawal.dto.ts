import { IsNumber, IsString, IsObject, Min } from 'class-validator';

export class CreateWithdrawalDto {
  @IsNumber()
  @Min(10000) // Minimum withdrawal: 10,000 coins = $10
  amount: number;

  @IsString()
  withdrawalMethod: string; // paypal, bank_transfer, mobile_money, crypto

  @IsObject()
  paymentDetails: any; // { email, accountNumber, walletAddress, etc. }
}

