import 'package:flutter/material.dart';
import 'animated_football.dart';

/// Reusable football-themed loading animation
class FootballLoading extends StatelessWidget {
  final double size;
  final String? message;

  const FootballLoading({super.key, this.size = 150, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedFootball(size: size * 0.6), // Make football proportional
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen football loading overlay
class FootballLoadingScreen extends StatelessWidget {
  final String? message;

  const FootballLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF161B33), Color(0xFF0D1126)],
          ),
        ),
        child: FootballLoading(size: 200, message: message ?? 'Loading...'),
      ),
    );
  }
}
