import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/auth_api_service.dart';
import '../../../core/extensions/localization_extensions.dart';
import '../../../shared/widgets/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authApiServiceProvider);
      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save auth token and user data
      final token = result['access_token'];
      final user = result['user'];

      await StorageService.instance.saveAuthToken(token);
      await StorageService.instance.saveUserId(user['id']);
      await StorageService.instance.saveUserData(user);

      if (!mounted) return;

      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authApiServiceProvider);
      final result = await authService.guestLogin();

      // Save auth token and user data
      final token = result['access_token'];
      final user = result['user'];

      await StorageService.instance.saveAuthToken(token);
      await StorageService.instance.saveUserId(user['id']);
      await StorageService.instance.saveUserData(user);

      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (!Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apple Sign-In is only available on iOS devices.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final appleId = credential.userIdentifier ?? '';
      final email = credential.email ?? '${appleId}@privaterelay.appleid.com';
      final name = [
        credential.givenName ?? '',
        credential.familyName ?? '',
      ].where((p) => p.isNotEmpty).join(' ');
      final displayName = name.isNotEmpty ? name : 'Apple User';

      final authService = ref.read(authApiServiceProvider);
      final result = await authService.appleSignIn(
        appleId: appleId,
        email: email,
        name: displayName,
      );

      // Save auth token and user data
      final token = result['access_token'];
      final user = result['user'];

      await StorageService.instance.saveAuthToken(token);
      await StorageService.instance.saveUserId(user['id']);
      await StorageService.instance.saveUserData(user);

      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Cancelled
        setState(() => _isLoading = false);
        return;
      }

      final googleId = googleUser.id;
      final mockEmail = googleUser.email;
      final finalName =
          (googleUser.displayName == null || googleUser.displayName!.isEmpty)
          ? 'Google User'
          : googleUser.displayName!;

      final authService = ref.read(authApiServiceProvider);
      final result = await authService.googleSignIn(
        googleId: googleId,
        email: mockEmail,
        name: finalName,
      );

      // Save auth token and user data
      final token = result['access_token'];
      final user = Map<String, dynamic>.from(result['user']);

      // Ensure username is present and properly formatted
      if (user['username'] == null ||
          user['username'].toString().trim().isEmpty ||
          user['username'].toString().startsWith('Google_')) {
        // Use the name we sent
        user['username'] = finalName;
      }

      await StorageService.instance.saveAuthToken(token);
      await StorageService.instance.saveUserId(user['id']);
      await StorageService.instance.saveUserData(user);

      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Blurred background layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Content layer
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.welcomeBack,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.welcomeDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
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
                            return context.l10n.pleaseEnterEmail;
                          }
                          if (!value.contains('@')) {
                            return context.l10n.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: context.l10n.password,
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              );
                            },
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
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
                            return context.l10n.pleaseEnterPassword;
                          }
                          if (value.length < 6) {
                            return context.l10n.passwordMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.push(RouteNames.forgotPassword),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            context.l10n.forgotPassword,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login button
                      CustomButton(
                        text: context.l10n.login,
                        type: ButtonType.gradient,
                        gradient: AppColors.primaryGradient,
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Guest login
                      CustomButton(
                        text: context.l10n.continueAsGuest,
                        type: ButtonType.outlined,
                        onPressed: _isLoading ? null : _handleGuestLogin,
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${context.l10n.dontHaveAccount} ',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.register),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            child: Text(
                              context.l10n.signUp,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Social login divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.border.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.border.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social login buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.apple,
                              label: 'Apple',
                              onPressed: _handleAppleSignIn,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onPressed: _handleGoogleSignIn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 24), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
