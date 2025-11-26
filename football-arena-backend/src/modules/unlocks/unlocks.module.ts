import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UnlocksService } from './unlocks.service';
import { UnlocksController } from './unlocks.controller';
import { UnlockableItem } from './entities/unlockable-item.entity';
import { UserUnlock } from './entities/user-unlock.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([UnlockableItem, UserUnlock]),
    UsersModule,
  ],
  controllers: [UnlocksController],
  providers: [UnlocksService],
  exports: [UnlocksService],
})
export class UnlocksModule {}

