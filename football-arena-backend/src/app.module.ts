import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { getDatabaseConfig } from './config/database.config';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { QuestionsModule } from './modules/questions/questions.module';
import { GameModule } from './modules/game/game.module';
import { LeaderboardModule } from './modules/leaderboard/leaderboard.module';
import { FriendsModule } from './modules/friends/friends.module';
import { AdminModule } from './modules/admin/admin.module';
import { StoreModule } from './modules/store/store.module';
import { AvatarsModule } from './modules/avatars/avatars.module';
import { UnlocksModule } from './modules/unlocks/unlocks.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: getDatabaseConfig,
      inject: [ConfigService],
    }),
    UsersModule,
    AuthModule,
    QuestionsModule,
    GameModule,
    LeaderboardModule,
    FriendsModule,
    AdminModule,
    StoreModule,
    AvatarsModule,
    UnlocksModule,
  ],
})
export class AppModule {}
