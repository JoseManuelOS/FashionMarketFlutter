import 'package:animated_path/animated_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../utils/fashion_market_paths.dart';

/// Splash Screen con animación del logo "FashionMarket"
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Inicia la animación
    _animationController.forward();

    // Navega a la home después de la animación
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcula la escala según el ancho de la pantalla
            final maxWidth = constraints.maxWidth * 0.85;
            final baseWidth = FashionMarketPaths.getTotalWidth(1.0);
            final scale = (maxWidth / baseWidth).clamp(0.3, 1.5);

            // Centrar el path
            final totalWidth = FashionMarketPaths.getTotalWidth(scale);
            final totalHeight = 70 * scale;
            final offsetX = (constraints.maxWidth - totalWidth) / 2;
            final offsetY = (constraints.maxHeight - totalHeight) / 2;

            final paint = Paint()
              ..color = AppColors.primary
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5 * scale
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round;

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _FashionMarketPainter(
                    animation: _animationController,
                    scale: scale,
                    offset: Offset(offsetX, offsetY),
                    strokePaint: paint,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter que usa AnimatedPath internamente
class _FashionMarketPainter extends CustomPainter {
  final Animation<double> animation;
  final double scale;
  final Offset offset;
  final Paint strokePaint;

  _FashionMarketPainter({
    required this.animation,
    required this.scale,
    required this.offset,
    required this.strokePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = FashionMarketPaths.getFullPath(scale: scale, offset: offset);
    
    // Valores de animación para efecto de "dibujo"
    final startValue = Tween<double>(begin: 0.0, end: 0.0).evaluate(animation);
    final endValue = Tween<double>(begin: 0.0, end: 1.0).evaluate(animation);

    // Dibujar cada segmento del path
    for (final metric in path.computeMetrics()) {
      final metricStart = startValue * metric.length;
      final metricEnd = endValue * metric.length;

      if (metricEnd > metricStart) {
        final extractedPath = metric.extractPath(metricStart, metricEnd);
        canvas.drawPath(extractedPath, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_FashionMarketPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}
