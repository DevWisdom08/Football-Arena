import { Controller, Get, Post, Delete, Body, Param, Query, Put, UseGuards, Headers, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { QuestionsService } from '../questions/questions.service';
import { GameService } from '../game/game.service';
import { AdminAuthService } from './admin-auth.service';
import { AdminAuthGuard } from './admin-auth.guard';
import { initialEvents, initialTournaments, getEventDates, getTournamentDates } from './seed-events-tournaments';

@Controller('admin')
export class AdminController {
  constructor(
    private usersService: UsersService,
    private questionsService: QuestionsService,
    private gameService: GameService,
    private adminAuthService: AdminAuthService,
  ) {}

  // ==================== ADMIN AUTHENTICATION ====================

  @Post('auth/login')
  async adminLogin(@Body() loginDto: { email: string; password: string }) {
    return this.adminAuthService.adminLogin(loginDto.email, loginDto.password);
  }

  @Get('auth/me')
  @UseGuards(AdminAuthGuard)
  async getAdminProfile(@Headers('authorization') authorization: string) {
    const token = authorization?.replace('Bearer ', '');
    if (!token) {
      throw new UnauthorizedException('No token provided');
    }
    return this.adminAuthService.validateAdminToken(token);
  }

  // ==================== USERS MANAGEMENT ====================

  @Get('users')
  async getAllUsers(@Query('page') page: number = 1, @Query('limit') limit: number = 50) {
    const users = await this.usersService.findAll();
    return {
      data: users,
      total: users.length,
      page: +page,
      limit: +limit,
    };
  }

  @Get('users/:id')
  async getUserById(@Param('id') id: string) {
    return await this.usersService.findOne(id);
  }

  @Delete('users/:id')
  async deleteUser(@Param('id') id: string) {
    await this.usersService.remove(id);
    return { message: 'User deleted successfully' };
  }

  @Get('users/stats/overview')
  async getUsersStats() {
    const users = await this.usersService.findAll();
    
    return {
      totalUsers: users.length,
      guestUsers: users.filter(u => u.isGuest).length,
      registeredUsers: users.filter(u => !u.isGuest).length,
      vipUsers: users.filter(u => u.isVip).length,
      activeToday: users.filter(u => {
        const lastPlayed = new Date(u.lastPlayedAt);
        const today = new Date();
        return lastPlayed.toDateString() === today.toDateString();
      }).length,
    };
  }

  // ==================== QUESTIONS MANAGEMENT ====================

  @Get('questions')
  async getAllQuestions(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 50,
    @Query('difficulty') difficulty?: string,
    @Query('category') category?: string,
  ) {
    const allQuestions = await this.questionsService.findAll();
    
    let filtered = allQuestions;
    if (difficulty) {
      filtered = filtered.filter(q => q.difficulty === difficulty);
    }
    if (category) {
      filtered = filtered.filter(q => q.categories.includes(category));
    }

    const start = (+page - 1) * +limit;
    const end = start + +limit;
    
    return {
      data: filtered.slice(start, end),
      total: filtered.length,
      page: +page,
      limit: +limit,
    };
  }

  @Get('questions/:id')
  async getQuestionById(@Param('id') id: string) {
    return await this.questionsService.findOne(id);
  }

  @Post('questions')
  async createQuestion(@Body() questionDto: any) {
    return await this.questionsService.create(questionDto);
  }

  @Put('questions/:id')
  async updateQuestion(@Param('id') id: string, @Body() questionDto: any) {
    return await this.questionsService.update(id, questionDto);
  }

  @Delete('questions/:id')
  async deleteQuestion(@Param('id') id: string) {
    await this.questionsService.remove(id);
    return { message: 'Question deleted successfully' };
  }

  @Post('questions/bulk')
  async bulkCreateQuestions(@Body() questions: any[]) {
    const created: any[] = [];
    for (const q of questions) {
      const question = await this.questionsService.create(q);
      created.push(question);
    }
    return {
      message: `${created.length} questions created successfully`,
      questions: created,
    };
  }

  @Get('questions/stats/overview')
  async getQuestionsStats() {
    const questions = await this.questionsService.findAll();
    
    return {
      totalQuestions: questions.length,
      activeQuestions: questions.filter(q => q.isActive).length,
      inactiveQuestions: questions.filter(q => !q.isActive).length,
      byDifficulty: {
        easy: questions.filter(q => q.difficulty === 'easy').length,
        medium: questions.filter(q => q.difficulty === 'medium').length,
        hard: questions.filter(q => q.difficulty === 'hard').length,
      },
      byType: {
        multipleChoice: questions.filter(q => q.type === 'multipleChoice').length,
        trueFalse: questions.filter(q => q.type === 'trueFalse').length,
        imageBased: questions.filter(q => q.type === 'imageBased').length,
      },
    };
  }

  // ==================== DASHBOARD STATS ====================

  @Get('stats/dashboard')
  async getDashboardStats() {
    const users = await this.usersService.findAll();
    const questions = await this.questionsService.findAll();
    
    return {
      users: {
        total: users.length,
        guests: users.filter(u => u.isGuest).length,
        registered: users.filter(u => !u.isGuest).length,
        vip: users.filter(u => u.isVip).length,
      },
      questions: {
        total: questions.length,
        active: questions.filter(q => q.isActive).length,
        inactive: questions.filter(q => !q.isActive).length,
      },
      topPlayers: users.sort((a, b) => b.xp - a.xp).slice(0, 10),
    };
  }

  // ==================== FILE UPLOAD ====================

  @Post('upload/image')
  @UseGuards(AdminAuthGuard)
  async uploadImage(@Body() body: { base64: string; filename: string }) {
    // In production, use proper file storage (S3, Cloudinary, etc.)
    // For now, return a mock URL
    return {
      url: `https://storage.example.com/images/${body.filename}`,
      message: 'Image uploaded successfully (mock)',
    };
  }

  @Post('upload/video')
  @UseGuards(AdminAuthGuard)
  async uploadVideo(@Body() body: { base64: string; filename: string }) {
    // In production, use proper file storage
    return {
      url: `https://storage.example.com/videos/${body.filename}`,
      message: 'Video uploaded successfully (mock)',
    };
  }

  // ==================== CONTENT ANALYTICS ====================

  @Get('analytics/content')
  @UseGuards(AdminAuthGuard)
  async getContentAnalytics(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const questions = await this.questionsService.findAll();
    // Get all daily quiz attempts (would need repository access)
    const dailyQuizAttempts: any[] = []; // Placeholder - would fetch from repository
    
    // Question performance analytics
    const questionStats = questions.map(q => ({
      id: q.id,
      text: q.text.substring(0, 50),
      type: q.type,
      difficulty: q.difficulty,
      timesUsed: 0, // Would need to track this
      averageAccuracy: 0, // Would need to track this
    }));

    // Daily quiz analytics
    const quizStats = {
      totalAttempts: dailyQuizAttempts.length,
      averageScore: dailyQuizAttempts.reduce((sum, a) => sum + a.score, 0) / (dailyQuizAttempts.length || 1),
      averageAccuracy: dailyQuizAttempts.reduce((sum, a) => sum + a.accuracy, 0) / (dailyQuizAttempts.length || 1),
      perfectScores: dailyQuizAttempts.filter(a => a.accuracy === 100).length,
    };

    return {
      questions: {
        total: questions.length,
        byType: {
          multipleChoice: questions.filter(q => q.type === 'multipleChoice').length,
          trueFalse: questions.filter(q => q.type === 'trueFalse').length,
          imageBased: questions.filter(q => q.type === 'imageBased').length,
          mediaBased: questions.filter(q => q.type === 'mediaBased').length,
        },
        byDifficulty: {
          easy: questions.filter(q => q.difficulty === 'easy').length,
          medium: questions.filter(q => q.difficulty === 'medium').length,
          hard: questions.filter(q => q.difficulty === 'hard').length,
        },
        performance: questionStats,
      },
      dailyQuiz: quizStats,
      dateRange: {
        start: startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
        end: endDate || new Date().toISOString(),
      },
    };
  }

  // ==================== DAILY QUIZ SCHEDULER ====================

  @Get('scheduler/daily-quiz')
  @UseGuards(AdminAuthGuard)
  async getDailyQuizSchedules() {
    // Would fetch from DailyQuizSchedule repository
    return {
      schedules: [],
      message: 'Daily quiz scheduler (to be implemented with repository)',
    };
  }

  @Post('scheduler/daily-quiz')
  @UseGuards(AdminAuthGuard)
  async createDailyQuizSchedule(@Body() scheduleDto: any) {
    // Would create schedule in DailyQuizSchedule repository
    return {
      message: 'Schedule created successfully (to be implemented)',
      schedule: scheduleDto,
    };
  }

  @Put('scheduler/daily-quiz/:id')
  @UseGuards(AdminAuthGuard)
  async updateDailyQuizSchedule(@Param('id') id: string, @Body() scheduleDto: any) {
    return {
      message: 'Schedule updated successfully (to be implemented)',
      id,
      schedule: scheduleDto,
    };
  }

  @Delete('scheduler/daily-quiz/:id')
  @UseGuards(AdminAuthGuard)
  async deleteDailyQuizSchedule(@Param('id') id: string) {
    return {
      message: 'Schedule deleted successfully (to be implemented)',
      id,
    };
  }

  // ==================== EVENTS & TOURNAMENTS SEEDING ====================

  @Post('seed/events')
  @UseGuards(AdminAuthGuard)
  async seedEvents() {
    const createdEvents: any[] = [];
    
    for (const eventTemplate of initialEvents) {
      const dates = getEventDates(eventTemplate.type);
      const event = await this.gameService.createEvent({
        ...eventTemplate,
        startDate: dates.startDate,
        endDate: dates.endDate,
      });
      createdEvents.push(event);
    }

    return {
      message: `${createdEvents.length} events created successfully`,
      events: createdEvents,
    };
  }

  @Post('seed/tournaments')
  @UseGuards(AdminAuthGuard)
  async seedTournaments() {
    const createdTournaments: any[] = [];
    
    for (const tournamentTemplate of initialTournaments) {
      const dates = getTournamentDates(tournamentTemplate.name);
      const tournament = await this.gameService.createTournament({
        ...tournamentTemplate,
        startDate: dates.startDate,
        endDate: dates.endDate,
        currentParticipants: 0,
        participantIds: [],
      });
      createdTournaments.push(tournament);
    }

    return {
      message: `${createdTournaments.length} tournaments created successfully`,
      tournaments: createdTournaments,
    };
  }

  @Post('seed/all')
  @UseGuards(AdminAuthGuard)
  async seedAll() {
    const events = await this.seedEvents();
    const tournaments = await this.seedTournaments();

    return {
      message: 'All data seeded successfully',
      events: events.events,
      tournaments: tournaments.tournaments,
    };
  }

  // ==================== EVENTS MANAGEMENT ====================

  @Get('events')
  @UseGuards(AdminAuthGuard)
  async getAllEvents() {
    return this.gameService.getAllEvents();
  }

  @Get('events/:id')
  @UseGuards(AdminAuthGuard)
  async getEventById(@Param('id') id: string) {
    return this.gameService.getEventById(id);
  }

  @Post('events')
  @UseGuards(AdminAuthGuard)
  async createEvent(@Body() eventData: any) {
    return this.gameService.createEvent(eventData);
  }

  // ==================== TOURNAMENTS MANAGEMENT ====================

  @Get('tournaments')
  @UseGuards(AdminAuthGuard)
  async getAllTournaments() {
    return this.gameService.getAllTournaments();
  }

  @Get('tournaments/:id')
  @UseGuards(AdminAuthGuard)
  async getTournamentById(@Param('id') id: string) {
    return this.gameService.getTournamentById(id);
  }

  @Post('tournaments')
  @UseGuards(AdminAuthGuard)
  async createTournament(@Body() tournamentData: any) {
    return this.gameService.createTournament(tournamentData);
  }
}

