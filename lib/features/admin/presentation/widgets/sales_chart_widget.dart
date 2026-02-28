import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/admin_providers.dart';

/// Widget mejorado de gráfico de ventas con barras + línea + selector de período
class SalesChartWidget extends ConsumerStatefulWidget {
  /// Si true, muestra versión compacta (para dashboard)
  final bool compact;

  const SalesChartWidget({super.key, this.compact = false});

  @override
  ConsumerState<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends ConsumerState<SalesChartWidget> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(adminSalesProvider(_selectedDays));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dark500,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ventas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 16),

          // KPI summary row + chart
          salesAsync.when(
            data: (salesData) {
              if (salesData.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Sin datos de ventas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              final totalSales = salesData.fold<double>(
                  0, (sum, d) => sum + ((d['total'] as num?)?.toDouble() ?? 0));
              final totalOrders = salesData.fold<int>(
                  0, (sum, d) => sum + ((d['orders'] as int?) ?? 0));
              final avgDaily = totalSales / salesData.length;

              return Column(
                children: [
                  _buildKpiRow(totalSales, totalOrders, avgDaily),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: widget.compact ? 180 : 220,
                    child: _buildCombinedChart(salesData),
                  ),
                  if (!widget.compact) ...[
                    const SizedBox(height: 16),
                    _buildMiniStats(salesData),
                  ],
                ],
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.neonCyan,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Error al cargar ventas',
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodChip(7, '7D'),
          _buildPeriodChip(30, '30D'),
          _buildPeriodChip(90, '90D'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(int days, String label) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDays = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonCyan : Colors.grey[500],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(double totalSales, int totalOrders, double avgDaily) {
    return Row(
      children: [
        _buildKpiCard(
          'Total Ventas',
          '${totalSales.toStringAsFixed(0)}€',
          Icons.euro,
          AppColors.neonCyan,
        ),
        const SizedBox(width: 8),
        _buildKpiCard(
          'Pedidos',
          '$totalOrders',
          Icons.shopping_bag_outlined,
          AppColors.neonFuchsia,
        ),
        const SizedBox(width: 8),
        _buildKpiCard(
          'Media/día',
          '${avgDaily.toStringAsFixed(0)}€',
          Icons.trending_up,
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedChart(List<Map<String, dynamic>> salesData) {
    final barGroups = <BarChartGroupData>[];
    final lineSpots = <FlSpot>[];
    final dates = <String>[];
    double maxY = 0;

    for (int i = 0; i < salesData.length; i++) {
      final total = (salesData[i]['total'] as num?)?.toDouble() ?? 0.0;
      if (total > maxY) maxY = total;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              width: _selectedDays <= 7
                  ? 20
                  : _selectedDays <= 30
                      ? 6
                      : 3,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.8),
                  AppColors.neonCyan.withValues(alpha: 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      );
      lineSpots.add(FlSpot(i.toDouble(), total));

      final dateStr = salesData[i]['date']?.toString() ?? '';
      try {
        final date = DateTime.parse(dateStr);
        dates.add(DateFormat('dd/MM').format(date));
      } catch (_) {
        dates.add(dateStr.length > 5 ? dateStr.substring(5) : dateStr);
      }
    }

    maxY = maxY > 0 ? maxY * 1.25 : 100;

    // Determine label interval based on days
    int labelInterval;
    if (_selectedDays <= 7) {
      labelInterval = 1;
    } else if (_selectedDays <= 30) {
      labelInterval = 5;
    } else {
      labelInterval = 15;
    }

    return Stack(
      children: [
        // Bar chart (background)
        BarChart(
          BarChartData(
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(alpha: 0.08),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: maxY / 4,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      '${value.toInt()}€',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= dates.length) return const SizedBox();
                    // Solo mostrar cada N-ésima etiqueta para evitar solapamiento
                    if (idx % labelInterval != 0 && idx != dates.length - 1) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dates[idx],
                        style: TextStyle(color: Colors.grey[600], fontSize: 9),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1A1A2E),
                tooltipBorder: BorderSide(
                  color: AppColors.neonCyan.withValues(alpha: 0.3),
                ),
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final date = groupIndex < dates.length ? dates[groupIndex] : '';
                  final orders = groupIndex < salesData.length
                      ? (salesData[groupIndex]['orders'] as int? ?? 0)
                      : 0;
                  return BarTooltipItem(
                    '$date\n',
                    TextStyle(color: Colors.grey[400], fontSize: 11),
                    children: [
                      TextSpan(
                        text: '${rod.toY.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '\n$orders pedidos',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // Line chart overlay (trend)
        if (salesData.length > 1)
          IgnorePointer(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (salesData.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: lineSpots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.neonFuchsia.withValues(alpha: 0.8),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: _selectedDays <= 7,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.neonFuchsia,
                          strokeWidth: 1.5,
                          strokeColor: AppColors.dark500,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStats(List<Map<String, dynamic>> salesData) {
    double bestDaySales = 0;
    String bestDayDate = '-';
    double worstDaySales = double.infinity;
    String worstDayDate = '-';
    int daysWithSales = 0;
    double totalSales = 0;

    for (final day in salesData) {
      final total = (day['total'] as num?)?.toDouble() ?? 0.0;
      final dateStr = day['date']?.toString() ?? '';
      totalSales += total;

      String formattedDate;
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd/MM').format(date);
      } catch (_) {
        formattedDate = dateStr;
      }

      if (total > bestDaySales) {
        bestDaySales = total;
        bestDayDate = formattedDate;
      }
      if (total < worstDaySales) {
        worstDaySales = total;
        worstDayDate = formattedDate;
      }
      if (total > 0) daysWithSales++;
    }

    if (worstDaySales == double.infinity) worstDaySales = 0;

    return Row(
      children: [
        _buildMiniStat(
          'Mejor día',
          '${bestDaySales.toStringAsFixed(0)}€',
          bestDayDate,
          AppColors.neonCyan,
        ),
        const SizedBox(width: 8),
        _buildMiniStat(
          'Peor día',
          '${worstDaySales.toStringAsFixed(0)}€',
          worstDayDate,
          AppColors.neonFuchsia,
        ),
        const SizedBox(width: 8),
        _buildMiniStat(
          'Días con ventas',
          '$daysWithSales/$_selectedDays',
          '${totalSales.toStringAsFixed(0)}€ total',
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
