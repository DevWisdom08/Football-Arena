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
import { UnlocksService } from './unlocks.service';
import { UnlockableItem, UnlockableItemType } from './entities/unlockable-item.entity';

@Controller('unlocks')
export class UnlocksController {
  constructor(private readonly unlocksService: UnlocksService) {}

  @Get()
  getAllUnlockableItems(): Promise<UnlockableItem[]> {
    return this.unlocksService.getAllUnlockableItems();
  }

  @Get(':id')
  getUnlockableItemById(@Param('id') id: string): Promise<UnlockableItem> {
    return this.unlocksService.getUnlockableItemById(id);
  }

  @Get('user/:userId')
  getUserUnlocks(@Param('userId') userId: string) {
    return this.unlocksService.getUserUnlocks(userId);
  }

  @Get('user/:userId/unlocked')
  getUserUnlockedItems(@Param('userId') userId: string): Promise<UnlockableItem[]> {
    return this.unlocksService.getUserUnlockedItems(userId);
  }

  @Get('user/:userId/upcoming')
  getUpcomingUnlocks(@Param('userId') userId: string) {
    return this.unlocksService.getUpcomingUnlocks(userId);
  }

  @Get('user/:userId/type/:type')
  getUnlockedItemsByType(
    @Param('userId') userId: string,
    @Param('type') type: UnlockableItemType,
  ): Promise<UnlockableItem[]> {
    return this.unlocksService.getUnlockedItemsByType(userId, type);
  }

  @Get('level/:level')
  getItemsByLevel(@Param('level') level: number): Promise<UnlockableItem[]> {
    return this.unlocksService.getItemsByLevel(+level);
  }

  @Get('level/:level/unlocked')
  getItemsUnlockedAtLevel(@Param('level') level: number): Promise<UnlockableItem[]> {
    return this.unlocksService.getItemsUnlockedAtLevel(+level);
  }

  @Get('level/:level/next')
  getNextLevelUnlocks(
    @Param('level') level: number,
    @Query('limit') limit?: number,
  ): Promise<UnlockableItem[]> {
    return this.unlocksService.getNextLevelUnlocks(+level, limit ? +limit : 5);
  }

  @Post('user/:userId/check-unlocks')
  checkAndUnlockItems(@Param('userId') userId: string): Promise<UnlockableItem[]> {
    return this.unlocksService.checkAndUnlockItems(userId);
  }

  @Post('user/:userId/unlock/:itemId')
  unlockItemWithCoins(
    @Param('userId') userId: string,
    @Param('itemId') itemId: string,
  ): Promise<UnlockableItem> {
    return this.unlocksService.unlockItemWithCoins(userId, itemId);
  }

  // Admin endpoints
  @Post()
  createUnlockableItem(@Body() itemData: Partial<UnlockableItem>): Promise<UnlockableItem> {
    return this.unlocksService.createUnlockableItem(itemData);
  }

  @Patch(':id')
  updateUnlockableItem(
    @Param('id') id: string,
    @Body() itemData: Partial<UnlockableItem>,
  ): Promise<UnlockableItem> {
    return this.unlocksService.updateUnlockableItem(id, itemData);
  }

  @Delete(':id')
  deleteUnlockableItem(@Param('id') id: string): Promise<{ message: string }> {
    return this.unlocksService.deleteUnlockableItem(id).then(() => ({
      message: 'Unlockable item deleted successfully',
    }));
  }

  @Post('seed')
  seedDefaultItems(): Promise<{ message: string }> {
    return this.unlocksService.seedDefaultItems().then(() => ({
      message: 'Default unlockable items seeded successfully',
    }));
  }
}

