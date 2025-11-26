import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { QuestionsService } from '../questions/questions.service';
import { UsersService } from '../users/users.service';

interface GameRoom {
  id: string;
  players: {
    player1: {
      userId: string;
      socketId: string;
      username: string;
      score: number;
      answers: { questionId: string; answer: string; correct: boolean; time: number }[];
      ready: boolean;
    };
    player2: {
      userId: string;
      socketId: string;
      username: string;
      score: number;
      answers: { questionId: string; answer: string; correct: boolean; time: number }[];
      ready: boolean;
    };
  };
  questions: any[];
  currentQuestionIndex: number;
  status: 'waiting' | 'ready' | 'playing' | 'finished';
  startedAt?: Date;
  finishedAt?: Date;
}

interface TeamPlayer {
  userId: string;
  socketId: string;
  username: string;
  team: 'A' | 'B';
  score: number;
  answers: { questionId: string; answer: string; correct: boolean; time: number }[];
  ready: boolean;
}

interface TeamRoom {
  id: string;
  roomCode: string;
  hostId: string;
  players: Map<string, TeamPlayer>;
  questions: any[];
  currentQuestionIndex: number;
  status: 'waiting' | 'ready' | 'playing' | 'finished';
  maxPlayers: number;
  teamAScore: number;
  teamBScore: number;
  startedAt?: Date;
  finishedAt?: Date;
}

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  namespace: '/game',
})
export class GameGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger = new Logger('GameGateway');
  private waitingPlayers: Map<string, { userId: string; socketId: string; username: string; level: number; region?: string }> = new Map();
  private gameRooms: Map<string, GameRoom> = new Map();
  private teamRooms: Map<string, TeamRoom> = new Map();
  private socketToRoom: Map<string, string> = new Map();
  private roomCodeToId: Map<string, string> = new Map();

  constructor(
    private questionsService: QuestionsService,
    private usersService: UsersService,
  ) {}

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    
    // Remove from waiting list
    this.waitingPlayers.delete(client.id);
    
    // Handle room disconnect
    const roomId = this.socketToRoom.get(client.id);
    if (roomId) {
      const room = this.gameRooms.get(roomId);
      if (room) {
        // Notify other player
        const otherPlayer = room.players.player1.socketId === client.id 
          ? room.players.player2 
          : room.players.player1;
        
        if (otherPlayer) {
          this.server.to(otherPlayer.socketId).emit('opponentDisconnected', {
            message: 'Your opponent has disconnected',
          });
        }
        
        // Clean up
        this.gameRooms.delete(roomId);
        this.socketToRoom.delete(client.id);
        if (otherPlayer) {
          this.socketToRoom.delete(otherPlayer.socketId);
        }
      }
    }
  }

  @SubscribeMessage('findMatch')
  async handleFindMatch(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string; username: string; level: number; region?: string },
  ) {
    this.logger.log(`Player ${data.username} looking for match (region: ${data.region || 'global'})`);

    // Check if already in queue
    if (this.waitingPlayers.has(client.id)) {
      client.emit('error', { message: 'Already in queue' });
      return;
    }

    // Add to waiting list
    this.waitingPlayers.set(client.id, {
      userId: data.userId,
      socketId: client.id,
      username: data.username,
      level: data.level,
      region: data.region || 'global',
    });

    client.emit('searchingForMatch', { message: 'Searching for opponent...' });

    // Try to find a match
    await this.tryMatchmaking(client, {
      userId: data.userId,
      username: data.username,
      level: data.level,
      region: data.region || 'global',
    });
  }

  @SubscribeMessage('cancelMatch')
  handleCancelMatch(@ConnectedSocket() client: Socket) {
    this.waitingPlayers.delete(client.id);
    client.emit('matchCancelled', { message: 'Match search cancelled' });
  }

  @SubscribeMessage('playerReady')
  async handlePlayerReady(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const room = this.gameRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    // Mark player as ready
    if (room.players.player1.socketId === client.id) {
      room.players.player1.ready = true;
    } else if (room.players.player2.socketId === client.id) {
      room.players.player2.ready = true;
    }

    // Check if both players are ready
    if (room.players.player1.ready && room.players.player2.ready) {
      room.status = 'playing';
      room.startedAt = new Date();

      // Send first question
      this.server.to(data.roomId).emit('gameStarted', {
        question: room.questions[0],
        questionNumber: 1,
        totalQuestions: room.questions.length,
      });
    } else {
      // Notify room that one player is ready
      this.server.to(data.roomId).emit('playerReady', {
        message: 'Waiting for other player...',
      });
    }
  }

  @SubscribeMessage('submitAnswer')
  async handleSubmitAnswer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string; questionId: string; answer: string; timeSpent: number },
  ) {
    const room = this.gameRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    const currentQuestion = room.questions[room.currentQuestionIndex];
    const isCorrect = currentQuestion.correctAnswer === data.answer;

    // Update player's answer
    let player = room.players.player1.socketId === client.id ? room.players.player1 : room.players.player2;
    
    player.answers.push({
      questionId: data.questionId,
      answer: data.answer,
      correct: isCorrect,
      time: data.timeSpent,
    });

    let attackResult: string | null = null;
    
    if (isCorrect) {
      player.score += 100;
      
      // Determine attack/counter-attack
      const opponent = player.socketId === room.players.player1.socketId 
        ? room.players.player2 
        : room.players.player1;
      
      // Check if opponent already answered this question
      const opponentAnswer = opponent.answers.find(a => a.questionId === data.questionId);
      
      if (opponentAnswer) {
        // Opponent already answered
        if (opponentAnswer.correct) {
          // Both correct - check who was faster
          if (data.timeSpent < opponentAnswer.time) {
            attackResult = 'counter'; // Counter-attack (faster correct answer)
            player.score += 50; // Bonus for counter-attack
          }
        } else {
          // Opponent was wrong, player is correct - this is an attack
          attackResult = 'attack';
          player.score += 50; // Bonus for attack
        }
      } else {
        // Player answered first and correctly - this is an attack
        attackResult = 'attack';
        player.score += 50; // Bonus for attack
      }
    }

    // Notify player of their result
    client.emit('answerResult', {
      correct: isCorrect,
      correctAnswer: currentQuestion.correctAnswer,
      score: player.score,
      attackResult: attackResult,
    });

    // Check if both players answered
    const bothAnswered = 
      room.players.player1.answers.length === room.currentQuestionIndex + 1 &&
      room.players.player2.answers.length === room.currentQuestionIndex + 1;

    if (bothAnswered) {
      // Move to next question or end game
      if (room.currentQuestionIndex < room.questions.length - 1) {
        room.currentQuestionIndex++;
        
        // Send next question after 2 seconds
        setTimeout(() => {
          this.server.to(data.roomId).emit('nextQuestion', {
            question: room.questions[room.currentQuestionIndex],
            questionNumber: room.currentQuestionIndex + 1,
            totalQuestions: room.questions.length,
            scores: {
              player1: room.players.player1.score,
              player2: room.players.player2.score,
            },
          });
        }, 2000);
      } else {
        // Game finished
        room.status = 'finished';
        room.finishedAt = new Date();

        const results = {
          player1: {
            userId: room.players.player1.userId,
            username: room.players.player1.username,
            score: room.players.player1.score,
            correctAnswers: room.players.player1.answers.filter(a => a.correct).length,
          },
          player2: {
            userId: room.players.player2.userId,
            username: room.players.player2.username,
            score: room.players.player2.score,
            correctAnswers: room.players.player2.answers.filter(a => a.correct).length,
          },
          winner: room.players.player1.score > room.players.player2.score 
            ? room.players.player1.username 
            : room.players.player2.score > room.players.player1.score 
            ? room.players.player2.username 
            : 'Draw',
        };

        // Update user stats in database and get updated user data
        const updatedUsers = await this.updatePlayerStats(room);
        
        // Add updated user data to results
        results['updatedUsers'] = updatedUsers;
        
        this.server.to(data.roomId).emit('gameFinished', results);

        // Clean up room after 10 seconds
        setTimeout(() => {
          this.gameRooms.delete(data.roomId);
        }, 10000);
      }
    } else {
      // Notify opponent that player answered
      const opponentSocketId = player.socketId === room.players.player1.socketId 
        ? room.players.player2.socketId 
        : room.players.player1.socketId;
      
      this.server.to(opponentSocketId).emit('opponentAnswered', {
        message: 'Opponent has answered',
        correct: isCorrect,
        attackResult: attackResult,
      });
    }
  }

  private async tryMatchmaking(client: Socket, playerData: { userId: string; username: string; level: number; region?: string }) {
    this.logger.log(`Trying matchmaking for ${playerData.username} (Level ${playerData.level}, Region: ${playerData.region || 'global'})`);
    this.logger.log(`Waiting players in queue: ${this.waitingPlayers.size}`);
    
    // Look for a suitable opponent
    for (const [socketId, opponent] of this.waitingPlayers.entries()) {
      if (socketId === client.id) {
        this.logger.log(`Skipping self: ${client.id}`);
        continue;
      }

      this.logger.log(`Checking opponent: ${opponent.username} (Level ${opponent.level}, Region: ${opponent.region || 'global'})`);

      // Match based on similar level (±5 levels)
      const levelDiff = Math.abs(opponent.level - playerData.level);
      this.logger.log(`Level difference: ${levelDiff}`);
      
      // Match based on region (if specified)
      const regionMatch = !playerData.region || !opponent.region || 
                          playerData.region === 'global' || 
                          opponent.region === 'global' ||
                          playerData.region === opponent.region;
      
      this.logger.log(`Region match: ${regionMatch}`);
      
      if (levelDiff <= 5 && regionMatch) {
        // Found a match!
        this.logger.log(`✅ Match found: ${playerData.username} vs ${opponent.username}`);

        // Remove both from waiting list
        this.waitingPlayers.delete(client.id);
        this.waitingPlayers.delete(socketId);

        // Create game room
        const roomId = `room_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const questions = await this.questionsService.getRandom(10);

        const gameRoom: GameRoom = {
          id: roomId,
          players: {
            player1: {
              userId: playerData.userId,
              socketId: client.id,
              username: playerData.username,
              score: 0,
              answers: [],
              ready: false,
            },
            player2: {
              userId: opponent.userId,
              socketId: socketId,
              username: opponent.username,
              score: 0,
              answers: [],
              ready: false,
            },
          },
          questions,
          currentQuestionIndex: 0,
          status: 'ready',
        };

        this.gameRooms.set(roomId, gameRoom);
        this.socketToRoom.set(client.id, roomId);
        this.socketToRoom.set(socketId, roomId);

        // Add both players to the room
        client.join(roomId);
        this.socketToRoom.set(client.id, roomId);
        
        // Use Socket.io's proper method to get socket
        const oppSocket = await this.server.in(socketId).fetchSockets();
        if (oppSocket.length > 0) {
          oppSocket[0].join(roomId);
          this.logger.log(`Both players joined room: ${roomId}`);
        } else {
          this.logger.warn(`Could not find opponent socket: ${socketId}, using emit instead`);
        }

        // Notify both players
        client.emit('matchFound', {
          roomId,
          opponent: opponent.username,
          message: 'Match found! Get ready...',
        });

        this.server.to(socketId).emit('matchFound', {
          roomId,
          opponent: playerData.username,
          message: 'Match found! Get ready...',
        });

        return;
      }
    }

    // No match found yet, keep waiting
    this.logger.log(`No match found for ${playerData.username}, waiting...`);
  }

  private async updatePlayerStats(room: GameRoom): Promise<{ [userId: string]: any }> {
    const updatedUsers: { [userId: string]: any } = {};
    
    try {
      // Update player 1
      const user1 = await this.usersService.findOne(room.players.player1.userId);
      if (user1) {
        const won = room.players.player1.score > room.players.player2.score;
        await this.usersService.update(room.players.player1.userId, {
          challenge1v1Played: user1.challenge1v1Played + 1,
          totalGames: user1.totalGames + 1,
          xp: user1.xp + (won ? 100 : 50),
          coins: user1.coins + (won ? 50 : 25),
        });
        
        // Fetch updated user data
        updatedUsers[room.players.player1.userId] = await this.usersService.findOne(room.players.player1.userId);
      }

      // Update player 2
      const user2 = await this.usersService.findOne(room.players.player2.userId);
      if (user2) {
        const won = room.players.player2.score > room.players.player1.score;
        await this.usersService.update(room.players.player2.userId, {
          challenge1v1Played: user2.challenge1v1Played + 1,
          totalGames: user2.totalGames + 1,
          xp: user2.xp + (won ? 100 : 50),
          coins: user2.coins + (won ? 50 : 25),
        });
        
        // Fetch updated user data
        updatedUsers[room.players.player2.userId] = await this.usersService.findOne(room.players.player2.userId);
      }
    } catch (error) {
      this.logger.error('Error updating player stats:', error);
    }
    
    return updatedUsers;
  }

  // ==================== TEAM MATCH HANDLERS ====================

  @SubscribeMessage('createTeamRoom')
  async handleCreateTeamRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string; username: string; maxPlayers: number },
  ) {
    try {
      this.logger.log(`Creating team room by ${data.username}`);

      const roomCode = this.generateRoomCode();
      const roomId = `team_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      this.logger.log(`Fetching questions for team room...`);
      const questions = await this.questionsService.getRandom(10);
      
      if (!questions || questions.length === 0) {
        this.logger.error('No questions available for team room');
        client.emit('error', { message: 'No questions available. Please seed questions first.' });
        return;
      }

      this.logger.log(`Got ${questions.length} questions for team room`);

      const teamRoom: TeamRoom = {
        id: roomId,
        roomCode,
        hostId: data.userId,
        players: new Map(),
        questions,
        currentQuestionIndex: 0,
        status: 'waiting',
        maxPlayers: Math.min(data.maxPlayers || 10, 10),
        teamAScore: 0,
        teamBScore: 0,
      };

      // Add host as first player in Team A
      teamRoom.players.set(client.id, {
        userId: data.userId,
        socketId: client.id,
        username: data.username,
        team: 'A',
        score: 0,
        answers: [],
        ready: false,
      });

      this.teamRooms.set(roomId, teamRoom);
      this.roomCodeToId.set(roomCode, roomId);
      this.socketToRoom.set(client.id, roomId);
      client.join(roomId);

      this.logger.log(`✅ Team room created: ${roomCode} (ID: ${roomId})`);

      client.emit('teamRoomCreated', {
        roomId,
        roomCode,
        message: `Room created! Share code: ${roomCode}`,
      });

      this.logger.log(`Emitted teamRoomCreated event to client`);

      this.broadcastRoomState(roomId);
    } catch (error) {
      this.logger.error(`Error creating team room: ${error}`);
      client.emit('error', { message: 'Failed to create room. Please try again.' });
    }
  }

  @SubscribeMessage('joinTeamRoom')
  async handleJoinTeamRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string; username: string; roomCode: string; team?: 'A' | 'B' },
  ) {
    this.logger.log(`${data.username} trying to join room ${data.roomCode}`);

    const roomId = this.roomCodeToId.get(data.roomCode.toUpperCase());
    
    if (!roomId) {
      client.emit('error', { message: 'Room not found. Check the code and try again.' });
      return;
    }

    const room = this.teamRooms.get(roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found.' });
      return;
    }

    if (room.status !== 'waiting') {
      client.emit('error', { message: 'Game already started.' });
      return;
    }

    if (room.players.size >= room.maxPlayers) {
      client.emit('error', { message: 'Room is full.' });
      return;
    }

    // Auto-balance teams if no preference
    let assignedTeam = data.team;
    if (!assignedTeam) {
      const teamACount = Array.from(room.players.values()).filter(p => p.team === 'A').length;
      const teamBCount = room.players.size - teamACount;
      assignedTeam = teamACount <= teamBCount ? 'A' : 'B';
    }

    // Add player to room
    room.players.set(client.id, {
      userId: data.userId,
      socketId: client.id,
      username: data.username,
      team: assignedTeam,
      score: 0,
      answers: [],
      ready: false,
    });

    this.socketToRoom.set(client.id, roomId);
    client.join(roomId);

    client.emit('teamRoomJoined', {
      roomId,
      roomCode: room.roomCode,
      team: assignedTeam,
      message: `Joined room ${room.roomCode}!`,
    });

    this.broadcastRoomState(roomId);
  }

  @SubscribeMessage('leaveTeamRoom')
  handleLeaveTeamRoom(@ConnectedSocket() client: Socket) {
    const roomId = this.socketToRoom.get(client.id);
    if (!roomId) return;

    const room = this.teamRooms.get(roomId);
    if (room) {
      room.players.delete(client.id);
      
      // If host left and room not empty, assign new host
      if (room.hostId === room.players.get(client.id)?.userId) {
        const remainingPlayers = Array.from(room.players.values());
        if (remainingPlayers.length > 0) {
          room.hostId = remainingPlayers[0].userId;
        }
      }

      // If room empty, delete it
      if (room.players.size === 0) {
        this.teamRooms.delete(roomId);
        this.roomCodeToId.delete(room.roomCode);
      } else {
        this.broadcastRoomState(roomId);
      }
    }

    this.socketToRoom.delete(client.id);
    client.leave(roomId);
  }

  @SubscribeMessage('teamPlayerReady')
  handleTeamPlayerReady(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const room = this.teamRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    const player = room.players.get(client.id);
    if (player) {
      player.ready = true;
    }

    this.broadcastRoomState(data.roomId);
  }

  @SubscribeMessage('shuffleTeams')
  handleShuffleTeams(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const room = this.teamRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    const player = room.players.get(client.id);
    if (!player || player.userId !== room.hostId) {
      client.emit('error', { message: 'Only host can shuffle teams' });
      return;
    }

    if (room.status !== 'waiting') {
      client.emit('error', { message: 'Cannot shuffle teams after game has started' });
      return;
    }

    if (room.players.size < 2) {
      client.emit('error', { message: 'Need at least 2 players to shuffle teams' });
      return;
    }

    // Get all players as array
    const playersArray = Array.from(room.players.values());
    
    // Shuffle players randomly
    for (let i = playersArray.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [playersArray[i], playersArray[j]] = [playersArray[j], playersArray[i]];
    }

    // Redistribute players evenly between teams
    playersArray.forEach((player, index) => {
      // Alternate teams: even index = Team A, odd index = Team B
      player.team = index % 2 === 0 ? 'A' : 'B';
      
      // Update in the room's players map
      const socketId = player.socketId;
      const existingPlayer = room.players.get(socketId);
      if (existingPlayer) {
        existingPlayer.team = player.team;
      }
    });

    this.logger.log(`Teams shuffled in room ${data.roomId} by host ${player.username}`);
    
    // Broadcast updated room state
    this.broadcastRoomState(data.roomId);
    
    // Notify all players that teams were shuffled
    this.server.to(data.roomId).emit('teamsShuffled', {
      message: 'Teams have been shuffled!',
    });
  }

  @SubscribeMessage('startTeamGame')
  async handleStartTeamGame(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string },
  ) {
    const room = this.teamRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    const player = room.players.get(client.id);
    if (!player || player.userId !== room.hostId) {
      client.emit('error', { message: 'Only host can start the game' });
      return;
    }

    if (room.players.size < 2) {
      client.emit('error', { message: 'Need at least 2 players to start' });
      return;
    }

    room.status = 'playing';
    room.startedAt = new Date();

    this.server.to(data.roomId).emit('teamGameStarted', {
      question: room.questions[0],
      questionNumber: 1,
      totalQuestions: room.questions.length,
    });
  }

  @SubscribeMessage('teamSubmitAnswer')
  async handleTeamSubmitAnswer(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { roomId: string; questionId: string; answer: string; timeSpent: number },
  ) {
    const room = this.teamRooms.get(data.roomId);
    if (!room) {
      client.emit('error', { message: 'Room not found' });
      return;
    }

    const player = room.players.get(client.id);
    if (!player) return;

    const currentQuestion = room.questions[room.currentQuestionIndex];
    const isCorrect = currentQuestion.correctAnswer === data.answer;

    // Update player's answer
    player.answers.push({
      questionId: data.questionId,
      answer: data.answer,
      correct: isCorrect,
      time: data.timeSpent,
    });

    if (isCorrect) {
      player.score += 100;
      
      // Add to team score
      if (player.team === 'A') {
        room.teamAScore += 100;
      } else {
        room.teamBScore += 100;
      }
    }

    // Notify player of their result
    client.emit('teamAnswerResult', {
      correct: isCorrect,
      correctAnswer: currentQuestion.correctAnswer,
      yourScore: player.score,
      teamScore: player.team === 'A' ? room.teamAScore : room.teamBScore,
    });

    // Broadcast that player answered
    this.server.to(data.roomId).emit('teamPlayerAnswered', {
      username: player.username,
      team: player.team,
    });

    // Check if all players answered
    const allAnswered = Array.from(room.players.values()).every(
      p => p.answers.length === room.currentQuestionIndex + 1,
    );

    if (allAnswered) {
      // Move to next question or end game
      if (room.currentQuestionIndex < room.questions.length - 1) {
        room.currentQuestionIndex++;
        
        // Send next question after 2 seconds
        setTimeout(() => {
          this.server.to(data.roomId).emit('teamNextQuestion', {
            question: room.questions[room.currentQuestionIndex],
            questionNumber: room.currentQuestionIndex + 1,
            totalQuestions: room.questions.length,
            teamAScore: room.teamAScore,
            teamBScore: room.teamBScore,
          });
        }, 2000);
      } else {
        // Game finished
        this.finishTeamGame(room);
      }
    }
  }

  private finishTeamGame(room: TeamRoom) {
    room.status = 'finished';
    room.finishedAt = new Date();

    const teamAPlayers = Array.from(room.players.values()).filter(p => p.team === 'A');
    const teamBPlayers = Array.from(room.players.values()).filter(p => p.team === 'B');

    const results = {
      teamA: {
        score: room.teamAScore,
        players: teamAPlayers.map(p => ({
          username: p.username,
          score: p.score,
          correctAnswers: p.answers.filter(a => a.correct).length,
        })),
      },
      teamB: {
        score: room.teamBScore,
        players: teamBPlayers.map(p => ({
          username: p.username,
          score: p.score,
          correctAnswers: p.answers.filter(a => a.correct).length,
        })),
      },
      winner: room.teamAScore > room.teamBScore 
        ? 'Team A' 
        : room.teamBScore > room.teamAScore 
        ? 'Team B' 
        : 'Draw',
    };

    // Update stats for all players and get updated user data
    this.updateTeamPlayerStats(room).then(updatedUsers => {
      // Add updated user data to results
      results['updatedUsers'] = updatedUsers;
      this.server.to(room.id).emit('teamGameFinished', results);
    });

    // Clean up room after 30 seconds
    setTimeout(() => {
      this.teamRooms.delete(room.id);
      this.roomCodeToId.delete(room.roomCode);
    }, 30000);
  }

  private async updateTeamPlayerStats(room: TeamRoom): Promise<{ [userId: string]: any }> {
    const updatedUsers: { [userId: string]: any } = {};
    const winningTeam = room.teamAScore > room.teamBScore ? 'A' : room.teamBScore > room.teamAScore ? 'B' : null;

    for (const player of room.players.values()) {
      try {
        const user = await this.usersService.findOne(player.userId);
        if (user) {
          const won = winningTeam === player.team;
          const draw = winningTeam === null;
          
          await this.usersService.update(player.userId, {
            teamMatchesPlayed: user.teamMatchesPlayed + 1,
            totalGames: user.totalGames + 1,
            xp: user.xp + (won ? 150 : draw ? 75 : 50),
            coins: user.coins + (won ? 75 : draw ? 35 : 25),
          });
          
          // Fetch updated user data
          updatedUsers[player.userId] = await this.usersService.findOne(player.userId);
        }
      } catch (error) {
        this.logger.error(`Error updating stats for player ${player.username}:`, error);
      }
    }
    
    return updatedUsers;
  }

  private broadcastRoomState(roomId: string) {
    const room = this.teamRooms.get(roomId);
    if (!room) {
      this.logger.warn(`broadcastRoomState: Room ${roomId} not found`);
      return;
    }

    this.logger.log(`Broadcasting room state for ${roomId}, ${room.players.size} players`);

    const playersArray = Array.from(room.players.values()).map(p => ({
      userId: p.userId,
      username: p.username,
      team: p.team,
      ready: p.ready,
      score: p.score,
    }));

    const teamAPlayers = playersArray.filter(p => p.team === 'A');
    const teamBPlayers = playersArray.filter(p => p.team === 'B');

    this.logger.log(`Team A: ${teamAPlayers.length} players, Team B: ${teamBPlayers.length} players`);
    this.logger.log(`Team A players: ${JSON.stringify(teamAPlayers)}`);
    this.logger.log(`Team B players: ${JSON.stringify(teamBPlayers)}`);

    const roomState = {
      roomCode: room.roomCode,
      hostId: room.hostId,
      players: playersArray,
      teamA: teamAPlayers,
      teamB: teamBPlayers,
      playerCount: room.players.size,
      maxPlayers: room.maxPlayers,
      status: room.status,
      teamAScore: room.teamAScore,
      teamBScore: room.teamBScore,
    };

    this.server.to(roomId).emit('teamRoomState', roomState);
    this.logger.log(`✅ Broadcasted team room state to room ${roomId}`);
  }

  private generateRoomCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }
}

