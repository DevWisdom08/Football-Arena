import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/users_api_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/top_notification.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  // Initialize with the first country from the list to ensure it's always valid
  late String _selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default country before loading user data
    _selectedCountry = AppConstants.countries.isNotEmpty
        ? AppConstants.countries.first
        : 'UAE';
    _loadUserData();
  }

  void _loadUserData() {
    final userData = StorageService.instance.getUserData();
    if (userData != null) {
      _usernameController.text = userData['username'] ?? '';
      _emailController.text = userData['email'] ?? '';

      // Ensure the country exists in the list
      final userCountry = userData['country'] ?? 'UAE';
      if (AppConstants.countries.contains(userCountry)) {
        _selectedCountry = userCountry;
      } else {
        // Default to first country if user's country not in list
        _selectedCountry = AppConstants.countries.isNotEmpty
            ? AppConstants.countries.first
            : 'UAE';
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = StorageService.instance.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Call backend API to update user profile
      final usersService = ref.read(usersApiServiceProvider);
      final updatedUser = await usersService.updateUser(userId, {
        'username': _usernameController.text.trim(),
        'country': _selectedCountry,
      });

      // Update local storage with response from backend
      await StorageService.instance.saveUserData(updatedUser);

      if (!mounted) return;

      TopNotification.show(
        context,
        message: '✅ Profile updated successfully!',
        type: NotificationType.success,
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      TopNotification.show(
        context,
        message: e.toString().replaceAll('Exception: ', ''),
        type: NotificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Edit Profile',
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
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(
                                  Icons.sports_soccer,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.cardBackground,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Username field
                        TextFormField(
                          controller: _usernameController,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email field (read-only)
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white70),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground.withOpacity(
                              0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(
                              Icons.lock,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Country dropdown
                        DropdownButtonFormField<String>(
                          initialValue:
                              AppConstants.countries.contains(_selectedCountry)
                              ? _selectedCountry
                              : AppConstants.countries.first,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: AppColors.cardBackground,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.flag,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          items: AppConstants.countries.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCountry = value!);
                          },
                        ),

                        const SizedBox(height: 40),

                        // Save button
                        CustomButton(
                          text: _isLoading ? 'Saving...' : 'Save Changes',
                          onPressed: _isLoading ? null : _handleSave,
                          gradient: AppColors.primaryGradient,
                          icon: Icons.check,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () => context.pop(),
                          type: ButtonType.outlined,
                        ),

                        const SizedBox(height: 32),

                        // Info card
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
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Email cannot be changed for security reasons.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
