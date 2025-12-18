import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Question, QuestionDifficulty } from './entities/question.entity';
import { CreateQuestionDto } from './dto/create-question.dto';
import { UpdateQuestionDto } from './dto/update-question.dto';

@Injectable()
export class QuestionsService {
  constructor(
    @InjectRepository(Question)
    private questionsRepository: Repository<Question>,
  ) {}

  async create(createQuestionDto: CreateQuestionDto): Promise<Question> {
    const question = this.questionsRepository.create(createQuestionDto);
    return await this.questionsRepository.save(question);
  }

  async findAll(): Promise<Question[]> {
    return await this.questionsRepository.find({
      where: { isActive: true },
    });
  }

  async findOne(id: string): Promise<Question> {
    const question = await this.questionsRepository.findOne({ where: { id } });
    if (!question) {
      throw new NotFoundException(`Question with ID ${id} not found`);
    }
    return question;
  }

  async getRandom(count: number = 10, difficulty?: string): Promise<Question[]> {
    const queryBuilder = this.questionsRepository
      .createQueryBuilder('question')
      .where('question.isActive = :isActive', { isActive: true });

    // Only filter by difficulty if it's a specific difficulty (not 'mixed' or null)
    // 'mixed' means return questions of any difficulty
    if (difficulty && difficulty !== 'mixed' && ['easy', 'medium', 'hard'].includes(difficulty.toLowerCase())) {
      queryBuilder.andWhere('question.difficulty = :difficulty', { difficulty: difficulty.toLowerCase() });
    }
    // If difficulty is 'mixed' or not specified, return questions of any difficulty

    const questions = await queryBuilder
      .orderBy('RANDOM()')
      .take(count)
      .getMany();

    return questions;
  }

  async getByCategory(category: string, count: number = 10): Promise<Question[]> {
    return await this.questionsRepository
      .createQueryBuilder('question')
      .where('question.isActive = :isActive', { isActive: true })
      .andWhere('question.categories && ARRAY[:category]::text[]', { category })
      .orderBy('RANDOM()')
      .take(count)
      .getMany();
  }

  async update(id: string, updateQuestionDto: UpdateQuestionDto): Promise<Question> {
    await this.findOne(id);
    await this.questionsRepository.update(id, updateQuestionDto);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const question = await this.findOne(id);
    await this.questionsRepository.remove(question);
  }

  async seed() {
    // Read questions from comprehensive-questions.json file
    const fs = require('fs');
    const path = require('path');
    
    let sampleQuestions: any[] = [];
    
    try {
      const questionsPath = path.join(__dirname, '../../../comprehensive-questions.json');
      const questionsData = fs.readFileSync(questionsPath, 'utf8');
      sampleQuestions = JSON.parse(questionsData);
    } catch (error) {
      // Fallback to hardcoded questions if file not found
      sampleQuestions = [
        {
          text: 'Who won the FIFA World Cup in 2018?',
          textAr: 'من فاز بكأس العالم لكرة القدم في 2018؟',
          options: ['France', 'Croatia', 'Belgium', 'England'],
          optionsAr: ['فرنسا', 'كرواتيا', 'بلجيكا', 'إنجلترا'],
          correctAnswer: 'France',
          difficulty: 'easy',
          categories: ['World Cup', 'General'],
        },
        {
          text: 'Which player has won the most Ballon d\'Or awards?',
          textAr: 'أي لاعب فاز بأكبر عدد من جوائز الكرة الذهبية؟',
          options: ['Lionel Messi', 'Cristiano Ronaldo', 'Michel Platini', 'Johan Cruyff'],
          optionsAr: ['ليونيل ميسي', 'كريستيانو رونالدو', 'ميشيل بلاتيني', 'يوهان كرويف'],
          correctAnswer: 'Lionel Messi',
          difficulty: 'medium',
          categories: ['Players', 'General'],
        },
      ];
    }

    let successCount = 0;
    let errorCount = 0;

    for (const q of sampleQuestions) {
      try {
        await this.create(q as CreateQuestionDto);
        successCount++;
      } catch (error) {
        // Skip duplicate or invalid questions
        errorCount++;
      }
    }

    return { 
      message: `Questions seeded successfully`,
      total: sampleQuestions.length,
      added: successCount,
      skipped: errorCount,
    };
  }
}
