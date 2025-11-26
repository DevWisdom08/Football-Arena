import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/storage_service.dart';
import '../../core/routes/route_names.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () => _showLogoutDialog(context),
      tooltip: 'Logout',
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear all auth data
              await StorageService.instance.clearAuthData();
              
              if (!context.mounted) return;
              
              // Go to login
              Navigator.pop(context); // Close dialog
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

