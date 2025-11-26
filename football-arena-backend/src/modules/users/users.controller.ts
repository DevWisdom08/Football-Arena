import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get('leaderboard')
  getLeaderboard(
    @Query('limit') limit?: number,
    @Query('type') type?: 'global' | 'friends' | 'monthly',
    @Query('filter') filter?: 'daily' | 'weekly' | 'monthly' | 'alltime',
    @Query('userId') userId?: string,
  ) {
    return this.usersService.getLeaderboard(
      limit || 50,
      type || 'global',
      filter || 'alltime',
      userId,
    );
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }

  @Post(':id/coins/spend')
  spendCoins(
    @Param('id') id: string,
    @Body() body: { amount: number; reason: string },
  ) {
    return this.usersService.spendCoins(id, body.amount, body.reason);
  }

  @Post(':id/coins/add')
  addCoins(
    @Param('id') id: string,
    @Body() body: { amount: number; reason: string },
  ) {
    return this.usersService.addCoins(id, body.amount, body.reason);
  }

  @Post(':id/xp/add')
  addXP(
    @Param('id') id: string,
    @Body() body: { amount: number; reason: string },
  ) {
    return this.usersService.addXP(id, body.amount, body.reason);
  }

  @Get(':id/vip-status')
  getVipStatus(@Param('id') id: string) {
    return this.usersService.getVipStatus(id);
  }

  @Get('search')
  searchUsers(@Query('q') query: string, @Query('limit') limit?: number) {
    return this.usersService.searchUsers(query, limit ? +limit : 10);
  }
}
