import { Controller, Get, Post, Body, Param } from '@nestjs/common';
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
  purchaseItem(@Body() purchaseRequest: PurchaseRequest) {
    return this.storeService.purchaseItem(purchaseRequest);
  }
}

