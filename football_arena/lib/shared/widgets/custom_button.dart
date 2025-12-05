import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
  gradient,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Gradient? gradient;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final EdgeInsets padding;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.gradient,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius = 26,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ButtonType.gradient || gradient != null) {
      return _buildGradientButton();
    }

    return SizedBox(
      width: width,
      height: height,
      child: _buildStandardButton(),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardButton() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: 8,
          ),
          child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
        );

      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardBackground,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: 4,
          ),
          child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
        );

      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: borderColor ?? Colors.white,
            side: BorderSide(
              color: borderColor ?? AppColors.border,
              width: 1.5, // Same thickness for all outlined buttons
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
          ),
          child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: padding,
          ),
          child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
        );

      default:
        return _buildGradientButton();
    }
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

