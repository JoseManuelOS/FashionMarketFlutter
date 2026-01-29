import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/splash/presentation/pages/splash_page_animated.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Instancia del router
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPageAnimated(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailPage(productId: productId);
        },
      ),
      // Agregar más rutas aquí según las features
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}

/// Constantes de rutas
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

  // Helper para construir rutas con parámetros
  static String productDetailById(String id) => '/product/$id';
}
