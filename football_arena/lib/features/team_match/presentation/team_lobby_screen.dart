import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/top_notification.dart';

class TeamLobbyScreen extends ConsumerStatefulWidget {
  final String? roomId;
  final String? roomCode;
  final String? myTeam;

  const TeamLobbyScreen({
    super.key,
    this.roomId,
    this.roomCode,
    this.myTeam,
  });

  @override
  ConsumerState<TeamLobbyScreen> createState() => _TeamLobbyScreenState();
}

class _TeamLobbyScreenState extends ConsumerState<TeamLobbyScreen> {
  String? roomId;
  String? roomCode;
  String? myTeam;
  List<Map<String, dynamic>> teamAPlayers = [];
  List<Map<String, dynamic>> teamBPlayers = [];
  String? hostId;
  String? roomName;
  int? rounds;
  int playerCount = 0;
  int maxPlayers = 10;
  String status = 'waiting';
  bool isHost = false;

  @override
  void initState() {
    super.initState();
    roomId = widget.roomId;
    roomCode = widget.roomCode;
    myTeam = widget.myTeam;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);

    socketService.onTeamRoomState((data) {
      setState(() {
        roomCode = data['roomCode'];
        hostId = data['hostId'];
        roomName = data['roomName'];
        rounds = data['rounds'];
        playerCount = data['playerCount'];
        maxPlayers = data['maxPlayers'];
        status = data['status'];
        
        teamAPlayers = List<Map<String, dynamic>>.from(data['teamA'] ?? []);
        teamBPlayers = List<Map<String, dynamic>>.from(data['teamB'] ?? []);
      });

      // Check if current user is host
      final userId = StorageService.instance.getUserId();
      isHost = userId == hostId;
    });

    socketService.onTeamsShuffled((data) {
      if (mounted) {
        TopNotification.show(
          context,
          message: context.l10n.teamsShuffled,
          type: NotificationType.success,
        );
      }
    });

    socketService.onTeamGameStarted((data) {
      if (mounted) {
        context.go(RouteNames.teamMatchGame, extra: {
          'roomId': roomId,
          'question': data['question'],
          'questionNumber': data['questionNumber'],
          'totalQuestions': data['totalQuestions'],
        });
      }
    });

    socketService.onError((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'An error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  void _copyRoomCode() {
    if (roomCode != null) {
      Clipboard.setData(ClipboardData(text: roomCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room code copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _startGame() {
    if (roomId != null && isHost) {
      final socketService = ref.read(socketServiceProvider);
      socketService.startTeamGame(roomId!);
    }
  }

  void _shuffleTeams() {
    if (roomId == null || !isHost) {
      TopNotification.show(
        context,
        message: context.l10n.onlyHostCanShuffle,
        type: NotificationType.warning,
      );
      return;
    }

    if (status != 'waiting') {
      TopNotification.show(
        context,
        message: context.l10n.cannotShuffleAfterStart,
        type: NotificationType.warning,
      );
      return;
    }

    if (playerCount < 2) {
      TopNotification.show(
        context,
        message: context.l10n.needTwoPlayersToShuffle,
        type: NotificationType.warning,
      );
      return;
    }

    final socketService = ref.read(socketServiceProvider);
    socketService.shuffleTeams(roomId!);
    
    TopNotification.show(
      context,
      message: context.l10n.shufflingTeams,
      type: NotificationType.info,
    );
  }

  void _leaveRoom() {
    final socketService = ref.read(socketServiceProvider);
    socketService.leaveTeamRoom();
    socketService.disconnect();
    context.go(RouteNames.home);
  }


  @override
  void dispose() {
    final socketService = ref.read(socketServiceProvider);
    socketService.offAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/team_match_back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _leaveRoom,
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Leave Room',
                    ),
                    const Text(
                      'Team Match Lobby',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),

              // Room Code Card
              if (roomCode != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomCard(
                    gradient: AppColors.primaryGradient,
                    child: Column(
                      children: [
                        const Text(
                          'Room Code',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              roomCode!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _copyRoomCode,
                              icon: const Icon(Icons.copy, color: Colors.white),
                              tooltip: 'Copy code',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Share this code with friends!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              if (roomName != null || rounds != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: CustomCard(
                    backgroundColor: AppColors.cardBackground,
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (roomName != null && roomName!.isNotEmpty)
                                Text(
                                  roomName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              if (rounds != null)
                                Text(
                                  'Rounds: $rounds',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Player Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Players',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$playerCount/$maxPlayers',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Teams
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Team A
                      _buildTeam('Team A', teamAPlayers, Colors.blue),
                      const SizedBox(height: 20),
                      
                      // VS Divider
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Team B
                      _buildTeam('Team B', teamBPlayers, Colors.red),
                    ],
                  ),
                ),
              ),


              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (isHost && playerCount >= 2)
                      CustomButton(
                        text: 'Start Game',
                        onPressed: _startGame,
                        gradient: AppColors.primaryGradient,
                      ),
                    if (isHost && playerCount < 2)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Waiting for at least 2 players...',
                          style: TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!isHost)
                      const Text(
                        'Waiting for host to start the game...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (isHost)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: CustomButton(
                          text: context.l10n.shuffleTeams,
                          type: ButtonType.outlined,
                          icon: Icons.shuffle,
                          onPressed: playerCount >= 2 && status == 'waiting'
                              ? _shuffleTeams
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(String teamName, List<Map<String, dynamic>> players, Color teamColor) {
    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: teamColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                teamName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: teamColor,
                ),
              ),
              const Spacer(),
              Text(
                '${players.length} players',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (players.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No players yet',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...players.map((player) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPlayerTile(player, teamColor),
            )),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> player, Color teamColor) {
    final isReady = player['ready'] ?? false;
    final username = player['username'] ?? 'Unknown';
    final isMe = player['userId'] == StorageService.instance.getUserId();
    final isHostPlayer = player['userId'] == hostId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColors.primary : Colors.white12,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: teamColor.withOpacity(0.3),
            ),
            child: Icon(
              Icons.person,
              color: teamColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (isHostPlayer) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isReady)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
          else
            Icon(
              Icons.radio_button_unchecked,
              color: Colors.white38,
              size: 24,
            ),
        ],
      ),
    );
  }
}

