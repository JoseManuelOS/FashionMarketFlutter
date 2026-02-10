import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Cantidad',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Controles
        Row(
          children: [
            // Botón decrementar
            _buildButton(
              icon: Icons.remove_rounded,
              onTap: quantity > 1
                  ? () {
                      HapticFeedback.selectionClick();
                      onChanged(quantity - 1);
                    }
                  : null,
            ),

            // Cantidad
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  '$quantity',
                  key: ValueKey<int>(quantity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Botón incrementar
            _buildButton(
              icon: Icons.add_rounded,
              onTap: quantity < maxQuantity
                  ? () {
                      HapticFeedback.selectionClick();
                      onChanged(quantity + 1);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isDisabled 
              ? Colors.transparent 
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          color: isDisabled
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
      ),
    );
  }
}
