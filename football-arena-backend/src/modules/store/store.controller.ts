import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { StoreService } from './store.service';
import type { PurchaseRequest } from './store.service';

@Controller('store')
export class StoreController {
  constructor(private readonly storeService: StoreService) {}

  @Get('items')
  getStoreItems() {
    return this.storeService.getStoreItems();
  }

  @Post('purchase')
  @Throttle({ limit: 10, ttl: 60000 }) // 10 purchases per minute
  purchaseItem(@Body() purchaseRequest: PurchaseRequest) {
    return this.storeService.purchaseItem(purchaseRequest);
  }
}

