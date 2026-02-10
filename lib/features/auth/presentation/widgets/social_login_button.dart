import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Botón para login social (Google, Apple, etc.)
class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? icon;
  final Widget? iconWidget;
  final String label;
  final Color? backgroundColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    required this.label,
    this.backgroundColor,
  });

  /// Constructor rápido para Google
  factory SocialLoginButton.google({
    Key? key,
    required VoidCallback onPressed,
  }) {
    return SocialLoginButton(
      key: key,
      onPressed: onPressed,
      label: 'Continuar con Google',
      iconWidget: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// Constructor rápido para Apple
  factory SocialLoginButton.apple({
    Key? key,
    required VoidCallback onPressed,
  }) {
    return SocialLoginButton(
      key: key,
      onPressed: onPressed,
      label: 'Continuar con Apple',
      backgroundColor: Colors.white,
      iconWidget: const Icon(Icons.apple, color: Colors.black, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApple = backgroundColor == Colors.white;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.glassLight,
          side: BorderSide(
            color: isApple ? Colors.white : AppColors.glassBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null) iconWidget!,
            if (iconWidget == null && icon != null)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isApple ? Colors.black : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
