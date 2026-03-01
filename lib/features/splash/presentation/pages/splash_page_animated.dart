import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../utils/fashion_market_paths.dart';

/// Splash Screen con animación de "trim path" dibujando "FashionMarket"
class SplashPageAnimated extends StatefulWidget {
  const SplashPageAnimated({super.key});

  @override
  State<SplashPageAnimated> createState() => _SplashPageAnimatedState();
}

class _SplashPageAnimatedState extends State<SplashPageAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  /// Bandera estática para mostrar la animación solo una vez por sesión de app
  static bool _hasShownSplash = false;

  @override
  void initState() {
    super.initState();

    // Si el usuario ya tiene sesión activa o ya se mostró el splash, ir directo al home
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    if (hasSession || _hasShownSplash) {
      _hasShownSplash = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
      _animationController = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      return;
    }

    _hasShownSplash = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Iniciar la animación
    _animationController.forward();

    // Navegar al home cuando termine
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
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _FashionMarketPainter(
              animation: _animationController,
            ),
          );
        },
      ),
    );
  }
}

/// Painter que dibuja el texto "FashionMarket" con animación de trim path
class _FashionMarketPainter extends CustomPainter {
  final Animation<double> animation;

  _FashionMarketPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final maxWidth = size.width * 0.85;
    final baseWidth = FashionMarketPaths.getTotalWidth(1.0);
    final scale = (maxWidth / baseWidth).clamp(0.3, 1.5);

    final totalWidth = FashionMarketPaths.getTotalWidth(scale);
    final totalHeight = 70 * scale;
    final offsetX = (size.width - totalWidth) / 2;
    final offsetY = (size.height - totalHeight) / 2;

    final paint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fullPath = FashionMarketPaths.getFullPath(
      scale: scale,
      offset: Offset(offsetX, offsetY),
    );

    // Calcular la longitud total del path
    final pathMetrics = fullPath.computeMetrics();
    double totalLength = 0;
    for (final metric in pathMetrics) {
      totalLength += metric.length;
    }

    // Calcular cuánto del path dibujar basado en la animación
    final currentLength = totalLength * animation.value;

    // Extraer y dibujar solo la porción animada
    final animatedPath = _extractPath(fullPath, currentLength);
    canvas.drawPath(animatedPath, paint);
  }

  Path _extractPath(Path originalPath, double length) {
    final path = Path();
    double remainingLength = length;

    for (final metric in originalPath.computeMetrics()) {
      if (remainingLength <= 0) break;

      if (remainingLength >= metric.length) {
        path.addPath(metric.extractPath(0, metric.length), Offset.zero);
        remainingLength -= metric.length;
      } else {
        path.addPath(metric.extractPath(0, remainingLength), Offset.zero);
        remainingLength = 0;
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(_FashionMarketPainter oldDelegate) => true;
}
