import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/router/app_router.dart';
import '../../config/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import 'newsletter_popup.dart';

/// Drawer de navegación principal de la aplicación
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return Drawer(
      backgroundColor: AppColors.dark500,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ═══ HEADER ═══
            _buildHeader(context, user),
            const Divider(color: AppColors.glassBorder, height: 1),

            // ═══ NAV ITEMS ═══
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Inicio',
                    onTap: () => _navigate(context, AppRoutes.home),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.grid_view_outlined,
                    label: 'Todos los productos',
                    onTap: () => _navigate(context, AppRoutes.products),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.local_offer_outlined,
                    label: 'Ofertas',
                    color: AppColors.neonFuchsia,
                    onTap: () => _navigate(context, AppRoutes.offers),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Newsletter',
                    onTap: () {
                      Navigator.of(context).pop();
                      showNewsletterPopup(context);
                    },
                  ),

                  // Categorías dinámicas
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      'CATEGORÍAS',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  categoriesAsync.when(
                    data: (categories) => Column(
                      children: categories.map((cat) {
                        return _buildNavItem(
                          context,
                          icon: _getCategoryIcon(cat['slug'] as String? ?? ''),
                          label: cat['name'] as String? ?? '',
                          onTap: () => _navigate(
                            context,
                            '/categoria/${cat['slug']}',
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const Divider(
                    color: AppColors.glassBorder,
                    height: 32,
                    indent: 20,
                    endIndent: 20,
                  ),

                  // Cuenta
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'MI CUENTA',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (user != null) ...[
                    _buildNavItem(
                      context,
                      icon: Icons.receipt_long_outlined,
                      label: 'Mis Pedidos',
                      onTap: () => _navigate(context, AppRoutes.orders),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.favorite_outline,
                      label: 'Favoritos',
                      onTap: () => _navigate(context, AppRoutes.favorites),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline,
                      label: 'Mi Perfil',
                      onTap: () => _navigate(context, AppRoutes.profile),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Carrito',
                      onTap: () => _navigate(context, AppRoutes.cart),
                    ),
                  ] else ...[
                    _buildNavItem(
                      context,
                      icon: Icons.login_rounded,
                      label: 'Iniciar sesión',
                      color: AppColors.neonCyan,
                      onTap: () => _navigate(context, AppRoutes.login),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_add_outlined,
                      label: 'Crear cuenta',
                      onTap: () => _navigate(context, AppRoutes.register),
                    ),
                  ],
                ],
              ),
            ),

            // ═══ FOOTER ═══
            if (user != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[400]!.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.08),
            AppColors.neonFuchsia.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Logo / avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.neonCyan, AppColors.neonFuchsia],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user != null
                    ? (user.email?.substring(0, 1).toUpperCase() ?? 'F')
                    : 'F',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/logo/logo.svg',
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Explora la moda',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[400], size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontSize: 15,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop(); // Close drawer
    context.push(route);
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug) {
      case 'camisas':
        return Icons.dry_cleaning_outlined;
      case 'pantalones':
        return Icons.checkroom_outlined;
      case 'trajes':
        return Icons.business_center_outlined;
      case 'accesorios':
        return Icons.watch_outlined;
      case 'zapatos':
        return Icons.ice_skating_outlined;
      case 'abrigos':
        return Icons.ac_unit_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
