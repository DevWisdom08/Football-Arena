import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/extensions/localization_extensions.dart';

class AppBottomBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomBarItem(
                icon: Icons.home,
                label: context.l10n.home,
                isActive: currentIndex == 0,
                onTap: () => context.go(RouteNames.home),
              ),
              _BottomBarItem(
                icon: Icons.leaderboard,
                label: context.l10n.leaderboard,
                isActive: currentIndex == 1,
                onTap: () => context.push(RouteNames.leaderboard),
              ),
              _BottomBarItem(
                icon: Icons.people,
                label: context.l10n.friends,
                isActive: currentIndex == 2,
                onTap: () => context.push(RouteNames.friends),
              ),
              _BottomBarItem(
                icon: Icons.history,
                label: context.l10n.history,
                isActive: currentIndex == 3,
                onTap: () => context.push(RouteNames.history),
              ),
              _BottomBarItem(
                icon: Icons.person,
                label: context.l10n.profile,
                isActive: currentIndex == 4,
                onTap: () => context.push(RouteNames.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white60,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.white60,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

