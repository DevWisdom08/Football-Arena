import { Controller, Get, Post, Delete, Param, Body, Query } from '@nestjs/common';
import { FriendsService } from './friends.service';

@Controller('friends')
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Get(':userId')
  getFriends(@Param('userId') userId: string) {
    return this.friendsService.getFriends(userId);
  }

  @Get(':userId/requests/pending')
  getPendingRequests(@Param('userId') userId: string) {
    return this.friendsService.getPendingRequests(userId);
  }

  @Get(':userId/requests/sent')
  getSentRequests(@Param('userId') userId: string) {
    return this.friendsService.getSentRequests(userId);
  }

  @Post('request')
  sendFriendRequest(
    @Body() requestDto: { senderId: string; receiverId: string },
  ) {
    return this.friendsService.sendFriendRequest(
      requestDto.senderId,
      requestDto.receiverId,
    );
  }

  @Post('request/:id/accept')
  acceptFriendRequest(
    @Param('id') requestId: string,
    @Body() body: { userId: string },
  ) {
    return this.friendsService.acceptFriendRequest(requestId, body.userId);
  }

  @Post('request/:id/reject')
  rejectFriendRequest(
    @Param('id') requestId: string,
    @Body() body: { userId: string },
  ) {
    return this.friendsService.rejectFriendRequest(requestId, body.userId);
  }

  @Delete(':userId/:friendId')
  removeFriend(
    @Param('userId') userId: string,
    @Param('friendId') friendId: string,
  ) {
    return this.friendsService.removeFriend(userId, friendId);
  }

  @Get('check/:userId/:otherUserId')
  checkFriendship(
    @Param('userId') userId: string,
    @Param('otherUserId') otherUserId: string,
  ) {
    return this.friendsService.checkFriendship(userId, otherUserId);
  }
}

