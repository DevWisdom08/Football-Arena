import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { AvatarsService } from './avatars.service';
import { Avatar } from './entities/avatar.entity';
import { UserAvatar } from './entities/user-avatar.entity';

@Controller('avatars')
export class AvatarsController {
  constructor(private readonly avatarsService: AvatarsService) {}

  @Get()
  getAllAvatars(): Promise<Avatar[]> {
    return this.avatarsService.getAllAvatars();
  }

  @Get(':id')
  getAvatarById(@Param('id') id: string): Promise<Avatar> {
    return this.avatarsService.getAvatarById(id);
  }

  @Get('user/:userId')
  getUserAvatars(@Param('userId') userId: string): Promise<UserAvatar[]> {
    return this.avatarsService.getUserAvatars(userId);
  }

  @Get('user/:userId/unlocked')
  getUserUnlockedAvatars(@Param('userId') userId: string): Promise<Avatar[]> {
    return this.avatarsService.getUserUnlockedAvatars(userId);
  }

  @Get('user/:userId/equipped')
  getEquippedAvatar(@Param('userId') userId: string): Promise<Avatar | null> {
    return this.avatarsService.getEquippedAvatar(userId);
  }

  @Post('user/:userId/check-unlocks')
  checkAndUnlockAvatars(@Param('userId') userId: string): Promise<Avatar[]> {
    return this.avatarsService.checkAndUnlockAvatars(userId);
  }

  @Post('user/:userId/unlock/:avatarId')
  unlockAvatarWithCoins(
    @Param('userId') userId: string,
    @Param('avatarId') avatarId: string,
  ): Promise<Avatar> {
    return this.avatarsService.unlockAvatarWithCoins(userId, avatarId);
  }

  @Post('user/:userId/equip/:avatarId')
  equipAvatar(
    @Param('userId') userId: string,
    @Param('avatarId') avatarId: string,
  ): Promise<Avatar> {
    return this.avatarsService.equipAvatar(userId, avatarId);
  }

  // Admin endpoints
  @Post()
  createAvatar(@Body() avatarData: Partial<Avatar>): Promise<Avatar> {
    return this.avatarsService.createAvatar(avatarData);
  }

  @Patch(':id')
  updateAvatar(
    @Param('id') id: string,
    @Body() avatarData: Partial<Avatar>,
  ): Promise<Avatar> {
    return this.avatarsService.updateAvatar(id, avatarData);
  }

  @Delete(':id')
  deleteAvatar(@Param('id') id: string): Promise<{ message: string }> {
    return this.avatarsService.deleteAvatar(id).then(() => ({
      message: 'Avatar deleted successfully',
    }));
  }

  @Post('seed')
  seedDefaultAvatars(): Promise<{ message: string }> {
    return this.avatarsService.seedDefaultAvatars().then(() => ({
      message: 'Default avatars seeded successfully',
    }));
  }
}

