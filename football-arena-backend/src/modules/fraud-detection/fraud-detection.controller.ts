import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { FraudDetectionService } from './fraud-detection.service';
import { FraudAlertStatus, FraudAlertSeverity } from './entities/fraud-alert.entity';

@Controller('fraud-detection')
export class FraudDetectionController {
  constructor(private readonly fraudDetectionService: FraudDetectionService) {}

  /**
   * Get all fraud alerts (admin only)
   */
  @Get('alerts')
  @Throttle({ limit: 30, ttl: 60000 }) // 30 requests per minute
  async getAllAlerts(
    @Query('status') status?: FraudAlertStatus,
    @Query('severity') severity?: FraudAlertSeverity,
  ) {
    return await this.fraudDetectionService.getAllAlerts(status, severity);
  }

  /**
   * Get fraud alerts for a specific user (admin only)
   */
  @Get('alerts/user/:userId')
  @Throttle({ limit: 30, ttl: 60000 })
  async getUserAlerts(@Param('userId') userId: string) {
    return await this.fraudDetectionService.getUserAlerts(userId);
  }

  /**
   * Update fraud alert status (admin only)
   */
  @Post('alerts/:alertId/review')
  @Throttle({ limit: 20, ttl: 60000 })
  async updateAlert(
    @Param('alertId') alertId: string,
    @Body()
    body: {
      status: FraudAlertStatus;
      reviewedBy: string;
      reviewNotes?: string;
    },
  ) {
    return await this.fraudDetectionService.updateAlert(
      alertId,
      body.status,
      body.reviewedBy,
      body.reviewNotes,
    );
  }

  /**
   * Check if user is flagged for fraud
   */
  @Get('check/:userId')
  @Throttle({ limit: 50, ttl: 60000 })
  async checkUserFlagged(@Param('userId') userId: string) {
    const isFlagged = await this.fraudDetectionService.isUserFlagged(userId);
    return { userId, isFlagged };
  }

  /**
   * Get fraud statistics (admin dashboard)
   */
  @Get('stats')
  @Throttle({ limit: 30, ttl: 60000 })
  async getFraudStats() {
    return await this.fraudDetectionService.getFraudStats();
  }

  /**
   * Run comprehensive fraud check on user (admin/testing)
   */
  @Post('check/:userId')
  @Throttle({ limit: 10, ttl: 60000 })
  async runFraudCheck(
    @Param('userId') userId: string,
    @Body() body: { ipAddress?: string },
  ) {
    await this.fraudDetectionService.runFraudCheck(userId, body.ipAddress);
    return {
      message: 'Fraud check completed',
      userId,
    };
  }
}

