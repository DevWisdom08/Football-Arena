import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { WithdrawalService } from './withdrawal.service';
import { WithdrawalController } from './withdrawal.controller';
import { CryptoPaymentService } from './crypto-payment.service';
import { User } from './entities/user.entity';
import { WithdrawalRequest } from './entities/withdrawal-request.entity';
import { TransactionHistory } from './entities/transaction-history.entity';
import { MatchHistory } from '../game/entities/match-history.entity';
import { Friendship } from '../friends/entities/friend.entity';
import { FraudDetectionModule } from '../fraud-detection/fraud-detection.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      WithdrawalRequest,
      TransactionHistory,
      MatchHistory,
      Friendship,
    ]),
    forwardRef(() => FraudDetectionModule),
  ],
  controllers: [UsersController, WithdrawalController],
  providers: [UsersService, WithdrawalService, CryptoPaymentService],
  exports: [UsersService, WithdrawalService, CryptoPaymentService],
})
export class UsersModule {}
