import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';

/// Drawer de navegación para el panel de administración
/// Incluye todas las secciones: General, Catálogo, Ventas, Clientes, Diseño
class AdminDrawer extends ConsumerWidget {
  final String currentRoute;

  const AdminDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminSessionProvider);

    return Drawer(
      backgroundColor: const Color(0xFF0D0D14),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.1),
                  AppColors.neonFuchsia.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonFuchsia],
                  ).createShader(bounds),
                  child: const Text(
                    'FashionMarket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Panel Admin',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // ═══════════════════════════════════════════════════
                // GENERAL
                // ═══════════════════════════════════════════════════
                _buildSection('General'),
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: AppRoutes.adminDashboard,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.bar_chart,
                  label: 'KPIs & Ventas',
                  route: AppRoutes.adminKpis,
                ),

                // ═══════════════════════════════════════════════════
                // CATÁLOGO
                // ═══════════════════════════════════════════════════
                _buildSection('Catálogo'),
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Productos',
                  route: AppRoutes.adminProducts,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.category_outlined,
                  label: 'Categorías',
                  route: AppRoutes.adminCategories,
                ),

                // ═══════════════════════════════════════════════════
                // VENTAS
                // ═══════════════════════════════════════════════════
                _buildSection('Ventas'),
                _buildNavItem(
                  context: context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'Pedidos',
                  route: AppRoutes.adminOrders,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.discount_outlined,
                  label: 'Códigos Promo',
                  route: AppRoutes.adminDiscountCodes,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  label: 'Facturas',
                  route: AppRoutes.adminInvoices,
                ),

                // ═══════════════════════════════════════════════════
                // CLIENTES
                // ═══════════════════════════════════════════════════
                _buildSection('Clientes'),
                _buildNavItem(
                  context: context,
                  icon: Icons.people_outline,
                  label: 'Usuarios',
                  route: AppRoutes.adminUsers,
                ),

                // ═══════════════════════════════════════════════════
                // COMUNICACIONES
                // ═══════════════════════════════════════════════════
                _buildSection('Comunicaciones'),
                _buildNavItem(
                  context: context,
                  icon: Icons.newspaper_outlined,
                  label: 'Newsletter',
                  route: AppRoutes.adminNewsletter,
                ),

                // ═══════════════════════════════════════════════════
                // DISEÑO
                // ═══════════════════════════════════════════════════
                _buildSection('Diseño'),
                _buildNavItem(
                  context: context,
                  icon: Icons.view_carousel_outlined,
                  label: 'Carrusel',
                  route: AppRoutes.adminCarousel,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.animation,
                  label: 'Animaciones',
                  route: AppRoutes.adminAnimations,
                ),

                // ═══════════════════════════════════════════════════
                // OTROS
                // ═══════════════════════════════════════════════════
                _buildSection('Otros'),
                _buildNavItem(
                  context: context,
                  icon: Icons.open_in_new,
                  label: 'Ver Tienda',
                  route: AppRoutes.home,
                  isExternal: true,
                ),
              ],
            ),
          ),

          // Footer with admin info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Column(
              children: [
                // Admin info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.neonCyan, AppColors.neonPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          admin?.displayName.isNotEmpty == true
                              ? admin!.displayName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin?.displayName ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            admin?.role == 'super_admin' ? 'Super Admin' : 'Admin',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(adminAuthProvider.notifier).signOut();
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Cerrar Sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[400]!.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    bool isExternal = false,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.neonCyan : Colors.grey[500],
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.neonCyan : Colors.grey[400],
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isExternal
            ? Icon(Icons.open_in_new, color: Colors.grey[600], size: 14)
            : null,
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isActive) {
            if (isExternal) {
              context.go(route);
            } else {
              context.push(route);
            }
          }
        },
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: isActive ? AppColors.neonCyan.withValues(alpha: 0.1) : null,
        selectedTileColor: AppColors.neonCyan.withValues(alpha: 0.1),
        hoverColor: AppColors.neonCyan.withValues(alpha: 0.05),
      ),
    );
  }
}
