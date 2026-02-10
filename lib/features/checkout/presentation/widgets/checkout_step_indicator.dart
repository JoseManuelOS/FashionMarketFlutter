import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Indicador de pasos del checkout
class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTap;

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.onStepTap,
  });

  static const _steps = ['Datos', 'Envío', 'Descuento', 'Resumen'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: AppColors.dark500,
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Línea entre pasos
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < currentStep
                    ? AppColors.success
                    : AppColors.glassBorder,
              ),
            );
          } else {
            // Círculo del paso
            final stepIndex = index ~/ 2;
            return _buildStep(stepIndex);
          }
        }),
      ),
    );
  }

  Widget _buildStep(int index) {
    final isCompleted = index < currentStep;
    final isActive = index == currentStep;

    return GestureDetector(
      onTap: index <= currentStep ? () => onStepTap(index) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.neonCyan
                      : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? AppColors.success
                    : isActive
                        ? AppColors.neonCyan
                        : AppColors.glassBorder,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.textOnPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _steps[index],
            style: TextStyle(
              color: isActive ? AppColors.neonCyan : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
