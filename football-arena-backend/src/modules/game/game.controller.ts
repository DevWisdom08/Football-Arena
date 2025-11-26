import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { GameService } from './game.service';

@Controller('game')
export class GameController {
  constructor(private readonly gameService: GameService) {}

  @Get('daily-quiz')
  getDailyQuiz(@Query('userId') userId: string) {
    return this.gameService.getDailyQuiz(userId);
  }

  @Post('daily-quiz/submit')
  submitDailyQuiz(
    @Body() submitDto: {
      userId: string;
      answers: { questionId: string; answer: string; correct: boolean }[];
    },
  ) {
    return this.gameService.submitDailyQuiz(submitDto.userId, submitDto.answers);
  }

  @Get('daily-quiz/history/:userId')
  getDailyQuizHistory(
    @Param('userId') userId: string,
    @Query('limit') limit?: number,
  ) {
    return this.gameService.getDailyQuizHistory(userId, limit ? +limit : 30);
  }

  @Get('daily-quiz/stats/:userId')
  getDailyQuizStats(@Param('userId') userId: string) {
    return this.gameService.getDailyQuizStats(userId);
  }

  @Get('history/:userId')
  getMatchHistory(
    @Param('userId') userId: string,
    @Query('limit') limit?: number,
  ) {
    return this.gameService.getMatchHistory(userId, limit ? +limit : 50);
  }

  @Get('history/:userId/mode/:mode')
  getMatchHistoryByMode(
    @Param('userId') userId: string,
    @Param('mode') mode: string,
    @Query('limit') limit?: number,
  ) {
    return this.gameService.getMatchHistoryByMode(userId, mode as any, limit ? +limit : 20);
  }

  @Get('stats/:userId')
  getMatchStats(@Param('userId') userId: string) {
    return this.gameService.getMatchStats(userId);
  }

  @Post('daily-quiz/protect-streak')
  protectStreak(
    @Body() protectDto: {
      userId: string;
      method: 'coins' | 'vip';
    },
  ) {
    return this.gameService.protectStreak(protectDto.userId, protectDto.method);
  }

  // ==================== SOLO MODE ====================

  @Post('solo/submit')
  async submitSoloResult(
    @Body() resultDto: {
      userId: string;
      correctAnswers: number;
      totalQuestions: number;
      accuracy: number;
      xpGained: number;
      coinsGained: number;
      score: number;
      duration?: number;
    },
  ) {
    return this.gameService.saveSoloModeResult(resultDto);
  }

  // ==================== SPECIAL EVENTS ====================

  @Get('events/active')
  getActiveEvents() {
    return this.gameService.getActiveEvents();
  }

  @Get('events/all')
  getAllEvents() {
    return this.gameService.getAllEvents();
  }

  @Get('events/:id')
  getEventById(@Param('id') id: string) {
    return this.gameService.getEventById(id);
  }

  @Get('events/multipliers/active')
  getActiveMultipliers() {
    return this.gameService.getActiveMultipliers();
  }

  @Post('events')
  createEvent(@Body() eventData: any) {
    return this.gameService.createEvent(eventData);
  }

  // ==================== TOURNAMENTS ====================

  @Get('tournaments/available')
  getAvailableTournaments() {
    return this.gameService.getAvailableTournaments();
  }

  @Get('tournaments/all')
  getAllTournaments() {
    return this.gameService.getAllTournaments();
  }

  @Get('tournaments/:id')
  getTournamentById(@Param('id') id: string) {
    return this.gameService.getTournamentById(id);
  }

  @Post('tournaments')
  createTournament(@Body() tournamentData: any) {
    return this.gameService.createTournament(tournamentData);
  }

  @Post('tournaments/:id/enter')
  enterTournament(
    @Param('id') tournamentId: string,
    @Body() enterDto: { userId: string },
  ) {
    return this.gameService.enterTournament(enterDto.userId, tournamentId);
  }
}
