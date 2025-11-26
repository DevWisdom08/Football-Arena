import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  
  // Serve static files (for admin dashboard)
  app.useStaticAssets(join(__dirname, '..', 'public'));
  
  // Enable CORS for Flutter app and admin dashboard
  app.enableCors({
    origin: '*', // In production, specify your Flutter app's domain
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  
  // Enable validation
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 Backend is running on: http://localhost:${port}`);
  console.log(`📚 API Endpoints:`);
  console.log(`   - POST   /auth/register`);
  console.log(`   - POST   /auth/login`);
  console.log(`   - POST   /auth/guest`);
  console.log(`   - GET    /auth/me`);
  console.log(`   - GET    /users`);
  console.log(`   - GET    /users/leaderboard`);
  console.log(`   - GET    /questions/random?count=10`);
  console.log(`   - POST   /questions/seed`);
  console.log(`   - GET    /leaderboard`);
  console.log(``);
  console.log(`🎛️  Admin Dashboard: http://localhost:${port}/admin.html`);
  console.log(`📊 Admin API: http://localhost:${port}/admin/stats/dashboard`);
}
bootstrap();
