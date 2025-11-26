import 'package:flutter/material.dart';

class AppColors {
  // ========== PREMIUM DARK THEME COLORS ==========

  // Backgrounds - Deep & Rich
  static const background = Color(0xFF0A0E27); // Deep navy blue
  static const cardBackground = Color(0xFF1A1F3A); // Dark blue-gray
  static const cardBackgroundLight = Color(0xFF252B48); // Lighter blue-gray

  // Primary Colors - Vibrant Gold
  static const primary = Color(0xFFFFD700); // Vibrant gold
  static const primaryDark = Color(0xFFFFA500); // Orange-gold
  static const primaryLight = Color(0xFFFFE57F); // Light gold
  static const heading = Color(0xFFFFE57F); // Warm golden heading
  static const accent = Color(0xFF00D9FF); // Cyan accent

  // Gradients - Premium Dark
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E27), // Deep navy
      Color(0xFF161B33), // Medium navy
      Color(0xFF0D1126), // Dark navy
    ],
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF1A1F3A), Color(0xFF252B48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFA500), // Orange
      Color(0xFFFF8C00), // Deep orange
    ],
  );

  static const xpGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
  );

  // Game Mode Gradients - Vibrant on Dark
  static const soloModeGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)], // Blue
  );

  static const challenge1v1Gradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)], // Red
  );

  static const teamMatchGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)], // Orange
  );

  static const leaderboardGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFC107)], // Gold
  );

  static const dailyQuizGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)], // Purple
  );

  static const coinsGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)], // Green
  );

  static const streakGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFF9100)], // Orange-fire
  );

  static const statsGradient = LinearGradient(
    colors: [Color(0xFF00ACC1), Color(0xFF26C6DA)], // Cyan
  );

  static const storeGradient = LinearGradient(
    colors: [Color(0xFFEC407A), Color(0xFFF06292)], // Pink
  );

  // Text Colors - Light on Dark
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB0B8C1); // Light gray
  static const textTertiary = Color(0xFF6C757D); // Medium gray
  static const textOnPrimary = Colors.white;

  // Status Colors
  static const success = Color(0xFF4CAF50); // Green
  static const error = Color(0xFFEF5350); // Red
  static const warning = Color(0xFFFF9800); // Orange
  static const info = Color(0xFF2196F3); // Blue

  // UI Elements
  static const border = Color(0xFF2A3F5F); // Blue border
  static const overlay = Color(0x1AFFFFFF); // Light overlay
  static const divider = Color(0xFF2A3F5F); // Blue divider

  // Shadow - Enhanced for dark theme
  static const shadow = Color(0x40000000); // Medium shadow
  static const shadowDark = Color(0x60000000); // Dark shadow
  static const shadowLight = Color(0x20000000); // Light shadow
}
