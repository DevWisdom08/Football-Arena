import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../shared/widgets/custom_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from storage
    notificationsEnabled =
        StorageService.instance.getBool('notifications') ?? true;
    soundEnabled = StorageService.instance.getBool('sound') ?? true;
    vibrationEnabled = StorageService.instance.getBool('vibration') ?? true;
    setState(() {});
  }

  void _saveSetting(String key, dynamic value) {
    if (value is bool) {
      StorageService.instance.setBool(key, value);
    } else if (value is String) {
      StorageService.instance.setString(key, value);
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear cache logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _logout() {
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
              await StorageService.instance.clearAuthData();
              if (!mounted) return;
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Football Arena Privacy Policy\n\n'
            '1. Data Collection\n'
            'We collect minimal data necessary for game functionality including username, email, game statistics, and progress.\n\n'
            '2. Data Usage\n'
            'Your data is used solely to provide game services, track progress, and enable multiplayer features.\n\n'
            '3. Data Storage\n'
            'All data is securely stored in encrypted databases and never shared with third parties.\n\n'
            '4. User Rights\n'
            'You can request data deletion or export at any time by contacting support.\n\n'
            '5. Cookies & Storage\n'
            'We use local storage for authentication tokens and user preferences only.\n\n'
            'Last updated: November 2024',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Football Arena Terms of Service\n\n'
            '1. Acceptance\n'
            'By using this app, you agree to these terms.\n\n'
            '2. User Conduct\n'
            'Users must not cheat, exploit bugs, or harass others.\n\n'
            '3. Account Security\n'
            'You are responsible for maintaining account security.\n\n'
            '4. Virtual Currency\n'
            'Coins and XP have no real-world value and cannot be exchanged for money.\n\n'
            '5. Service Availability\n'
            'We strive for 99% uptime but cannot guarantee uninterrupted service.\n\n'
            '6. Changes to Terms\n'
            'We may update these terms at any time.\n\n'
            '7. Termination\n'
            'We reserve the right to terminate accounts that violate these terms.\n\n'
            'Last updated: November 2024',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
              Colors.white.withOpacity(0.1),
              BlendMode.lighten,
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
                      'Settings',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifications Section
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.notifications,
                              title: 'Push Notifications',
                              subtitle: 'Get notified about challenges',
                              value: notificationsEnabled,
                              onChanged: (value) {
                                setState(() => notificationsEnabled = value);
                                _saveSetting('notifications', value);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sound & Vibration
                      const Text(
                        'Sound & Haptics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.volume_up,
                              title: 'Sound Effects',
                              subtitle: 'Play sound effects',
                              value: soundEnabled,
                              onChanged: (value) {
                                setState(() => soundEnabled = value);
                                _saveSetting('sound', value);
                              },
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            _buildSwitchTile(
                              icon: Icons.vibration,
                              title: 'Vibration',
                              subtitle: 'Haptic feedback',
                              value: vibrationEnabled,
                              onChanged: (value) {
                                setState(() => vibrationEnabled = value);
                                _saveSetting('vibration', value);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Language
                      const Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: ListTile(
                          leading: const Icon(
                            Icons.language,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            context.l10n.language,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Builder(
                            builder: (context) {
                              final currentLocale = ref.read(localeProvider);
                              return Text(
                                currentLocale.languageCode == 'ar'
                                    ? context.l10n.arabic
                                    : context.l10n.english,
                                style: const TextStyle(color: Colors.white70),
                              );
                            },
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            final currentLocale = ref.read(localeProvider);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(context.l10n.selectLanguage),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text(context.l10n.english),
                                      leading: Radio<Locale>(
                                        value: const Locale('en'),
                                        groupValue: currentLocale,
                                        onChanged: (value) {
                                          if (value != null) {
                                            ref.read(localeProvider.notifier).setLocale(value);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(context.l10n.arabic),
                                      leading: Radio<Locale>(
                                        value: const Locale('ar'),
                                        groupValue: currentLocale,
                                        onChanged: (value) {
                                          if (value != null) {
                                            ref.read(localeProvider.notifier).setLocale(value);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Data & Storage
                      const Text(
                        'Data & Storage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.cached,
                                color: AppColors.primary,
                              ),
                              title: const Text(
                                'Clear Cache',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                'Free up storage space',
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                              onTap: _clearCache,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomCard(
                        backgroundColor: AppColors.cardBackground,
                        child: Column(
                          children: [
                            const ListTile(
                              leading: Icon(
                                Icons.info,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                'Version',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '1.0.0',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.privacy_tip,
                                color: AppColors.primary,
                              ),
                              title: const Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                            onTap: () {
                              _showPrivacyPolicy();
                            },
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.description,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                            onTap: () {
                              _showTermsOfService();
                            },
                          ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
