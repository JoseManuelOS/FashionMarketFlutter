import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../providers/orders_providers.dart';

/// Pantalla de listado de pedidos del cliente
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrdersProvider);
    final currentFilter = ref.watch(ordersFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark500,
        title: const Text('Mis Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // FILTROS POR ESTADO
          // ═══════════════════════════════════════════════════════════════
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Todos',
                  isSelected: currentFilter == null,
                  onTap: () => ref.read(ordersFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: status.displayName,
                    isSelected: currentFilter == status,
                    onTap: () => ref.read(ordersFilterProvider.notifier).state = status,
                    color: _statusColor(status),
                  ),
                )),
              ],
            ),
          ),

          const Divider(color: AppColors.dark100, height: 1),

          // ═══════════════════════════════════════════════════════════════
          // LISTA DE PEDIDOS
          // ═══════════════════════════════════════════════════════════════
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
              error: (error, _) => _buildError(ref, error),
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmpty(currentFilter);
                }
                return RefreshIndicator(
                  color: AppColors.neonCyan,
                  backgroundColor: AppColors.dark400,
                  onRefresh: () => ref.refresh(myOrdersProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderCard(order: order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar pedidos',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(myOrdersProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(OrderStatus? filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.textSubtle,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              filter != null
                  ? 'No hay pedidos ${filter.displayName.toLowerCase()}s'
                  : 'Aún no tienes pedidos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter != null
                  ? 'Prueba con otro filtro'
                  : '¡Descubre nuestra colección!',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.paid:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.neonCyan;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.returnRequested:
        return Colors.amber;
      case OrderStatus.returned:
        return Colors.deepOrange;
      case OrderStatus.partialReturn:
        return Colors.teal;
      case OrderStatus.returnRejected:
        return Colors.red[300]!;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS INTERNOS
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.neonCyan;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : AppColors.dark400,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.dark100,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : AppColors.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/cuenta/pedidos/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dark100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: número + estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedOrderNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 12),

            // Fecha
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Items preview
            if (order.items.isNotEmpty) ...[
              Row(
                children: [
                  // Thumbnails de items (max 3)
                  ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.productImage != null
                          ? Image.network(
                              item.productImage!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _itemPlaceholder(),
                            )
                          : _itemPlaceholder(),
                    ),
                  )),
                  if (order.items.length > 3)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.dark300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+${order.items.length - 3}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            // Tracking info
            if (order.hasTracking) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        size: 16, color: AppColors.neonCyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order.shippingCarrier ?? 'Transportista'}: ${order.trackingNumber}',
                        style: const TextStyle(
                          color: AppColors.neonCyanLight,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      color: AppColors.dark300,
      child: const Icon(Icons.image_outlined, size: 20, color: AppColors.textSubtle),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.paid:
        return AppColors.info;
      case OrderStatus.shipped:
        return AppColors.neonCyan;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.returnRequested:
        return Colors.amber;
      case OrderStatus.returned:
        return Colors.deepOrange;
      case OrderStatus.partialReturn:
        return Colors.teal;
      case OrderStatus.returnRejected:
        return Colors.red[300]!;
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.paid:
        return Icons.payment;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.returnRequested:
        return Icons.assignment_return;
      case OrderStatus.returned:
        return Icons.assignment_returned;
      case OrderStatus.partialReturn:
        return Icons.assignment_return_outlined;
      case OrderStatus.returnRejected:
        return Icons.do_not_disturb_alt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
