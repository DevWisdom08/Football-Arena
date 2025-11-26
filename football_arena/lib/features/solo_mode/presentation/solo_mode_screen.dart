import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';

class SoloModeScreen extends StatefulWidget {
  const SoloModeScreen({super.key});

  @override
  State<SoloModeScreen> createState() => _SoloModeScreenState();
}

class _SoloModeScreenState extends State<SoloModeScreen> {
  final Map<String, Map<String, dynamic>> difficulties = {
    'easy': {
      'label': 'Easy',
      'icon': Icons.sentiment_satisfied,
      'color': Colors.green,
      'description': 'Perfect for beginners',
    },
    'medium': {
      'label': 'Medium',
      'icon': Icons.sentiment_neutral,
      'color': Colors.orange,
      'description': 'Moderate challenge',
    },
    'hard': {
      'label': 'Hard',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red,
      'description': 'Expert level questions',
    },
  };

  final Map<String, Map<String, dynamic>> categories = {
    'general': {
      'label': 'General',
      'icon': Icons.sports_soccer,
      'color': AppColors.primary,
    },
    'worldCup': {
      'label': 'World Cup',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
    },
    'clubs': {
      'label': 'Clubs',
      'icon': Icons.group,
      'color': Colors.blue,
    },
    'players': {
      'label': 'Players',
      'icon': Icons.person,
      'color': Colors.purple,
    },
  };

  String? selectedDifficulty;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/solo_mode_back.jpg'),
            fit: BoxFit.cover,
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
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Solo Mode',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCard(
                        gradient: AppColors.soloModeGradient,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.bolt,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Solo Mode',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Test your knowledge with a quick quiz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Game Info
                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Game Info',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.heading,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.question_answer,
                              label: 'Questions',
                              value: '10 Questions',
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.timer,
                              label: 'Time per question',
                              value: '10 seconds',
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.stars,
                              label: 'Rewards',
                              value: 'XP + Coins',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Difficulty Selection
                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.difficulty,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.heading,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.l10n.difficultyDescription,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: difficulties.entries.map((entry) {
                                final key = entry.key;
                                final data = entry.value;
                                final isSelected = selectedDifficulty == key;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: key != difficulties.keys.last ? 8 : 0,
                                    ),
                                    child: _DifficultyCard(
                                      label: data['label'] as String,
                                      icon: data['icon'] as IconData,
                                      color: data['color'] as Color,
                                      description: data['description'] as String,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          selectedDifficulty =
                                              isSelected ? null : key;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Selection
                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.category,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.category,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.heading,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.l10n.categoryDescription,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: categories.entries.map((entry) {
                                final key = entry.key;
                                final data = entry.value;
                                final isSelected = selectedCategory == key;
                                return _CategoryChip(
                                  label: data['label'] as String,
                                  icon: data['icon'] as IconData,
                                  color: data['color'] as Color,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      selectedCategory =
                                          isSelected ? null : key;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Start button
                      CustomButton(
                        text: context.l10n.startQuiz,
                        type: ButtonType.gradient,
                        gradient: AppColors.soloModeGradient,
                        icon: Icons.play_arrow,
                        height: 64,
                        onPressed: () {
                          context.push(
                            RouteNames.soloModeGame,
                            extra: {
                              'difficulty': selectedDifficulty,
                              'category': selectedCategory,
                            },
                          );
                        },
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white.withOpacity(0.6),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                color: color,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
