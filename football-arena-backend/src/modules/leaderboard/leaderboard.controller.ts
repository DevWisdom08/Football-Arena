import { Controller, Get, Query } from '@nestjs/common';
import { UsersService } from '../users/users.service';

@Controller('leaderboard')
export class LeaderboardController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  getLeaderboard(@Query('limit') limit?: number) {
    return this.usersService.getLeaderboard(limit ? +limit : 50);
  }
}
