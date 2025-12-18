import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { QuestionsService } from './questions.service';
import { CreateQuestionDto } from './dto/create-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto';
import { QuestionDifficulty } from './entities/question.entity';

@Controller('questions')
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  @Post()
  create(@Body() createQuestionDto: CreateQuestionDto) {
    return this.questionsService.create(createQuestionDto);
  }

  @Get()
  findAll() {
    return this.questionsService.findAll();
  }

  @Get('random')
  getRandom(
    @Query('count') count?: number,
    @Query('difficulty') difficulty?: string,
  ) {
    return this.questionsService.getRandom(count ? +count : 10, difficulty);
  }

  @Get('category/:category')
  getByCategory(
    @Param('category') category: string,
    @Query('count') count?: number,
  ) {
    return this.questionsService.getByCategory(category, count ? +count : 10);
  }

  @Post('seed')
  seed() {
    return this.questionsService.seed();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.questionsService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateQuestionDto: UpdateQuestionDto) {
    return this.questionsService.update(id, updateQuestionDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.questionsService.remove(id);
  }
}
