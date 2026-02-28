import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/sales_chart_widget.dart';

/// Pantalla de KPIs y Ventas - Dashboard Ejecutivo
/// Equivalente a /admin/dashboard-ejecutivo en FashionStore
class AdminKpisScreen extends ConsumerWidget {
  const AdminKpisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminSessionProvider);
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    final dateFormat = DateFormat("EEEE, d 'de' MMMM yyyy · HH:mm", 'es_ES');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminKpis),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'KPIs & Ventas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(adminDashboardStatsProvider);
              ref.invalidate(adminSalesProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminSalesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard Ejecutivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Resumen de métricas clave • ${dateFormat.format(DateTime.now())}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // KPI Cards Grid
              statsAsync.when(
                loading: () => _buildKpiCardsLoading(),
                error: (e, _) => _buildKpiCardsError(),
                data: (stats) => _buildKpiCardsGrid(stats, currencyFormat),
              ),

              const SizedBox(height: 24),

              // Ventas (Gráfico mejorado con selector de período)
              const SalesChartWidget(),

              const SizedBox(height: 24),

              // Resumen rápido y enlaces
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _buildQuickStatsPanel(context, stats, currencyFormat),
              ),

              const SizedBox(height: 16),

              // Nota de actualización
              Center(
                child: Text(
                  'Los datos se actualizan con cada recarga · Powered by Supabase',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCardsLoading() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.neonCyan,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCardsError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Text(
            'Error al cargar estadísticas',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardsGrid(Map<String, dynamic> stats, NumberFormat currencyFormat) {
    final monthlySales = (stats['monthlySales'] as num?)?.toDouble() ?? 0.0;
    final pendingOrders = stats['pendingOrders'] ?? 0;
    final topProduct = stats['topProduct'] as Map<String, dynamic>?;
    final lowStockCount = stats['lowStockProducts'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        // Ventas del Mes - Cyan
        _buildKpiCard(
          icon: Icons.euro_symbol,
          label: 'Ventas del Mes',
          value: currencyFormat.format(monthlySales),
          subtitle: DateFormat("MMMM yyyy", 'es_ES').format(DateTime.now()),
          color: AppColors.neonCyan,
          isGradientValue: true,
        ),

        // Pedidos Pendientes - Fuchsia
        _buildKpiCard(
          icon: Icons.assignment_outlined,
          label: 'Pedidos Pendientes',
          value: '$pendingOrders',
          subtitle: pendingOrders == 0 ? '✓ ¡Todo al día!' : '⚡ Requieren atención',
          color: AppColors.neonFuchsia,
        ),

        // Top Producto - Purple
        _buildKpiCard(
          icon: Icons.star_outline,
          label: 'Más Vendido',
          value: topProduct?['name'] ?? 'Sin datos',
          subtitle: topProduct != null 
              ? '🔥 ${topProduct['quantity']} unidades vendidas'
              : 'No hay ventas registradas',
          color: AppColors.neonPurple,
          isSmallValue: true,
        ),

        // Stock Bajo - Amber
        _buildKpiCard(
          icon: Icons.warning_amber_outlined,
          label: 'Stock Bajo',
          value: '$lowStockCount',
          subtitle: lowStockCount > 0 
              ? '⚠️ Necesitan reposición'
              : '✓ Inventario saludable',
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    bool isGradientValue = false,
    bool isSmallValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF12121A),
            const Color(0xFF18181F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar color indicator
          Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.5)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          
          const Spacer(),
          
          // Label
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          
          // Value
          isGradientValue
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonFuchsia],
                  ).createShader(bounds),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallValue ? 14 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Space Grotesk',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallValue ? 14 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Space Grotesk',
                  ),
                  maxLines: isSmallValue ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsPanel(
    BuildContext context,
    Map<String, dynamic> stats,
    NumberFormat currencyFormat,
  ) {
    final lowStockCount = stats['lowStockProducts'] ?? 0;
    final pendingOrders = stats['pendingOrders'] ?? 0;
    final totalProducts = stats['totalProducts'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF12121A),
            const Color(0xFF18181F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Resumen Rápido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats items
          _buildStatItem('Total productos', '$totalProducts'),
          _buildStatItem(
            'Stock bajo (≤5)',
            lowStockCount > 0 ? '$lowStockCount productos' : '✓ OK',
            isWarning: lowStockCount > 0,
          ),
          _buildStatItem(
            'Pedidos pendientes',
            pendingOrders > 0 ? '$pendingOrders pedidos' : '✓ Al día',
            isWarning: pendingOrders > 0,
          ),
          
          const SizedBox(height: 20),
          
          // Quick links
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildQuickLink(
            icon: Icons.assignment_outlined,
            label: 'Ver todos los pedidos',
            onTap: () => context.push(AppRoutes.adminOrders),
          ),
          const SizedBox(height: 8),
          _buildQuickLink(
            icon: Icons.inventory_2_outlined,
            label: 'Gestionar inventario',
            onTap: () => context.push(AppRoutes.adminProducts),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isWarning
                  ? Colors.amber.withValues(alpha: 0.1)
                  : AppColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isWarning ? Colors.amber : AppColors.neonCyan,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.neonCyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.neonCyan, size: 14),
          ],
        ),
      ),
    );
  }
}
