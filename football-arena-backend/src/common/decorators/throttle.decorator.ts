import { SetMetadata } from '@nestjs/common';

// Custom throttle limits for sensitive endpoints
export const THROTTLE_KEY = 'throttle';

export interface ThrottleOptions {
  limit: number;
  ttl: number;
}

export const Throttle = (options: ThrottleOptions) =>
  SetMetadata(THROTTLE_KEY, options);

// Preset throttle configurations
export const ThrottleAuth = () => Throttle({ limit: 5, ttl: 60000 }); // 5 requests per minute
export const ThrottlePayment = () => Throttle({ limit: 3, ttl: 60000 }); // 3 requests per minute
export const ThrottleWithdrawal = () => Throttle({ limit: 5, ttl: 300000 }); // 5 requests per 5 minutes
export const ThrottleStakeMatch = () => Throttle({ limit: 10, ttl: 60000 }); // 10 requests per minute

