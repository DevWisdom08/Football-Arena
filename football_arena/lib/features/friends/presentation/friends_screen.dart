import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/friends_api_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/app_bottom_bar.dart';
import '../../../shared/widgets/top_notification.dart';
import '../../../core/extensions/localization_extensions.dart';

final friendsApiServiceProvider = Provider<FriendsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return FriendsApiService(dio);
});

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = false;
  String? errorMessage;
  String? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      setState(() {
        userId = userData['id'];
      });
      _loadFriends();
      _loadPendingRequests();
    } else {
      setState(() {
        errorMessage = 'Please login to view friends';
      });
    }
  }

  Future<void> _loadFriends() async {
    if (userId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      final data = await friendsService.getFriends(userId!);

      setState(() {
        friends = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadPendingRequests() async {
    if (userId == null) return;

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      final data = await friendsService.getPendingRequests(userId!);

      setState(() {
        pendingRequests = data;
      });
    } catch (e) {
      // Silently fail for requests, show error only if critical
      if (mounted) {
        setState(() {
          if (pendingRequests.isEmpty) {
            pendingRequests = [];
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // TODO: Show add friend dialog
                        _showAddFriendDialog();
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white54,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Friends'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${friends.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Requests'),
                        if (pendingRequests.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${pendingRequests.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildFriendsTab(), _buildRequestsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomBar(currentIndex: 2),
    );
  }

  Widget _buildFriendsTab() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 20),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadFriends,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              context.l10n.noFriendsYet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.addFriendsToChallenge,
              style: const TextStyle(fontSize: 14, color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFriendCard(friend),
          );
        },
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              context.l10n.noPendingRequests,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          final request = pendingRequests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRequestCard(request),
          );
        },
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final isOnline = friend['online'] ?? false;

    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend['username'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Level ${friend['level']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(' · ', style: TextStyle(color: Colors.white54)),
                    Text(
                      friend['country'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'challenge',
                child: Row(
                  children: [
                    Icon(Icons.gamepad, size: 20),
                    SizedBox(width: 12),
                    Text('Challenge'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Remove Friend', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'remove') {
                await _removeFriend(
                  friend['friendId'] ?? friend['id'] ?? friend['userId'],
                );
              } else if (value == 'challenge') {
                // Navigate to 1v1 challenge
                context.push(RouteNames.challenge1v1);
                TopNotification.show(
                  context,
                  message: 'Challenge your friend in 1v1 mode!',
                  type: NotificationType.info,
                );
              } else if (value == 'profile') {
                // Navigate to profile screen (currently shows own profile)
                // In future: pass friendId to view friend's profile
                context.push(RouteNames.profile);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return CustomCard(
      backgroundColor: AppColors.cardBackground,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['username'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Level ${request['level']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(' · ', style: TextStyle(color: Colors.white54)),
                    Text(
                      request['country'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _acceptRequest(request['id']),
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
              IconButton(
                onPressed: () => _rejectRequest(request['id']),
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String requestId) async {
    if (userId == null) return;

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      await friendsService.acceptFriendRequest(
        requestId: requestId,
        userId: userId!,
      );

      TopNotification.show(
        context,
        message: context.l10n.friendRequestAccepted,
        type: NotificationType.success,
      );

      await _loadPendingRequests();
      await _loadFriends();
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    if (userId == null) return;

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      await friendsService.rejectFriendRequest(
        requestId: requestId,
        userId: userId!,
      );

      TopNotification.show(
        context,
        message: context.l10n.friendRequestRejected,
        type: NotificationType.success,
      );

      await _loadPendingRequests();
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  Future<void> _removeFriend(String friendId) async {
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          context.l10n.removeFriend,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.removeFriendConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.remove),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      await friendsService.removeFriend(userId: userId!, friendId: friendId);

      TopNotification.show(
        context,
        message: context.l10n.friendRemoved,
        type: NotificationType.success,
      );

      await _loadFriends();
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  void _showAddFriendDialog() {
    final TextEditingController controller = TextEditingController();
    bool isSearching = false;
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            context.l10n.addFriend,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: context.l10n.enterUsernameOrEmail,
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (value) async {
                    if (value.length >= 3) {
                      setDialogState(() => isSearching = true);
                      try {
                        final friendsService = ref.read(
                          friendsApiServiceProvider,
                        );
                        final results = await friendsService.searchUsers(value);
                        setDialogState(() {
                          searchResults = results;
                          isSearching = false;
                        });
                      } catch (e) {
                        setDialogState(() => isSearching = false);
                      }
                    } else {
                      setDialogState(() => searchResults = []);
                    }
                  },
                ),
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                if (searchResults.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          title: Text(
                            user['username'] ?? user['email'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Level ${user['level'] ?? 1}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.person_add,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _sendFriendRequest(user['id']),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            if (controller.text.isNotEmpty && searchResults.isEmpty)
              ElevatedButton(
                onPressed: () {
                  // Try to send request by username/email
                  _sendFriendRequestByQuery(controller.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(context.l10n.sendRequest),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    if (userId == null) return;

    Navigator.pop(context); // Close dialog

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      await friendsService.sendFriendRequest(
        senderId: userId!,
        receiverId: receiverId,
      );

      TopNotification.show(
        context,
        message: context.l10n.friendRequestSent,
        type: NotificationType.success,
      );
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }

  Future<void> _sendFriendRequestByQuery(String query) async {
    if (userId == null) return;

    try {
      final friendsService = ref.read(friendsApiServiceProvider);
      final users = await friendsService.searchUsers(query);

      if (users.isEmpty) {
        TopNotification.show(
          context,
          message: context.l10n.userNotFound,
          type: NotificationType.error,
        );
        return;
      }

      await _sendFriendRequest(users.first['id']);
    } catch (e) {
      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    }
  }
}
