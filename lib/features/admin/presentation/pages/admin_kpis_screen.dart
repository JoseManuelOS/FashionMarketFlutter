import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';

/// Pantalla de KPIs y Ventas - Dashboard Ejecutivo
/// Equivalente a /admin/dashboard-ejecutivo en FashionStore
class AdminKpisScreen extends ConsumerWidget {
  const AdminKpisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminSessionProvider);
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final salesDataAsync = ref.watch(adminSalesLast7DaysProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
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
              ref.invalidate(adminSalesLast7DaysProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminSalesLast7DaysProvider);
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

              // Ventas últimos 7 días (Gráfico)
              _buildSalesChartSection(salesDataAsync, currencyFormat),

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
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                colors: [color, color.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  Widget _buildSalesChartSection(
    AsyncValue<List<Map<String, dynamic>>> salesDataAsync,
    NumberFormat currencyFormat,
  ) {
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
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ventas de los últimos 7 días',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          salesDataAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Error al cargar datos de ventas',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            data: (salesData) => _buildSimpleBarChart(salesData, currencyFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(
    List<Map<String, dynamic>> salesData,
    NumberFormat currencyFormat,
  ) {
    if (salesData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, color: Colors.grey[600], size: 48),
              const SizedBox(height: 12),
              Text(
                'No hay datos de ventas',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Calcular el máximo para la escala
    final maxValue = salesData
        .map((e) => (e['total'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
    final scale = maxValue > 0 ? maxValue : 1;

    return Column(
      children: [
        // Barras
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: salesData.map((data) {
              final total = (data['total'] as num?)?.toDouble() ?? 0.0;
              final date = data['date'] as String? ?? '';
              final heightPercent = total / scale;
              
              // Parsear fecha
              DateTime? parsedDate;
              try {
                parsedDate = DateTime.parse(date);
              } catch (_) {}
              
              final dayName = parsedDate != null 
                  ? DateFormat('EEE', 'es_ES').format(parsedDate).substring(0, 2)
                  : '';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Valor encima de la barra
                      if (total > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '€${total.toInt()}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      // Barra
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: (heightPercent * 120).clamp(4.0, 120.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonCyan,
                              AppColors.neonCyan.withOpacity(0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: total > 0
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Día
                      Text(
                        dayName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Total de la semana
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: AppColors.neonCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'Total semana: ',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              Text(
                currencyFormat.format(
                  salesData.fold<double>(
                    0,
                    (sum, item) => sum + ((item['total'] as num?)?.toDouble() ?? 0),
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
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
                  ? Colors.amber.withOpacity(0.1)
                  : AppColors.neonCyan.withOpacity(0.1),
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
          color: AppColors.neonCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.3)),
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
