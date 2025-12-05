import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';

class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _status = 'Initializing...';
  bool _searching = false;
  String? _opponent;
  String? _roomId;
  String _selectedRegion = 'global';

  final List<Map<String, String>> _regions = [
    {'code': 'global', 'name': '🌍 Global'},
    {'code': 'us', 'name': '🇺🇸 United States'},
    {'code': 'eu', 'name': '🇪🇺 Europe'},
    {'code': 'asia', 'name': '🌏 Asia'},
    {'code': 'sa', 'name': '🇧🇷 South America'},
    {'code': 'africa', 'name': '🇿🇦 Africa'},
    {'code': 'oceania', 'name': '🇦🇺 Oceania'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Defer socket initialization until after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSocket();
    });
  }

  void _initializeSocket() {
    final socketService = ref.read(socketServiceProvider);
    
    // Add timeout for socket connection
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_searching && _status == 'Initializing...') {
        setState(() {
          _status = 'Connection timeout';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to connect to matchmaking server.\nPlease check your connection and try again.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.pop();
        });
      }
    });

    socketService.connect();

    // Setup listeners
    socketService.onSearchingForMatch((data) {
      setState(() {
        _status = data['message'] ?? 'Searching for opponent...';
        _searching = true;
      });
    });

    socketService.onMatchFound((data) {
      setState(() {
        _status = 'Match found!';
        _opponent = data['opponent'];
        _roomId = data['roomId'];
        _searching = false;
      });

      // Navigate to game screen after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _roomId != null) {
          context.go(
            RouteNames.challenge1v1Game,
            extra: {'roomId': _roomId, 'opponent': _opponent},
          );
        }
      });
    });

    socketService.onMatchCancelled((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Match cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
        context.pop();
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

    // Start matchmaking
    _startMatchmaking();
  }

  void _startMatchmaking() {
    final userData = StorageService.instance.getUserData();
    final savedRegion =
        StorageService.instance.getString('region') ??
        userData?['region'] ??
        'global';

    // Use selected region or saved region
    final region = _selectedRegion != 'global' ? _selectedRegion : savedRegion;

    // If no user data, try to get from storage or use defaults
    if (userData == null) {
      final userId = StorageService.instance.getUserId();

      if (userId == null) {
        // No authentication at all - redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to play 1v1 Challenge.'),
            backgroundColor: AppColors.error,
          ),
        );

        // Clear any invalid auth data and go to login
        StorageService.instance.clearAuthData();
        context.go(RouteNames.login);
        return;
      }

      // Has userId but no user data - use defaults
      final socketService = ref.read(socketServiceProvider);
      socketService.findMatch(
        userId: userId,
        username: 'Player_${userId.substring(0, 8)}',
        level: 1,
        region: region,
      );
      return;
    }

    // Normal flow with complete user data
    final socketService = ref.read(socketServiceProvider);
    socketService.findMatch(
      userId: userData['id'],
      username: userData['username'] ?? 'Player',
      level: userData['level'] ?? 1,
      region: region,
    );
  }

  void _cancelMatch() {
    final socketService = ref.read(socketServiceProvider);
    socketService.cancelMatch();
    socketService.disconnect();
    context.pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    final socketService = ref.read(socketServiceProvider);
    socketService.offAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _cancelMatch,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Text(
                      '1v1 Challenge',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),

              // Region selector (only show if not searching)
              if (!_searching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.public,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Region:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedRegion,
                            isExpanded: true,
                            dropdownColor: AppColors.cardBackground,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _regions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region['code'],
                                child: Text(region['name']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRegion = value;
                                  StorageService.instance.setString(
                                    'region',
                                    value,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Matchmaking animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: [_animationController.value * 0.8, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _searching ? Icons.search : Icons.check,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Status text
              Text(
                _status,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              if (_opponent != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'vs $_opponent',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Cancel button
              if (_searching)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: OutlinedButton(
                    onPressed: _cancelMatch,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
