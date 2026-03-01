import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/splash/presentation/pages/splash_page_animated.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/checkout/presentation/pages/checkout_screen.dart';
import '../../features/checkout/presentation/pages/checkout_success_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/admin/presentation/pages/admin_dashboard_screen.dart';
import '../../features/admin/presentation/pages/admin_orders_screen.dart';
import '../../features/admin/presentation/pages/admin_products_screen.dart';
import '../../features/admin/presentation/pages/admin_kpis_screen.dart';
import '../../features/admin/presentation/pages/admin_discount_codes_screen.dart';
import '../../features/admin/presentation/pages/admin_carousel_screen.dart';
import '../../features/admin/presentation/pages/admin_users_screen.dart';
import '../../features/admin/presentation/pages/admin_notifications_screen.dart';
import '../../features/admin/presentation/pages/admin_invoices_screen.dart';
import '../../features/admin/presentation/pages/admin_newsletter_screen.dart';
import '../../features/admin/presentation/pages/admin_animations_screen.dart';
import '../../features/admin/presentation/pages/admin_categories_screen.dart';
import '../../features/orders/presentation/pages/orders_screen.dart';
import '../../features/orders/presentation/pages/order_detail_screen.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Configuración de rutas de la aplicación usando GoRouter
/// Con StatefulShellRoute para navegación con bottom tabs
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorProductsKey = GlobalKey<NavigatorState>(debugLabel: 'shellProducts');
  static final _shellNavigatorCartKey = GlobalKey<NavigatorState>(debugLabel: 'shellCart');
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  /// En web, si el navegador ya tiene una ruta (p.ej. Stripe redirige a
  /// /checkout/success?session_id=...), usar esa ruta en vez del splash.
  static String get _initialLocation {
    if (kIsWeb) {
      final uri = Uri.base;
      final path = uri.path;
      // Rutas válidas para deep-link directo (no splash ni raíz)
      if (path.length > 1 && path != '/') {
        final query = uri.query;
        return query.isNotEmpty ? '$path?$query' : path;
      }
    }
    return AppRoutes.splash;
  }

  /// Instancia del router
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _initialLocation,
    debugLogDiagnostics: true,
    routes: [
      // ══════════════════════════════════════════════════════════════════════
      // SPLASH
      // ══════════════════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPageAnimated(),
      ),

      // ══════════════════════════════════════════════════════════════════════
      // SHELL CON BOTTOM NAVIGATION
      // ══════════════════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // ────────────────────────────────────────────────────────────────────
          // TAB 0: HOME
          // ────────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
                routes: [
                  // Categoría desde home
                  GoRoute(
                    path: 'categoria/:slug',
                    name: 'homeCategory',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      return ProductListPage(categorySlug: slug);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────────
          // TAB 1: PRODUCTOS
          // ────────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProductsKey,
            routes: [
              GoRoute(
                path: AppRoutes.products,
                name: 'products',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProductListPage(),
                ),
                routes: [
                  // Detalle de producto
                  GoRoute(
                    path: ':slug',
                    name: 'productDetail',
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      return ProductDetailPage(productId: slug);
                    },
                  ),
                ],
              ),
              // Categoría
              GoRoute(
                path: AppRoutes.category,
                name: 'category',
                builder: (context, state) {
                  final slug = state.pathParameters['slug'] ?? '';
                  return ProductListPage(categorySlug: slug);
                },
              ),
              // Ofertas
              GoRoute(
                path: AppRoutes.offers,
                name: 'offers',
                builder: (context, state) => const ProductListPage(isOffers: true),
              ),
              // Búsqueda
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) {
                  final query = state.uri.queryParameters['q'];
                  return ProductListPage(searchQuery: query);
                },
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────────
          // TAB 2: CARRITO
          // ────────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCartKey,
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: 'cart',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CartScreen(),
                ),
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────────
          // TAB 3: PERFIL / CUENTA
          // ────────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
                routes: [
                  // Pedidos
                  GoRoute(
                    path: 'pedidos',
                    name: 'orders',
                    builder: (context, state) => const OrdersScreen(),
                    routes: [
                      GoRoute(
                        path: ':orderId',
                        name: 'orderDetail',
                        builder: (context, state) {
                          final orderId = state.pathParameters['orderId'] ?? '';
                          return OrderDetailScreen(orderId: orderId);
                        },
                      ),
                    ],
                  ),
                  // Favoritos
                  GoRoute(
                    path: 'favoritos',
                    name: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ══════════════════════════════════════════════════════════════════════
      // RUTAS FUERA DEL SHELL (modales, auth, etc.)
      // ══════════════════════════════════════════════════════════════════════
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Checkout (fuera del shell para pantalla completa)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      // Checkout Success
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.checkoutSuccess,
        name: 'checkoutSuccess',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'] ?? '';
          final orderId = state.uri.queryParameters['orderId'] ?? '';
          final orderNumber = state.uri.queryParameters['orderNumber'] ?? '';
          return CheckoutSuccessScreen(sessionId: sessionId, orderId: orderId, orderNumber: orderNumber);
        },
      ),

      // ══════════════════════════════════════════════════════════════════════
      // RUTAS DE ADMINISTRACIÓN
      // ══════════════════════════════════════════════════════════════════════
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminKpis,
        name: 'adminKpis',
        builder: (context, state) => const AdminKpisScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminProducts,
        name: 'adminProducts',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminOrders,
        name: 'adminOrders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminDiscountCodes,
        name: 'adminDiscountCodes',
        builder: (context, state) => const AdminDiscountCodesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminUsers,
        name: 'adminUsers',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminCarousel,
        name: 'adminCarousel',
        builder: (context, state) => const AdminCarouselScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminNotifications,
        name: 'adminNotifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminInvoices,
        name: 'adminInvoices',
        builder: (context, state) => const AdminInvoicesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminNewsletter,
        name: 'adminNewsletter',
        builder: (context, state) => const AdminNewsletterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminCategories,
        name: 'adminCategories',
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminAnimations,
        name: 'adminAnimations',
        builder: (context, state) => const AdminAnimationsScreen(),
      ),

      // Detalle de producto (ruta global para deep links)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/producto/:slug',
        name: 'productDetailGlobal',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return ProductDetailPage(productId: slug);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Página no encontrada',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => GoRouter.of(context).go(AppRoutes.home),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Constantes de rutas
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String products = '/productos';
  static const String productDetail = '/productos/:slug';
  static const String category = '/categoria/:slug';
  static const String offers = '/ofertas';
  static const String search = '/buscar';
  static const String cart = '/carrito';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout/success';
  static const String profile = '/cuenta';
  static const String orders = '/cuenta/pedidos';
  static const String favorites = '/cuenta/favoritos';
  static const String login = '/auth/login';
  static const String register = '/auth/registro';
  static const String forgotPassword = '/auth/recuperar';

  // Rutas de administración
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminKpis = '/admin/kpis';
  static const String adminProducts = '/admin/productos';
  static const String adminOrders = '/admin/pedidos';
  static const String adminDiscountCodes = '/admin/codigos';
  static const String adminUsers = '/admin/usuarios';
  static const String adminCarousel = '/admin/carrusel';
  static const String adminNotifications = '/admin/notificaciones';
  static const String adminInvoices = '/admin/facturas';
  static const String adminNewsletter = '/admin/newsletter';
  static const String adminCategories = '/admin/categorias';
  static const String adminAnimations = '/admin/animaciones';

  // Helpers para construir rutas con parámetros
  static String productBySlug(String slug) => '/productos/$slug';
  static String categoryBySlug(String slug) => '/categoria/$slug';
  static String searchByQuery(String query) => '/buscar?q=$query';
  static String checkoutSuccessWithOrder(String orderId, {String orderNumber = ''}) =>
      '/checkout/success?orderId=$orderId${orderNumber.isNotEmpty ? '&orderNumber=$orderNumber' : ''}';
}
