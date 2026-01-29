import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Indicador de carga circular
class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Loader de pantalla completa con overlay
class AppFullScreenLoader extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const AppFullScreenLoader({
    super.key,
    this.message,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLoader(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra el loader como overlay
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppFullScreenLoader(message: message),
    );
  }

  /// Oculta el loader
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Shimmer/Skeleton loader para contenido
class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.grey200,
                AppColors.grey100,
                AppColors.grey200,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton de una card de producto
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmer(height: 150, borderRadius: 8),
            const SizedBox(height: 12),
            const AppShimmer(height: 16, width: 120),
            const SizedBox(height: 8),
            AppShimmer(height: 14, width: MediaQuery.of(context).size.width * 0.6),
            const SizedBox(height: 8),
            const AppShimmer(height: 20, width: 80),
          ],
        ),
      ),
    );
  }
}
