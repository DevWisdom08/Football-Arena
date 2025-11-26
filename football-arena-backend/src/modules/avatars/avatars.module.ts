import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AvatarsService } from './avatars.service';
import { AvatarsController } from './avatars.controller';
import { Avatar } from './entities/avatar.entity';
import { UserAvatar } from './entities/user-avatar.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Avatar, UserAvatar]),
    UsersModule,
  ],
  controllers: [AvatarsController],
  providers: [AvatarsService],
  exports: [AvatarsService],
})
export class AvatarsModule {}

