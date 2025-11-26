import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FriendRequest, Friendship, FriendRequestStatus } from './entities/friend.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class FriendsService {
  constructor(
    @InjectRepository(FriendRequest)
    private friendRequestRepository: Repository<FriendRequest>,
    @InjectRepository(Friendship)
    private friendshipRepository: Repository<Friendship>,
    private usersService: UsersService,
  ) {}

  async sendFriendRequest(senderId: string, receiverId: string) {
    try {
      if (senderId === receiverId) {
        throw new BadRequestException('Cannot send friend request to yourself');
      }

      // Verify both users exist
      const sender = await this.usersService.findOne(senderId);
      const receiver = await this.usersService.findOne(receiverId);

      if (!sender || !receiver) {
        throw new BadRequestException('User not found');
      }

      // Check if already friends
      const existingFriendship = await this.checkFriendship(senderId, receiverId);
      if (existingFriendship) {
        throw new BadRequestException('Already friends');
      }

      // Check for existing pending request
      const existingRequest = await this.friendRequestRepository.findOne({
        where: [
          { senderId, receiverId, status: FriendRequestStatus.PENDING },
          { senderId: receiverId, receiverId: senderId, status: FriendRequestStatus.PENDING },
        ],
      });

      if (existingRequest) {
        throw new BadRequestException('Friend request already exists');
      }

      const request = this.friendRequestRepository.create({
        senderId,
        receiverId,
        status: FriendRequestStatus.PENDING,
      });

      const savedRequest = await this.friendRequestRepository.save(request);

      return {
        success: true,
        request: savedRequest,
        message: 'Friend request sent successfully',
      };
    } catch (error) {
      console.error('Error sending friend request:', error);
      throw error;
    }
  }

  async acceptFriendRequest(requestId: string, userId: string) {
    const request = await this.friendRequestRepository.findOne({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.receiverId !== userId) {
      throw new BadRequestException('Not authorized to accept this request');
    }

    if (request.status !== FriendRequestStatus.PENDING) {
      throw new BadRequestException('Request already processed');
    }

    // Update request status
    request.status = FriendRequestStatus.ACCEPTED;
    request.respondedAt = new Date();
    await this.friendRequestRepository.save(request);

    // Create friendship
    const friendship = this.friendshipRepository.create({
      user1Id: request.senderId,
      user2Id: request.receiverId,
    });

    return await this.friendshipRepository.save(friendship);
  }

  async rejectFriendRequest(requestId: string, userId: string) {
    const request = await this.friendRequestRepository.findOne({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Friend request not found');
    }

    if (request.receiverId !== userId) {
      throw new BadRequestException('Not authorized to reject this request');
    }

    request.status = FriendRequestStatus.REJECTED;
    request.respondedAt = new Date();
    
    return await this.friendRequestRepository.save(request);
  }

  async removeFriend(userId: string, friendId: string) {
    const friendship = await this.friendshipRepository.findOne({
      where: [
        { user1Id: userId, user2Id: friendId },
        { user1Id: friendId, user2Id: userId },
      ],
    });

    if (!friendship) {
      throw new NotFoundException('Friendship not found');
    }

    await this.friendshipRepository.remove(friendship);
    return { message: 'Friend removed successfully' };
  }

  async getFriends(userId: string) {
    const friendships = await this.friendshipRepository.find({
      where: [{ user1Id: userId }, { user2Id: userId }],
      relations: ['user1', 'user2'],
    });

    return friendships.map(f => {
      const friend = f.user1Id === userId ? f.user2 : f.user1;
      return {
        id: f.id,
        friendId: friend.id,
        username: friend.username,
        level: friend.level,
        xp: friend.xp,
        country: friend.country,
        avatarUrl: friend.avatarUrl,
        createdAt: f.createdAt,
      };
    });
  }

  async getPendingRequests(userId: string) {
    const requests = await this.friendRequestRepository.find({
      where: { receiverId: userId, status: FriendRequestStatus.PENDING },
      relations: ['sender'],
      order: { createdAt: 'DESC' },
    });

    return requests.map(r => ({
      id: r.id,
      senderId: r.sender.id,
      username: r.sender.username,
      level: r.sender.level,
      country: r.sender.country,
      avatarUrl: r.sender.avatarUrl,
      createdAt: r.createdAt,
    }));
  }

  async getSentRequests(userId: string) {
    return await this.friendRequestRepository.find({
      where: { senderId: userId, status: FriendRequestStatus.PENDING },
      relations: ['receiver'],
      order: { createdAt: 'DESC' },
    });
  }

  async checkFriendship(userId: string, otherUserId: string): Promise<boolean> {
    const friendship = await this.friendshipRepository.findOne({
      where: [
        { user1Id: userId, user2Id: otherUserId },
        { user1Id: otherUserId, user2Id: userId },
      ],
    });

    return !!friendship;
  }
}

