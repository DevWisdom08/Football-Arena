import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/top_notification.dart';

class TeamMatchScreen extends ConsumerStatefulWidget {
  const TeamMatchScreen({super.key});

  @override
  ConsumerState<TeamMatchScreen> createState() => _TeamMatchScreenState();
}

class _TeamMatchScreenState extends ConsumerState<TeamMatchScreen> {
  final _roomCodeController = TextEditingController();
  final _roomNameController = TextEditingController();
  final _roundsController = TextEditingController(text: '10');
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    final socketService = ref.read(socketServiceProvider);
    socketService.connect();

    socketService.onTeamRoomCreated((data) {
      if (mounted) {
        final roomId = data['roomId'];
        final roomCode = data['roomCode'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room created: $roomCode'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(
          RouteNames.teamMatchLobby,
          extra: {'roomId': roomId, 'roomCode': roomCode, 'myTeam': 'A'},
        );
      }
    });

    socketService.onTeamRoomJoined((data) {
      if (mounted) {
        final roomId = data['roomId'];
        final roomCode = data['roomCode'];
        final team = data['team'];

        context.go(
          RouteNames.teamMatchLobby,
          extra: {'roomId': roomId, 'roomCode': roomCode, 'myTeam': team},
        );
      }
    });

    socketService.onError((data) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'An error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  void _createRoom() {
    final userData = StorageService.instance.getUserData();
    final userId = StorageService.instance.getUserId();

    if (userId == null) {
      TopNotification.show(
        context,
        message: 'Please login first',
        type: NotificationType.error,
      );
      return;
    }

    // Validate rounds
    final roundsText = _roundsController.text.trim();
    if (roundsText.isEmpty) {
      TopNotification.show(
        context,
        message: context.l10n.roundsInvalid,
        type: NotificationType.error,
      );
      return;
    }

    final rounds = int.tryParse(roundsText);
    if (rounds == null || rounds < 5 || rounds > 30) {
      TopNotification.show(
        context,
        message: context.l10n.roundsInvalid,
        type: NotificationType.error,
      );
      return;
    }

    // Validate room name length if provided
    final roomName = _roomNameController.text.trim();
    if (roomName.isNotEmpty && roomName.length > 50) {
      TopNotification.show(
        context,
        message: 'Room name must be 50 characters or less',
        type: NotificationType.error,
      );
      return;
    }

    setState(() => _isCreating = true);

    final socketService = ref.read(socketServiceProvider);
    
    // Wait for connection before creating room
    socketService.whenConnected(() {
      if (!mounted) return;
      
      print('Creating team room...');
      socketService.createTeamRoom(
        userId: userId,
        username: userData?['username'] ?? 'Player',
        maxPlayers: 10,
        roomName: roomName.isEmpty ? null : roomName,
        rounds: rounds,
        questionsPerRound: 1,
      );
    });

    // Timeout after 10 seconds if still creating
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isCreating) {
        setState(() => _isCreating = false);
        TopNotification.show(
          context,
          message: 'Connection timeout. Please try again.',
          type: NotificationType.error,
        );
      }
    });
  }

  void _joinRoom() {
    final roomCode = _roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (roomCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room code must be 6 characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userData = StorageService.instance.getUserData();
    final userId = StorageService.instance.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final socketService = ref.read(socketServiceProvider);
    
    // Wait for connection before joining room
    socketService.whenConnected(() {
      if (!mounted) return;
      
      print('Joining team room: $roomCode');
      socketService.joinTeamRoom(
        userId: userId,
        username: userData?['username'] ?? 'Player',
        roomCode: roomCode,
      );
    });

    // Timeout after 10 seconds if still trying to join
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isCreating) {
        setState(() => _isCreating = false);
        TopNotification.show(
          context,
          message: 'Connection timeout. Please try again.',
          type: NotificationType.error,
        );
      }
    });
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _roomNameController.dispose();
    _roundsController.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Team Match',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.teamMatchGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.groups,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Team Match Mode',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.heading,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Compete in teams of up to 10 players!\nCreate a room or join with a code.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Create Room Card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.teamMatchGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withOpacity(0.95),
                          Colors.deepOrange.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icon with background
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Create New Room',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new game and invite friends',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Room Settings Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Room Settings',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Room name field
                              Text(
                                context.l10n.roomNameOptional,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _roomNameController,
                                  maxLength: 50,
                                  decoration: InputDecoration(
                                    hintText: context.l10n.roomNameHint,
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.meeting_room,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Rounds field
                              Text(
                                context.l10n.numberOfRounds,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _roundsController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: context.l10n.roundsHint,
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.repeat,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.info_outline,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (value) {
                                    // Validate on change
                                    final rounds = int.tryParse(value);
                                    if (value.isNotEmpty &&
                                        (rounds == null ||
                                            rounds < 5 ||
                                            rounds > 30)) {
                                      // Show subtle hint but don't block
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${context.l10n.roundsMin} • ${context.l10n.roundsMax}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Create button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : _createRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.deepOrange,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Create Room',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 24),

                // Join Room Card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.cardBackground,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cardBackground,
                          AppColors.cardBackground.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icon with animated background
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.login_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Join Existing Room',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-character room code',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Room code input with special styling
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _roomCodeController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 6,
                            ),
                            maxLength: 6,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'ABC123',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                letterSpacing: 6,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Join button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : _joinRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Join Room',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[300],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How it works:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[200],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '• Up to 10 players\n'
                              '• Divided into 2 teams\n'
                              '• Team with highest score wins\n'
                              '• All players answer same questions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
