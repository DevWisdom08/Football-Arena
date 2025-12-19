import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
  Query,
  Delete,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { StakeMatchService } from './stake-match.service';
import { CreateStakeMatchDto } from './dto/create-stake-match.dto';
import { JoinStakeMatchDto } from './dto/join-stake-match.dto';
import { CompleteStakeMatchDto } from './dto/complete-stake-match.dto';

@Controller('stake-matches')
export class StakeMatchController {
  constructor(private readonly stakeMatchService: StakeMatchService) {}

  /**
   * Create a new stake match
   */
  @Post()
  @Throttle({ limit: 10, ttl: 60000 }) // 10 stake match creations per minute
  async createStakeMatch(
    @Request() req,
    @Body() createDto: CreateStakeMatchDto,
  ) {
    const userId = req.user?.id || req.body.userId; // Support both auth and direct userId
    return await this.stakeMatchService.createStakeMatch(userId, createDto);
  }

  /**
   * Get all available stake matches
   */
  @Get('available')
  async getAvailableMatches(@Query('limit') limit?: number) {
    return await this.stakeMatchService.getAvailableMatches(limit || 20);
  }

  /**
   * Get user's stake match history
   */
  @Get('user/:userId')
  async getUserMatches(@Param('userId') userId: string) {
    return await this.stakeMatchService.getUserStakeMatches(userId);
  }

  /**
   * Get stake match by ID
   */
  @Get(':id')
  async getStakeMatch(@Param('id') id: string) {
    return await this.stakeMatchService.getStakeMatchById(id);
  }

  /**
   * Join a stake match
   */
  @Post(':id/join')
  async joinStakeMatch(
    @Param('id') matchId: string,
    @Request() req,
    @Body() body?: { userId?: string },
  ) {
    const userId = req.user?.id || body?.userId;
    if (!userId) {
      throw new Error('User ID is required');
    }
    return await this.stakeMatchService.joinStakeMatch(userId, matchId);
  }

  /**
   * Complete a stake match
   */
  @Post('complete')
  async completeStakeMatch(@Body() completeDto: CompleteStakeMatchDto) {
    return await this.stakeMatchService.completeStakeMatch(
      completeDto.matchId,
      completeDto.userId,
      completeDto.score,
    );
  }

  /**
   * Cancel a stake match
   */
  @Delete(':id')
  async cancelStakeMatch(
    @Param('id') id: string,
    @Request() req,
  ) {
    const userId = req.user?.id || req.body.userId;
    return await this.stakeMatchService.cancelStakeMatch(id, userId);
  }
}

