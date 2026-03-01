import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/checkout_providers.dart';
import '../services/stripe_service.dart';

/// Página de éxito tras completar el checkout con Stripe.
///
/// Acepta dos modos:
/// - [sessionId]: devuelto por Stripe al redirigir al usuario. Se llama
///   a [StripeService.verifyPayment] para confirmar el pago y crear el pedido.
/// - [orderId]: usado cuando la verificación ya se hizo en el flujo del diálogo.
class CheckoutSuccessScreen extends ConsumerStatefulWidget {
  /// ID de sesión de Stripe (`?session_id=cs_xxx`). Se verifica automáticamente.
  final String sessionId;

  /// ID de pedido ya conocido (flujo del diálogo, ruta `?orderId=xxx`).
  final String orderId;

  /// Número de pedido legible (de la columna order_number de la BD).
  final String orderNumber;

  const CheckoutSuccessScreen({
    super.key,
    this.sessionId = '',
    this.orderId = '',
    this.orderNumber = '',
  });

  @override
  ConsumerState<CheckoutSuccessScreen> createState() =>
      _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends ConsumerState<CheckoutSuccessScreen> {
  bool _isVerifying = false;
  String _resolvedOrderId = '';
  String _resolvedOrderNumber = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.isNotEmpty) {
      // Ya tenemos el ID de pedido: flujo desde el diálogo
      _resolvedOrderId = widget.orderId;
      _resolvedOrderNumber = widget.orderNumber;
      _clearCheckoutState();
    } else if (widget.sessionId.isNotEmpty) {
      // Llegamos desde Stripe con session_id → verificar
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifySession());
    }
  }

  Future<void> _verifySession() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final result = await StripeService.verifyPayment(widget.sessionId);
      if (result['success'] == true) {
        final orderId = result['orderId']?.toString() ?? '';
        final orderNumber = result['orderNumber']?.toString() ?? '';
        setState(() {
          _resolvedOrderId = orderId;
          _resolvedOrderNumber = orderNumber;
          _isVerifying = false;
        });
        _clearCheckoutState();
      } else {
        setState(() {
          _error =
              'No se pudo confirmar el pago. Si ya pagaste, contacta con soporte.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al verificar el pago: ${e.toString()}';
        _isVerifying = false;
      });
    }
  }

  void _clearCheckoutState() {
    ref.read(cartNotifierProvider.notifier).clearCart();
    ref.read(checkoutDataProvider.notifier).reset();
    ref.read(checkoutStepProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerifying) {
      return _buildLoading();
    }
    if (_error != null) {
      return _buildError();
    }
    return _buildSuccess();
  }

  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.neonCyan),
            const SizedBox(height: 24),
            const Text(
              'Confirmando tu pago…',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.15),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.error_outline,
                    size: 50, color: AppColors.error),
              ),
              const SizedBox(height: 32),
              const Text(
                'Error al confirmar el pedido',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.sessionId.isNotEmpty ? _verifySession : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reintentar verificación',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/cuenta/pedidos'),
                child: const Text('Ver mis pedidos',
                    style:
                        TextStyle(color: AppColors.neonCyan, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de éxito
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.neonCyan, AppColors.neonCyanLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 32),

              const Text(
                '¡Pedido Confirmado!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Número de pedido
              if (_resolvedOrderId.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dark400,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_outlined,
                          color: AppColors.neonCyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido #${_resolvedOrderNumber.isNotEmpty ? _resolvedOrderNumber : _resolvedOrderId}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Gracias por tu compra. Recibirás un email de confirmación con los detalles de tu pedido.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/cuenta/pedidos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Ver mis pedidos',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'Seguir comprando',
                  style: TextStyle(color: AppColors.neonCyan, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
