import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Request,
  Query,
  Delete,
} from '@nestjs/common';
import { WithdrawalService } from './withdrawal.service';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { SubmitKycDto } from './dto/submit-kyc.dto';
import { ProcessWithdrawalDto } from './dto/process-withdrawal.dto';

@Controller('withdrawals')
export class WithdrawalController {
  constructor(private readonly withdrawalService: WithdrawalService) {}

  /**
   * Submit KYC verification
   */
  @Post('kyc')
  async submitKyc(@Request() req, @Body() kycDto: SubmitKycDto) {
    const userId = req.user?.id || req.body.userId;
    return await this.withdrawalService.submitKyc(userId, kycDto);
  }

  /**
   * Process KYC (admin only)
   */
  @Post('kyc/process')
  async processKyc(
    @Body() body: { userId: string; approved: boolean; adminId: string },
  ) {
    return await this.withdrawalService.processKyc(
      body.userId,
      body.approved,
      body.adminId,
    );
  }

  /**
   * Create withdrawal request
   */
  @Post()
  async createWithdrawal(
    @Request() req,
    @Body() withdrawalDto: CreateWithdrawalDto,
  ) {
    const userId = req.user?.id || req.body.userId;
    return await this.withdrawalService.createWithdrawal(userId, withdrawalDto);
  }

  /**
   * Get user's withdrawals
   */
  @Get('my-withdrawals/:userId')
  async getUserWithdrawals(@Param('userId') userId: string) {
    return await this.withdrawalService.getUserWithdrawals(userId);
  }

  /**
   * Get user's transaction history
   */
  @Get('transactions/:userId')
  async getUserTransactions(@Param('userId') userId: string) {
    return await this.withdrawalService.getUserTransactions(userId);
  }

  /**
   * Get pending withdrawals (admin only)
   */
  @Get('pending')
  async getPendingWithdrawals() {
    return await this.withdrawalService.getPendingWithdrawals();
  }

  /**
   * Get all withdrawals (admin only)
   */
  @Get('all')
  async getAllWithdrawals(@Query('limit') limit?: number) {
    return await this.withdrawalService.getAllWithdrawals(limit || 100);
  }

  /**
   * Process withdrawal (admin only)
   */
  @Post('process')
  async processWithdrawal(@Body() processDto: ProcessWithdrawalDto, @Request() req) {
    const adminId = req.user?.id || req.body.adminId;
    return await this.withdrawalService.processWithdrawal(processDto, adminId);
  }

  /**
   * Complete withdrawal (admin only)
   */
  @Post('complete')
  async completeWithdrawal(
    @Body() body: { withdrawalId: string; transactionId: string; adminId: string },
  ) {
    return await this.withdrawalService.completeWithdrawal(
      body.withdrawalId,
      body.transactionId,
      body.adminId,
    );
  }

  /**
   * Cancel withdrawal
   */
  @Delete(':id')
  async cancelWithdrawal(@Param('id') id: string, @Request() req) {
    const userId = req.user?.id || req.body.userId;
    return await this.withdrawalService.cancelWithdrawal(userId, id);
  }
}

