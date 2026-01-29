import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Tipos de botón disponibles
enum AppButtonType { primary, secondary, outline, text }

/// Tamaños de botón disponibles
enum AppButtonSize { small, medium, large }

/// Botón reutilizable de la aplicación
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconOnRight;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonSize = _getButtonSize();

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          )
        : _buildContent();

    Widget button;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(buttonSize),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(buttonSize),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(buttonSize),
          ),
          child: buttonChild,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(text);
    }

    final iconWidget = Icon(icon, size: _getIconSize());
    final textWidget = Text(text);
    const spacing = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconOnRight
          ? [textWidget, spacing, iconWidget]
          : [iconWidget, spacing, textWidget],
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textPrimary,
        );
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        );
    }
  }

  Size _getButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return const Size(80, 36);
      case AppButtonSize.medium:
        return const Size(120, 44);
      case AppButtonSize.large:
        return const Size(160, 52);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppColors.textOnPrimary;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
    }
  }
}
