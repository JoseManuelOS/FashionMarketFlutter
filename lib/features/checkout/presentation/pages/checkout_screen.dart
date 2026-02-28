import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/checkout_providers.dart';
import '../widgets/checkout_step_indicator.dart';
import '../widgets/checkout_step_shipping_data.dart';
import '../widgets/checkout_step_shipping_method.dart';
import '../widgets/checkout_step_discount.dart';
import '../widgets/checkout_step_summary.dart';

/// Pantalla de checkout con stepper de 4 pasos
/// Igual que la web: 1. Datos, 2. Envío, 3. Descuento, 4. Resumen
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    final currentStep = ref.read(checkoutStepProvider);
    
    // Validar antes de avanzar
    if (step > currentStep) {
      if (!_validateStep(currentStep)) return;
    }
    
    ref.read(checkoutStepProvider.notifier).state = step;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep(int step) {
    final checkoutData = ref.read(checkoutDataProvider);
    
    switch (step) {
      case 0: // Datos de envío
        if (checkoutData.email.isEmpty ||
            checkoutData.fullName.isEmpty ||
            checkoutData.phone.isEmpty ||
            checkoutData.street.isEmpty ||
            checkoutData.city.isEmpty ||
            checkoutData.postalCode.isEmpty) {
          _showError('Por favor, completa todos los campos obligatorios');
          return false;
        }
        if (!checkoutData.email.contains('@')) {
          _showError('Por favor, introduce un email válido');
          return false;
        }
        return true;
        
      case 1: // Método de envío
        if (checkoutData.shippingMethodId == null) {
          _showError('Por favor, selecciona un método de envío');
          return false;
        }
        return true;
        
      case 2: // Descuento (opcional)
        return true;
        
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(checkoutStepProvider);
    final cartItems = ref.watch(cartNotifierProvider);

    // Si el carrito está vacío, redirigir
    if (cartItems.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/carrito');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark500.withValues(alpha: 0.95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (currentStep > 0) {
              _goToStep(currentStep - 1);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          CheckoutStepIndicator(
            currentStep: currentStep,
            onStepTap: _goToStep,
          ),

          // Steps content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CheckoutStepShippingData(
                  onContinue: () => _goToStep(1),
                ),
                CheckoutStepShippingMethod(
                  onBack: () => _goToStep(0),
                  onContinue: () => _goToStep(2),
                ),
                CheckoutStepDiscount(
                  onBack: () => _goToStep(1),
                  onContinue: () => _goToStep(3),
                ),
                CheckoutStepSummary(
                  onBack: () => _goToStep(2),
                  onEditAddress: () => _goToStep(0),
                  onEditShipping: () => _goToStep(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
