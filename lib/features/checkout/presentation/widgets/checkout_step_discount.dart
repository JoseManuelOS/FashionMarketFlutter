import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/checkout_providers.dart';

/// Paso 3: Código de descuento
class CheckoutStepDiscount extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const CheckoutStepDiscount({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  ConsumerState<CheckoutStepDiscount> createState() =>
      _CheckoutStepDiscountState();
}

class _CheckoutStepDiscountState extends ConsumerState<CheckoutStepDiscount> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasAppliedDiscount = false;

  @override
  void initState() {
    super.initState();
    final data = ref.read(checkoutDataProvider);
    if (data.discountCode != null) {
      _hasAppliedDiscount = true;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyDiscount() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Introduce un código');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(validateDiscountProvider(code).future);

      if (result == null || result['valid'] != true) {
        setState(() {
          _errorMessage = result?['error'] ?? 'Código no válido';
          _isLoading = false;
        });
        return;
      }

      final discount = result['discount'];
      final subtotal = ref.read(cartTotalProvider);
      
      double discountAmount = 0;
      if (discount['type'] == 'percentage') {
        discountAmount = subtotal * (discount['value'] as int) / 100;
      } else if (discount['type'] == 'fixed') {
        discountAmount = (discount['value'] as int).toDouble();
        if (discountAmount > subtotal) discountAmount = subtotal;
      }

      ref.read(checkoutDataProvider.notifier).setDiscount(
            code: code,
            amount: discountAmount,
            type: discount['type'],
            value: discount['value'],
          );

      setState(() {
        _hasAppliedDiscount = true;
        _isLoading = false;
      });
      _codeController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al validar el código';
        _isLoading = false;
      });
    }
  }

  void _removeDiscount() {
    ref.read(checkoutDataProvider.notifier).clearDiscount();
    setState(() => _hasAppliedDiscount = false);
  }

  @override
  Widget build(BuildContext context) {
    final checkoutData = ref.watch(checkoutDataProvider);

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
                        'Código de Descuento',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Introduce tu código promocional (opcional)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input de código
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                letterSpacing: 1,
                              ),
                              decoration: InputDecoration(
                                hintText: 'CÓDIGO',
                                hintStyle: TextStyle(color: AppColors.textSubtle),
                                filled: true,
                                fillColor: AppColors.dark300,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.glassBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.glassBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.neonCyan),
                                ),
                              ),
                              onSubmitted: (_) => _applyDiscount(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _applyDiscount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dark300,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: AppColors.glassBorder),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.neonCyan,
                                    ),
                                  )
                                : const Text('Aplicar'),
                          ),
                        ],
                      ),

                      // Mensaje de error
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ],

                      // Descuento aplicado
                      if (_hasAppliedDiscount &&
                          checkoutData.discountCode != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${checkoutData.discountCode} aplicado',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      checkoutData.discountType == 'percentage'
                                          ? '${checkoutData.discountValue}% de descuento'
                                          : '€${checkoutData.discountAmount.toStringAsFixed(2)} de descuento',
                                      style: TextStyle(
                                        color: AppColors.success.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _removeDiscount,
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildBottomButtons() {
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
                onPressed: widget.onBack,
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
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
