import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/app_colors.dart';
import '../../data/models/order_model.dart';
import '../providers/orders_providers.dart';

/// Pantalla de detalle de un pedido
class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isCancelling = false;
  bool _isReturning = false;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark500,
        title: const Text('Detalle del Pedido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (orders) {
          final order = orders.where((o) => o.id == widget.orderId).firstOrNull;
          if (order == null) {
            return const Center(
              child: Text('Pedido no encontrado',
                  style: TextStyle(color: Colors.white)),
            );
          }
          return _buildContent(context, order);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════
          // HEADER: Número + Estado
          // ═══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dark100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.formattedOrderNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.calendar_today_outlined, 'Fecha',
                    _formatDate(order.createdAt)),
                if (order.customerEmail != null)
                  _buildInfoRow(Icons.email_outlined, 'Email',
                      order.customerEmail!),
                _buildInfoRow(Icons.euro, 'Total', order.formattedTotal),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════
          // PROGRESO DEL PEDIDO
          // ═══════════════════════════════════════════════════════════
          _buildProgressSection(order),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════
          // TRACKING
          // ═══════════════════════════════════════════════════════════
          if (order.hasTracking) ...[
            _buildTrackingSection(order),
            const SizedBox(height: 16),
          ],

          // ═══════════════════════════════════════════════════════════
          // ITEMS DEL PEDIDO
          // ═══════════════════════════════════════════════════════════
          _buildItemsSection(order),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════
          // RESUMEN DE PRECIOS
          // ═══════════════════════════════════════════════════════════
          _buildPriceSummary(order),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════
          // DIRECCIÓN DE ENVÍO
          // ═══════════════════════════════════════════════════════════
          if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty)
            _buildAddressSection(order),

          const SizedBox(height: 24),

          // ═══════════════════════════════════════════════════════════
          // ACCIONES
          // ═══════════════════════════════════════════════════════════
          if (order.status.canCancel) _buildCancelButton(order),
          if (order.status.canRequestReturn) _buildReturnButton(order),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Progress Timeline ───────────────────────────────────────────────
  Widget _buildProgressSection(OrderModel order) {
    final steps = [
      _ProgressStep('Pedido', Icons.receipt_outlined, true),
      _ProgressStep('Pagado', Icons.payment,
          order.status != OrderStatus.pending),
      _ProgressStep('Enviado', Icons.local_shipping_outlined,
          order.status == OrderStatus.shipped || order.status == OrderStatus.delivered),
      _ProgressStep('Entregado', Icons.check_circle_outline,
          order.status == OrderStatus.delivered),
    ];

    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pedido cancelado',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  if (order.cancellationReason != null)
                    Text(order.cancellationReason!,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final isLast = i == steps.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: step.completed
                              ? AppColors.neonCyan.withOpacity(0.15)
                              : AppColors.dark300,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: step.completed
                                ? AppColors.neonCyan
                                : AppColors.dark100,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          step.icon,
                          size: 16,
                          color: step.completed
                              ? AppColors.neonCyan
                              : AppColors.textSubtle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.label,
                        style: TextStyle(
                          color: step.completed ? Colors.white : AppColors.textSubtle,
                          fontSize: 10,
                          fontWeight: step.completed ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 16,
                    height: 2,
                    color: step.completed
                        ? AppColors.neonCyan.withOpacity(0.5)
                        : AppColors.dark100,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Tracking ────────────────────────────────────────────────────────
  Widget _buildTrackingSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Seguimiento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (order.shippingCarrier != null) ...[
                Text(
                  order.shippingCarrier!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('·', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  order.trackingNumber!,
                  style: const TextStyle(
                    color: AppColors.neonCyanLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: order.trackingNumber!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Número de tracking copiado')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (order.trackingUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openTrackingUrl(order.trackingUrl!),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Seguir envío'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonCyan,
                  side: const BorderSide(color: AppColors.neonCyan),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Items ───────────────────────────────────────────────────────────
  Widget _buildItemsSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artículos (${order.items.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Talla: ${item.size} · x${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.formattedSubtotal,
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.dark300,
      child: const Icon(Icons.image_outlined, color: AppColors.textSubtle, size: 24),
    );
  }

  // ─── Price Summary ───────────────────────────────────────────────────
  Widget _buildPriceSummary(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark100),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '€${order.subtotal.toStringAsFixed(2)}'),
          if (order.shippingPrice > 0)
            _buildPriceRow('Envío', '€${order.shippingPrice.toStringAsFixed(2)}'),
          if (order.discountAmount > 0)
            _buildPriceRow(
              'Descuento${order.discountCode != null ? ' (${order.discountCode})' : ''}',
              '-€${order.discountAmount.toStringAsFixed(2)}',
              valueColor: AppColors.success,
            ),
          const Divider(color: AppColors.dark100, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(
                order.formattedTotal,
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  // ─── Address ─────────────────────────────────────────────────────────
  Widget _buildAddressSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dark100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 18),
              SizedBox(width: 8),
              Text('Dirección de envío',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.shippingAddress!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────
  Widget _buildCancelButton(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isCancelling ? null : () => _showCancelDialog(order),
          icon: _isCancelling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                )
              : const Icon(Icons.cancel_outlined),
          label: Text(_isCancelling ? 'Cancelando...' : 'Cancelar pedido'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnButton(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isReturning ? null : () => _showReturnDialog(order),
          icon: _isReturning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warning),
                )
              : const Icon(Icons.assignment_return_outlined),
          label: Text(_isReturning ? 'Solicitando...' : 'Solicitar devolución'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warning,
            side: const BorderSide(color: AppColors.warning),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────
  void _showCancelDialog(OrderModel order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark400,
        title: const Text('Cancelar pedido', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro de que quieres cancelar este pedido?',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo de la cancelación...',
                hintStyle: const TextStyle(color: AppColors.textSubtle),
                filled: true,
                fillColor: AppColors.dark300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelOrder(order, controller.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancelar pedido',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(OrderModel order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark400,
        title: const Text('Solicitar devolución', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Indica el motivo de la devolución.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo de la devolución...',
                hintStyle: const TextStyle(color: AppColors.textSubtle),
                filled: true,
                fillColor: AppColors.dark300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _requestReturn(order, controller.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Solicitar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ─── API calls ───────────────────────────────────────────────────────
  Future<void> _cancelOrder(OrderModel order, String reason) async {
    setState(() => _isCancelling = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final success = await repo.cancelOrder(
        orderId: order.id.toString(),
        reason: reason.isEmpty ? 'Cancelado por el cliente' : reason,
      );
      ref.invalidate(myOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Pedido cancelado' : 'No se pudo cancelar'),
          backgroundColor: success ? Colors.green[700] : Colors.red[700],
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _requestReturn(OrderModel order, String reason) async {
    setState(() => _isReturning = true);
    try {
      final repo = ref.read(orderRepositoryProvider);
      final success = await repo.requestReturn(
        orderId: order.id.toString(),
        reason: reason.isEmpty ? 'Devolución solicitada por el cliente' : reason,
      );
      ref.invalidate(myOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Devolución solicitada correctamente'
              : 'No se pudo solicitar la devolución'),
          backgroundColor: success ? Colors.green[700] : Colors.red[700],
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _isReturning = false);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────
  Future<void> _openTrackingUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
      case OrderStatus.paid:
        color = AppColors.info;
      case OrderStatus.shipped:
        color = AppColors.neonCyan;
      case OrderStatus.delivered:
        color = AppColors.success;
      case OrderStatus.cancelled:
        color = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _ProgressStep {
  final String label;
  final IconData icon;
  final bool completed;
  _ProgressStep(this.label, this.icon, this.completed);
}
