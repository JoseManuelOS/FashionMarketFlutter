import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/checkout_providers.dart';
import '../services/stripe_service.dart';

/// Paso 4: Resumen y pago
class CheckoutStepSummary extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onEditAddress;
  final VoidCallback onEditShipping;

  const CheckoutStepSummary({
    super.key,
    required this.onBack,
    required this.onEditAddress,
    required this.onEditShipping,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutData = ref.watch(checkoutDataProvider);
    final cartItems = ref.watch(cartNotifierProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final isLoading = ref.watch(paymentLoadingProvider);

    final discount = checkoutData.discountAmount;
    final shipping = checkoutData.shippingCost;
    final total = subtotal - discount + shipping;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Pedido',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dirección
                      _buildSummarySection(
                        title: 'Dirección de Envío',
                        onEdit: onEditAddress,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkoutData.fullName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              checkoutData.formattedAddress,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            Text(
                              checkoutData.email,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: AppColors.glassBorder, height: 32),

                      // Método de envío
                      _buildSummarySection(
                        title: 'Método de Envío',
                        onEdit: onEditShipping,
                        content: Text(
                          checkoutData.shippingMethodName ?? 'No seleccionado',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),

                      const Divider(color: AppColors.glassBorder, height: 32),

                      // Productos
                      const Text(
                        'Productos',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cartItems.map((item) => _buildProductItem(item)),

                      const Divider(color: AppColors.glassBorder, height: 32),

                      // Totales
                      _buildPriceRow('Subtotal', subtotal),
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'Descuento (${checkoutData.discountCode})',
                          -discount,
                          isDiscount: true,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Envío',
                        shipping,
                        showFree: shipping == 0,
                      ),
                      const Divider(color: AppColors.glassBorder, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '€${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, ref, total, isLoading),
      ],
    );
  }

  Widget _buildSummarySection({
    required String title,
    required VoidCallback onEdit,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Text(
                'Editar',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildProductItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.dark300,
                child: Icon(Icons.image, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Talla: ${item.size} · Cantidad: ${item.quantity}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '€${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {
    bool isDiscount = false,
    bool showFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? AppColors.success : AppColors.textMuted,
            fontSize: 14,
          ),
        ),
        Text(
          showFree
              ? 'Gratis'
              : '${isDiscount ? '-' : ''}€${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isDiscount
                ? AppColors.success
                : showFree
                    ? AppColors.neonCyan
                    : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    WidgetRef ref,
    double total,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark500,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.glassBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Atrás'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _processPayment(context, ref, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.textOnPrimary,
                  disabledBackgroundColor: AppColors.dark400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pagar Ahora',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    WidgetRef ref,
    double total,
  ) async {
    ref.read(paymentLoadingProvider.notifier).state = true;

    try {
      final checkoutData = ref.read(checkoutDataProvider);
      final cartItems = ref.read(cartNotifierProvider);

      // Llamar al API real de FashionStore para crear sesión de Stripe
      final result = await StripeService.createCheckoutSession(
        items: cartItems,
        customerEmail: checkoutData.email,
        customerPhone: checkoutData.phone,
        customerName: checkoutData.fullName,
        shippingAddress: {
          'street': checkoutData.street,
          'city': checkoutData.city,
          'postal_code': checkoutData.postalCode,
          'province': checkoutData.province,
          'country': checkoutData.country,
        },
        discountCode: checkoutData.discountCode,
        discountAmount: checkoutData.discountAmount,
        discountType: checkoutData.discountType,
        discountValue: checkoutData.discountValue,
        shippingMethodId: checkoutData.shippingMethodId,
        shippingCost: checkoutData.shippingCost,
      );

      if (result['success'] == true && result['url'] != null) {
        final stripeUrl = result['url'] as String;
        final sessionId = result['sessionId'] as String;

        // Abrir Stripe Checkout en el navegador
        final uri = Uri.parse(stripeUrl);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          throw Exception('No se pudo abrir la pasarela de pago');
        }

        // Esperar un momento y luego verificar el pago
        // El usuario volverá a la app tras completar el pago en Stripe
        if (context.mounted) {
          // Mostrar diálogo de espera mientras el usuario paga
          _showPaymentPendingDialog(context, ref, sessionId);
        }
      } else {
        throw Exception(result['error'] ?? 'Error al procesar el pago');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      ref.read(paymentLoadingProvider.notifier).state = false;
    }
  }

  /// Diálogo que se muestra mientras el usuario está pagando en Stripe
  /// Permite verificar manualmente o cancelar
  void _showPaymentPendingDialog(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PaymentPendingDialog(
        sessionId: sessionId,
        onPaymentVerified: (orderId) {
          Navigator.of(dialogContext).pop();
          // Limpiar carrito y checkout
          ref.read(cartNotifierProvider.notifier).clearCart();
          ref.read(checkoutDataProvider.notifier).reset();
          ref.read(checkoutStepProvider.notifier).state = 0;
          // Navegar a pantalla de éxito
          context.go(AppRoutes.checkoutSuccessWithOrder(orderId));
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

/// Diálogo para gestionar el estado del pago con Stripe
class _PaymentPendingDialog extends StatefulWidget {
  final String sessionId;
  final void Function(String orderId) onPaymentVerified;
  final VoidCallback onCancel;

  const _PaymentPendingDialog({
    required this.sessionId,
    required this.onPaymentVerified,
    required this.onCancel,
  });

  @override
  State<_PaymentPendingDialog> createState() => _PaymentPendingDialogState();
}

class _PaymentPendingDialogState extends State<_PaymentPendingDialog> {
  bool _isVerifying = false;
  String? _error;

  Future<void> _verifyPayment() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final result = await StripeService.verifyPayment(widget.sessionId);

      if (result['success'] == true) {
        widget.onPaymentVerified(result['orderId']?.toString() ?? '');
      } else {
        setState(() {
          _error = 'El pago aún no se ha completado. Finaliza el pago en Stripe e inténtalo de nuevo.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al verificar: ${e.toString()}';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.payment, color: AppColors.neonCyan),
          SizedBox(width: 12),
          Text(
            'Pago en proceso',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Se ha abierto la pasarela de pago de Stripe en tu navegador.\n\n'
            'Una vez completes el pago, pulsa "Verificar pago" para confirmar tu pedido.',
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Verificar pago'),
        ),
      ],
    );
  }
}
