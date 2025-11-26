import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: { 
    username: string; 
    email: string; 
    password: string; 
    country: string 
  }) {
    const existingUser = await this.usersService.findByEmail(registerDto.email);
    
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);
    
    const user = await this.usersService.create({
      ...registerDto,
      passwordHash: hashedPassword,
    });

    const { passwordHash, ...result } = user;
    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      access_token: token,
      user: result,
    };
  }

  async login(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const { passwordHash, ...result } = user;
    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      access_token: token,
      user: result,
    };
  }

  async guestLogin() {
    try {
      const timestamp = Date.now();
      const guestUser = await this.usersService.create({
        username: `Guest_${timestamp}`,
        email: `guest_${timestamp}@temp.com`,
        country: 'Unknown',
        isGuest: true,
      });

      const { passwordHash, ...result } = guestUser;
      const token = this.jwtService.sign({ sub: guestUser.id, email: guestUser.email });

      return {
        access_token: token,
        user: result,
      };
    } catch (error) {
      console.error('Guest login error:', error);
      throw error;
    }
  }

  async validateToken(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      const user = await this.usersService.findOne(payload.sub);
      const { passwordHash, ...result } = user;
      return result;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }

  async appleSignIn(appleId: string, email: string, name?: string) {
    // Check if user exists with this Apple ID
    let user = await this.usersService.findByAppleId(appleId);
    
    if (!user) {
      // Check if email exists (try both email and socialEmail)
      const existingUser = await this.usersService.findByEmail(email);
      if (existingUser) {
        // Link Apple ID to existing account
        user = await this.usersService.update(existingUser.id, {
          appleId,
          socialEmail: email,
        });
      } else {
        // Extract username from email if name not provided
        let username = name;
        if (!username && email) {
          // Extract username from email (e.g., "john.doe@privaterelay.appleid.com" -> "john.doe")
          const emailParts = email.split('@')[0];
          username = emailParts.replace(/[^a-zA-Z0-9]/g, '') || `Apple_${Date.now()}`;
        }
        username = username || `Apple_${Date.now()}`;

        // Create new user with actual Apple email (or use a placeholder if private relay)
        // Apple Sign-In may use private relay emails, so we handle both cases
        const userEmail = email.includes('privaterelay.appleid.com') 
          ? `apple_${appleId}@apple.temp` 
          : email;

        user = await this.usersService.create({
          username,
          email: userEmail,
          socialEmail: email,
          country: 'Unknown', // Default, can be updated later
          appleId,
          isGuest: false,
        });
      }
    } else {
      // User exists, update socialEmail if different
      if (user.socialEmail !== email) {
        user = await this.usersService.update(user.id, {
          socialEmail: email,
        });
      }
    }

    const { passwordHash, ...result } = user;
    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      access_token: token,
      user: result,
    };
  }

  async googleSignIn(googleId: string, email: string, name?: string) {
    // Extract username from email if name not provided
    let username = name;
    if (!username && email) {
      // Extract username from email (e.g., "john.doe@gmail.com" -> "John Doe")
      const emailParts = email.split('@')[0];
      // Replace dots/underscores with spaces and capitalize
      username = emailParts
        .replace(/[._-]/g, ' ')
        .split(' ')
        .map(word => word.length > 0 
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '')
        .filter(word => word.length > 0)
        .join(' ')
        .trim() || `Google_${Date.now()}`;
    }
    username = username || `Google_${Date.now()}`;

    // Check if user exists with this Google ID
    let user = await this.usersService.findByGoogleId(googleId);
    
    if (!user) {
      // Check if email exists (try both email and socialEmail)
      // First try by email field
      let existingUser = await this.usersService.findByEmail(email);
      
      // If not found, try to find by socialEmail
      if (!existingUser) {
        existingUser = await this.usersService.findBySocialEmail(email);
      }

      if (existingUser) {
        // Link Google ID to existing account and update username if provided
        user = await this.usersService.update(existingUser.id, {
          googleId,
          socialEmail: email,
          username: username, // Update username with the provided name
        });
      } else {
        // Create new user with actual Google email
        user = await this.usersService.create({
          username,
          email: email, // Use actual Google email
          socialEmail: email,
          country: 'Unknown', // Default, can be updated later
          googleId,
          isGuest: false,
        });
      }
    } else {
      // User exists, update socialEmail and username if different
      const updateData: any = {};
      if (user.socialEmail !== email) {
        updateData.socialEmail = email;
      }
      if (user.username !== username && username) {
        updateData.username = username;
      }
      if (Object.keys(updateData).length > 0) {
        user = await this.usersService.update(user.id, updateData);
      }
    }

    const { passwordHash, ...result } = user;
    const token = this.jwtService.sign({ sub: user.id, email: user.email });

    return {
      access_token: token,
      user: result,
    };
  }

  async upgradeGuestAccount(
    userId: string,
    upgradeDto: {
      email: string;
      password: string;
      username?: string;
      country?: string;
    },
  ) {
    const user = await this.usersService.findOne(userId);
    
    if (!user.isGuest) {
      throw new ConflictException('User is not a guest account');
    }

    // Check if email already exists
    const existingUser = await this.usersService.findByEmail(upgradeDto.email);
    if (existingUser && existingUser.id !== userId) {
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(upgradeDto.password, 10);
    
    const updatedUser = await this.usersService.update(userId, {
      email: upgradeDto.email,
      passwordHash: hashedPassword,
      isGuest: false,
      username: upgradeDto.username || user.username,
      country: upgradeDto.country || user.country,
    });

    const { passwordHash, ...result } = updatedUser;
    const token = this.jwtService.sign({ sub: updatedUser.id, email: updatedUser.email });

    return {
      access_token: token,
      user: result,
    };
  }
}
