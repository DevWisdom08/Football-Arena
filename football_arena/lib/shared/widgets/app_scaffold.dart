import 'package:flutter/material.dart';

/// Reusable scaffold with consistent background image for all screens
class AppScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const AppScaffold({
    super.key,
    required this.child,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95),
              BlendMode.lighten,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

