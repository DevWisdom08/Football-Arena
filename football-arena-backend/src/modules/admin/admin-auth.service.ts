import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AdminAuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async adminLogin(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isAdmin) {
      throw new UnauthorizedException('Access denied. Admin privileges required.');
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const { passwordHash, ...result } = user;
    const token = this.jwtService.sign({ 
      sub: user.id, 
      email: user.email,
      isAdmin: true,
    });

    return {
      access_token: token,
      user: result,
    };
  }

  async validateAdminToken(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      if (!payload.isAdmin) {
        throw new UnauthorizedException('Admin access required');
      }
      const user = await this.usersService.findOne(payload.sub);
      if (!user.isAdmin) {
        throw new UnauthorizedException('Admin access required');
      }
      return user;
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}

