import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.borderRadius = 26,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? (backgroundColor ?? AppColors.cardBackground) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: AppColors.border),
      boxShadow: boxShadow ??
          const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Ink(
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}

