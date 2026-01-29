import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import 'app_button.dart';

/// Widget para mostrar estados de error
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryText = 'Reintentar',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: retryText,
                onPressed: onRetry,
                type: AppButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
class AppEmptyWidget extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData icon;

  const AppEmptyWidget({
    super.key,
    this.title,
    required this.message,
    this.onAction,
    this.actionText,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                type: AppButtonType.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar que no hay conexión
class AppNoConnectionWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const AppNoConnectionWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.wifi_off,
      title: 'Sin conexión',
      message: 'No hay conexión a internet. Verifica tu conexión e intenta de nuevo.',
      onRetry: onRetry,
    );
  }
}
