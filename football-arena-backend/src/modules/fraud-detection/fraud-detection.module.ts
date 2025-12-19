import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FraudDetectionService } from './fraud-detection.service';
import { FraudDetectionController } from './fraud-detection.controller';
import { FraudAlert } from './entities/fraud-alert.entity';
import { User } from '../users/entities/user.entity';
import { TransactionHistory } from '../users/entities/transaction-history.entity';
import { WithdrawalRequest } from '../users/entities/withdrawal-request.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([FraudAlert, User, TransactionHistory, WithdrawalRequest]),
  ],
  controllers: [FraudDetectionController],
  providers: [FraudDetectionService],
  exports: [FraudDetectionService],
})
export class FraudDetectionModule {}

