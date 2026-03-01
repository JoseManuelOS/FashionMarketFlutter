import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../../data/models/cart_item_model.dart';
import '../providers/cart_providers.dart';

/// Pantalla completa del carrito
/// Navegación: /carrito
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final savings = ref.watch(cartSavingsProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Carrito'),
            if (itemCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, ref),
              child: Text(
                'Vaciar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, ref, items, total, savings),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.glassLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: AppColors.textSubtle,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Parece que aún no has añadido ningún producto.\nExplora nuestra colección y encuentra algo que te guste.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.products),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Explorar productos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    List<CartItemModel> items,
    double total,
    double savings,
  ) {
    return Column(
      children: [
        // Lista de items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CartItemCard(item: items[index]),
              );
            },
          ),
        ),

        // Resumen y checkout
        _buildOrderSummary(context, total, savings, items.length),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    double total,
    double savings,
    int itemCount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.dark400,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Savings banner
            if (savings > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.2),
                      AppColors.neonCyan.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '¡Estás ahorrando €${savings.toStringAsFixed(2)}!',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Subtotal
            _buildSummaryRow('Subtotal ($itemCount productos)', '€${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Envío', 'Gratis', isHighlight: true),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.divider),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '€${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.checkout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Finalizar compra',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Security badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 14, color: AppColors.textSubtle),
                const SizedBox(width: 4),
                Text(
                  'Pago seguro',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.local_shipping_outlined, size: 14, color: AppColors.textSubtle),
                const SizedBox(width: 4),
                Text(
                  'Envío gratis',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.success : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dark400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¿Vaciar carrito?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Se eliminarán todos los productos de tu carrito.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: Text(
              'Vaciar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de item del carrito
class _CartItemCard extends ConsumerStatefulWidget {
  final CartItemModel item;

  const _CartItemCard({required this.item});

  @override
  ConsumerState<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends ConsumerState<_CartItemCard> {
  bool _isCheckingStock = false;

  /// Valida stock en tiempo real antes de incrementar cantidad
  Future<void> _handleIncrement() async {
    final item = widget.item;
    setState(() => _isCheckingStock = true);
    try {
      final result = await FashionStoreApiService.getStockBySize(
        productId: item.productId,
        color: item.color,
      );
      final stockBySize = result['stockBySize'] as Map?;
      final available = stockBySize != null
          ? (stockBySize[item.size] as num?)?.toInt() ?? 0
          : (result['totalStock'] as num?)?.toInt() ?? 0;

      if (item.quantity + 1 > available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Solo hay $available unidades de talla ${item.size} disponibles',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }
      ref
          .read(cartNotifierProvider.notifier)
          .incrementQuantity(item.productId, item.size, item.color);
    } catch (_) {
      // Si falla la consulta de stock, incrementar sin validación
      ref
          .read(cartNotifierProvider.notifier)
          .incrementQuantity(item.productId, item.size, item.color);
    } finally {
      if (mounted) setState(() => _isCheckingStock = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Dismissible(
      key: Key('${item.productId}_${item.size}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(cartNotifierProvider.notifier).removeItem(item.productId, item.size, item.color);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} eliminado del carrito'),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: AppColors.neonCyan,
              onPressed: () {
                ref.read(cartNotifierProvider.notifier).addItem(item);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dark400,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            GestureDetector(
              onTap: () => context.push('/producto/${item.slug}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.dark300,
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.textSubtle, size: 20),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.dark300,
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.textSubtle, size: 20),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  GestureDetector(
                    onTap: () => context.push('/producto/${item.slug}'),
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Talla y Color en una fila
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.glassLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Talla: ${item.size}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.color != null && item.color!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.glassLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.color!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.formattedPrice,
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.hasDiscount && item.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '€${item.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onPressed: () {
                                ref
                                    .read(cartNotifierProvider.notifier)
                                    .decrementQuantity(item.productId, item.size, item.color);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onPressed: _isCheckingStock
                                  ? () {}
                                  : _handleIncrement,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Subtotal
                      Text(
                        '€${item.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
