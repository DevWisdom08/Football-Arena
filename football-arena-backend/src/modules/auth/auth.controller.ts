import { Controller, Post, Body, Get, Headers, UnauthorizedException } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @Throttle({ limit: 5, ttl: 60000 }) // 5 registrations per minute
  async register(
    @Body() registerDto: { 
      username: string; 
      email: string; 
      password: string; 
      country: string;
      dateOfBirth?: string;
    },
  ) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @Throttle({ limit: 5, ttl: 60000 }) // 5 login attempts per minute
  async login(@Body() loginDto: { email: string; password: string }) {
    return this.authService.login(loginDto.email, loginDto.password);
  }

  @Post('guest')
  @Throttle({ limit: 10, ttl: 60000 }) // 10 guest logins per minute
  async guestLogin() {
    return this.authService.guestLogin();
  }

  @Get('me')
  async getProfile(@Headers('authorization') authorization: string) {
    if (!authorization) {
      throw new UnauthorizedException('No token provided');
    }
    
    const token = authorization.replace('Bearer ', '');
    return this.authService.validateToken(token);
  }

  @Post('apple')
  async appleSignIn(
    @Body() appleDto: { appleId: string; email: string; name?: string },
  ) {
    return this.authService.appleSignIn(
      appleDto.appleId,
      appleDto.email,
      appleDto.name,
    );
  }

  @Post('google')
  async googleSignIn(
    @Body() googleDto: { googleId: string; email: string; name?: string },
  ) {
    return this.authService.googleSignIn(
      googleDto.googleId,
      googleDto.email,
      googleDto.name,
    );
  }

  @Post('upgrade-guest')
  async upgradeGuest(
    @Body() upgradeDto: {
      userId: string;
      email: string;
      password: string;
      username?: string;
      country?: string;
    },
  ) {
    return this.authService.upgradeGuestAccount(
      upgradeDto.userId,
      upgradeDto,
    );
  }
}
