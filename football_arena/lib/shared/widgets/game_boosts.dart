import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Boost types available in games
enum BoostType {
  extraTime,    // Add 5 seconds to timer
  skip,         // Skip current question
  revealWrong,  // Reveal one wrong option
}

/// Boost configuration
class BoostConfig {
  final BoostType type;
  final String name;
  final IconData icon;
  final int cost;
  final String description;

  const BoostConfig({
    required this.type,
    required this.name,
    required this.icon,
    required this.cost,
    required this.description,
  });

  static const List<BoostConfig> all = [
    BoostConfig(
      type: BoostType.extraTime,
      name: 'Extra Time',
      icon: Icons.timer,
      cost: 20,
      description: 'Add 5 seconds to timer',
    ),
    BoostConfig(
      type: BoostType.skip,
      name: 'Skip',
      icon: Icons.skip_next,
      cost: 30,
      description: 'Skip this question',
    ),
    BoostConfig(
      type: BoostType.revealWrong,
      name: 'Reveal Wrong',
      icon: Icons.visibility_off,
      cost: 25,
      description: 'Remove one wrong option',
    ),
  ];
}

/// Widget to display boost buttons in game screens
class GameBoosts extends StatelessWidget {
  final int availableCoins;
  final Function(BoostType) onBoostUsed;
  final List<BoostType> usedBoosts;
  final bool isAnswered;

  const GameBoosts({
    super.key,
    required this.availableCoins,
    required this.onBoostUsed,
    this.usedBoosts = const [],
    this.isAnswered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: BoostConfig.all.map((boost) {
          final isUsed = usedBoosts.contains(boost.type);
          final canAfford = availableCoins >= boost.cost;
          final canUse = !isAnswered && !isUsed && canAfford;

          return _BoostButton(
            boost: boost,
            isUsed: isUsed,
            canUse: canUse,
            onTap: canUse ? () => onBoostUsed(boost.type) : null,
          );
        }).toList(),
      ),
    );
  }
}

class _BoostButton extends StatelessWidget {
  final BoostConfig boost;
  final bool isUsed;
  final bool canUse;
  final VoidCallback? onTap;

  const _BoostButton({
    required this.boost,
    required this.isUsed,
    required this.canUse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed
              ? Colors.grey.withOpacity(0.3)
              : canUse
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUsed
                ? Colors.grey
                : canUse
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              boost.icon,
              color: isUsed
                  ? Colors.grey
                  : canUse
                      ? AppColors.primary
                      : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              boost.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUsed
                    ? Colors.grey
                    : canUse
                        ? Colors.white
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/coin_icon.png',
                  width: 12,
                  height: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${boost.cost}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isUsed
                        ? Colors.grey
                        : canUse
                            ? AppColors.primary
                            : Colors.grey,
                  ),
                ),
              ],
            ),
            if (isUsed)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

