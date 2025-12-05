import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    final token = StorageService.instance.getAuthToken();
    
    _socket = IO.io(
      '${AppConstants.baseUrl}/game',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .setTimeout(5000) // 5 second timeout
          .enableReconnection()
          .setReconnectionAttempts(3)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket?.onConnect((_) {
      print('🟢 Socket connected');
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      print('🔴 Socket disconnected');
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
    });

    _socket?.onConnectTimeout((data) {
      print('⏱️ Socket connection timeout');
      _isConnected = false;
    });

    _socket?.onError((error) {
      print('❌ Socket error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // Matchmaking
  void findMatch({
    required String userId,
    required String username,
    required int level,
    String? region,
  }) {
    _socket?.emit('findMatch', {
      'userId': userId,
      'username': username,
      'level': level,
      if (region != null) 'region': region,
    });
  }

  void cancelMatch() {
    _socket?.emit('cancelMatch', {});
  }

  // Game actions
  void playerReady(String roomId) {
    _socket?.emit('playerReady', {'roomId': roomId});
  }

  void submitAnswer({
    required String roomId,
    required String questionId,
    required String answer,
    required int timeSpent,
  }) {
    _socket?.emit('submitAnswer', {
      'roomId': roomId,
      'questionId': questionId,
      'answer': answer,
      'timeSpent': timeSpent,
    });
  }

  // Event listeners
  void onSearchingForMatch(Function(dynamic) callback) {
    _socket?.on('searchingForMatch', callback);
  }

  void onMatchFound(Function(dynamic) callback) {
    _socket?.on('matchFound', callback);
  }

  void onMatchCancelled(Function(dynamic) callback) {
    _socket?.on('matchCancelled', callback);
  }

  void onPlayerReady(Function(dynamic) callback) {
    _socket?.on('playerReady', callback);
  }

  void onGameStarted(Function(dynamic) callback) {
    _socket?.on('gameStarted', callback);
  }

  void onAnswerResult(Function(dynamic) callback) {
    _socket?.on('answerResult', callback);
  }

  void onOpponentAnswered(Function(dynamic) callback) {
    _socket?.on('opponentAnswered', callback);
  }

  void onNextQuestion(Function(dynamic) callback) {
    _socket?.on('nextQuestion', callback);
  }

  void onGameFinished(Function(dynamic) callback) {
    _socket?.on('gameFinished', callback);
  }

  void onOpponentDisconnected(Function(dynamic) callback) {
    _socket?.on('opponentDisconnected', callback);
  }

  void onError(Function(dynamic) callback) {
    _socket?.on('error', callback);
  }

  // Team Match actions
  void createTeamRoom({
    required String userId,
    required String username,
    int maxPlayers = 10,
    String? roomName,
    int? rounds,
    int? questionsPerRound,
  }) {
    _socket?.emit('createTeamRoom', {
      'userId': userId,
      'username': username,
      'maxPlayers': maxPlayers,
      if (roomName != null) 'roomName': roomName,
      if (rounds != null) 'rounds': rounds,
      if (questionsPerRound != null) 'questionsPerRound': questionsPerRound,
    });
  }

  void joinTeamRoom({
    required String userId,
    required String username,
    required String roomCode,
    String? team,
  }) {
    _socket?.emit('joinTeamRoom', {
      'userId': userId,
      'username': username,
      'roomCode': roomCode,
      if (team != null) 'team': team,
    });
  }

  void leaveTeamRoom() {
    _socket?.emit('leaveTeamRoom', {});
  }

  void teamPlayerReady(String roomId) {
    _socket?.emit('teamPlayerReady', {'roomId': roomId});
  }

  void startTeamGame(String roomId) {
    _socket?.emit('startTeamGame', {'roomId': roomId});
  }

  void shuffleTeams(String roomId) {
    _socket?.emit('shuffleTeams', {'roomId': roomId});
  }

  void teamSubmitAnswer({
    required String roomId,
    required String questionId,
    required String answer,
    required int timeSpent,
  }) {
    _socket?.emit('teamSubmitAnswer', {
      'roomId': roomId,
      'questionId': questionId,
      'answer': answer,
      'timeSpent': timeSpent,
    });
  }

  // Team Match listeners
  void onTeamRoomCreated(Function(dynamic) callback) {
    _socket?.on('teamRoomCreated', callback);
  }

  void onTeamRoomJoined(Function(dynamic) callback) {
    _socket?.on('teamRoomJoined', callback);
  }

  void onTeamRoomState(Function(dynamic) callback) {
    _socket?.on('teamRoomState', callback);
  }

  void onTeamGameStarted(Function(dynamic) callback) {
    _socket?.on('teamGameStarted', callback);
  }

  void onTeamAnswerResult(Function(dynamic) callback) {
    _socket?.on('teamAnswerResult', callback);
  }

  void onTeamPlayerAnswered(Function(dynamic) callback) {
    _socket?.on('teamPlayerAnswered', callback);
  }

  void onTeamNextQuestion(Function(dynamic) callback) {
    _socket?.on('teamNextQuestion', callback);
  }

  void onTeamGameFinished(Function(dynamic) callback) {
    _socket?.on('teamGameFinished', callback);
  }

  void onTeamsShuffled(Function(dynamic) callback) {
    _socket?.on('teamsShuffled', callback);
  }

  // Remove listeners
  void offAll() {
    _socket?.off('searchingForMatch');
    _socket?.off('matchFound');
    _socket?.off('matchCancelled');
    _socket?.off('playerReady');
    _socket?.off('gameStarted');
    _socket?.off('answerResult');
    _socket?.off('opponentAnswered');
    _socket?.off('nextQuestion');
    _socket?.off('gameFinished');
    _socket?.off('opponentDisconnected');
    _socket?.off('teamRoomCreated');
    _socket?.off('teamRoomJoined');
    _socket?.off('teamRoomState');
    _socket?.off('teamGameStarted');
    _socket?.off('teamAnswerResult');
    _socket?.off('teamPlayerAnswered');
    _socket?.off('teamNextQuestion');
    _socket?.off('teamGameFinished');
    _socket?.off('teamsShuffled');
    _socket?.off('error');
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

