import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/checkout_providers.dart';

/// Paso 2: Método de envío
class CheckoutStepShippingMethod extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const CheckoutStepShippingMethod({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  ConsumerState<CheckoutStepShippingMethod> createState() =>
      _CheckoutStepShippingMethodState();
}

class _CheckoutStepShippingMethodState
    extends ConsumerState<CheckoutStepShippingMethod> {
  int? _selectedMethodId;

  @override
  void initState() {
    super.initState();
    final data = ref.read(checkoutDataProvider);
    _selectedMethodId = data.shippingMethodId;
  }

  void _selectMethod(ShippingMethod method) {
    setState(() => _selectedMethodId = method.id);
    ref.read(checkoutDataProvider.notifier).setShippingMethod(
          id: method.id,
          name: '${method.name} (${method.estimatedDays ?? ""})',
          cost: method.price,
        );
  }

  @override
  Widget build(BuildContext context) {
    final methodsAsync = ref.watch(shippingMethodsProvider);

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
                        'Método de Envío',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      methodsAsync.when(
                        data: (methods) => Column(
                          children: methods.map((method) {
                            final isSelected = _selectedMethodId == method.id;
                            return _buildMethodCard(method, isSelected);
                          }).toList(),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonCyan,
                          ),
                        ),
                        error: (e, _) => Center(
                          child: Text(
                            'Error al cargar métodos de envío',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ),
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

  Widget _buildMethodCard(ShippingMethod method, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.1)
              : AppColors.dark300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.neonCyan : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (method.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      method.description!,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (method.estimatedDays != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      method.estimatedDays!,
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              method.price > 0 ? '€${method.price.toStringAsFixed(2)}' : 'Gratis',
              style: TextStyle(
                color: method.price > 0 ? AppColors.textPrimary : AppColors.neonCyan,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
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
                onPressed: _selectedMethodId != null ? widget.onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.textOnPrimary,
                  disabledBackgroundColor: AppColors.dark400,
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
