import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';

/// Selector de colores circular estilo swatch
/// Muestra los colores disponibles del producto extraídos de sus imágenes
class ColorSelector extends StatelessWidget {
  final List<({String name, String hex})> colors;
  final String? selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  /// Convierte hex string (#RRGGBB) a Color
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Determina si un color es claro para ajustar el checkmark
  bool _isLightColor(String hex) {
    final color = _hexToColor(hex);
    // Fórmula de luminancia relativa
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con nombre del color seleccionado
        Row(
          children: [
            Text(
              'Color',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedColor != null) ...[
              const SizedBox(width: 8),
              Text(
                '· $selectedColor',
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Swatches de colores
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = selectedColor == color.name;
            final swatchColor = _hexToColor(color.hex);
            final isLight = _isLightColor(color.hex);

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onColorSelected(color.name);
              },
              child: Tooltip(
                message: color.name,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: swatchColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonCyan
                          : Colors.white.withValues(alpha: 0.2),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: isLight ? Colors.black87 : Colors.white,
                          size: 22,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
