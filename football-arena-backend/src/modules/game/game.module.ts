import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GameService } from './game.service';
import { GameController } from './game.controller';
import { GameGateway } from './game.gateway';
import { StakeMatchService } from './stake-match.service';
import { StakeMatchController } from './stake-match.controller';
import { DailyQuizAttempt } from './entities/daily-quiz.entity';
import { MatchHistory } from './entities/match-history.entity';
import { SpecialEvent } from './entities/special-event.entity';
import { Tournament } from './entities/tournament.entity';
import { StakeMatch } from './entities/stake-match.entity';
import { User } from '../users/entities/user.entity';
import { TransactionHistory } from '../users/entities/transaction-history.entity';
import { QuestionsModule } from '../questions/questions.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      DailyQuizAttempt,
      MatchHistory,
      SpecialEvent,
      Tournament,
      StakeMatch,
      User,
      TransactionHistory,
    ]),
    QuestionsModule,
    UsersModule,
  ],
  controllers: [GameController, StakeMatchController],
  providers: [GameService, GameGateway, StakeMatchService],
  exports: [GameService, GameGateway, StakeMatchService],
})
export class GameModule {}
