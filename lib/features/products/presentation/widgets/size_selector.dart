import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';

enum SizeStockStatus { available, low, out, unknown }

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selectedSize;
  final Map<String, int> stockBySize;
  final ValueChanged<String> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.stockBySize,
    required this.onSizeSelected,
  });

  SizeStockStatus _getSizeStockStatus(String size) {
    final stock = stockBySize[size];
    if (stock == null) {
      // Si tenemos datos de stock para otras tallas pero no para esta,
      // significa que esta talla no tiene variante → agotada
      if (stockBySize.isNotEmpty) return SizeStockStatus.out;
      return SizeStockStatus.unknown;
    }
    if (stock <= 0) return SizeStockStatus.out;
    if (stock <= 3) return SizeStockStatus.low;
    return SizeStockStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Talla',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Botones de tallas
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sizes.map((size) {
            final status = _getSizeStockStatus(size);
            final isDisabled = status == SizeStockStatus.out;
            final isSelected = selectedSize == size;

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onSizeSelected(size);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonCyan.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDisabled
                        ? Colors.white.withValues(alpha: 0.1)
                        : isSelected
                            ? AppColors.neonCyan
                            : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Texto de la talla
                    Text(
                      size,
                      style: TextStyle(
                        color: isDisabled
                            ? Colors.white.withValues(alpha: 0.3)
                            : isSelected
                                ? AppColors.neonCyan
                                : Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: isDisabled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    // Indicador de pocas unidades
                    if (status == SizeStockStatus.low && !isDisabled)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.neonFuchsia,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Leyenda
        if (stockBySize.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem(
                color: AppColors.neonFuchsia,
                text: 'Últimas unidades',
                pulsing: true,
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                color: Colors.white.withValues(alpha: 0.3),
                text: 'Agotado',
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    bool pulsing = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
