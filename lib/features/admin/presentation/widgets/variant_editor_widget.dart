import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import 'color_editor_widget.dart';

/// Widget para editar variantes (tallas × colores) de un producto.
/// Cuando hay colores definidos, muestra una cuadrícula talla×color.
/// Sin colores, muestra la lista simple de talla+stock.
class VariantEditorWidget extends StatefulWidget {
  final List<Map<String, dynamic>> initialVariants;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final List<ProductColor> colors;

  const VariantEditorWidget({
    super.key,
    this.initialVariants = const [],
    required this.onChanged,
    this.colors = const [],
  });

  @override
  State<VariantEditorWidget> createState() => _VariantEditorWidgetState();
}

class _VariantEditorWidgetState extends State<VariantEditorWidget> {
  late List<_VariantEntry> _variants;

  static const List<String> _predefinedSizes = [
    'XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL',
    '36', '38', '40', '42', '44', '46', '48',
    'Única',
  ];

  bool get _hasColors => widget.colors.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _variants = widget.initialVariants.map((v) => _VariantEntry(
          size: v['size'] as String? ?? '',
          stock: v['stock'] as int? ?? 0,
          sku: v['sku'] as String?,
          price: (v['price'] as num?)?.toDouble(),
          color: v['color'] as String?,
        )).toList();
  }

  @override
  void didUpdateWidget(covariant VariantEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When colors change, rebuild grid entries
    if (_hasColors && widget.colors != oldWidget.colors) {
      _rebuildForColors();
    }
  }

  /// Rebuild variant entries to match current colors × existing sizes
  void _rebuildForColors() {
    final existingSizes = _variants.map((v) => v.size).toSet();
    final colorNames = widget.colors.map((c) => c.name).toSet();

    // Build a lookup of existing stock by (size, color)
    final stockMap = <String, int>{};
    for (final v in _variants) {
      stockMap['${v.size}|${v.color ?? ''}'] = v.stock;
    }

    final newVariants = <_VariantEntry>[];
    for (final size in existingSizes) {
      if (size.isEmpty) continue;
      for (final pc in widget.colors) {
        final key = '$size|${pc.name}';
        newVariants.add(_VariantEntry(
          size: size,
          stock: stockMap[key] ?? stockMap['$size|'] ?? 0,
          color: pc.name,
        ));
      }
    }

    // Remove entries whose color no longer exists
    setState(() {
      _variants = newVariants.where((v) =>
          v.color == null || colorNames.contains(v.color)).toList();
    });
    _notifyChange();
  }

  void _notifyChange() {
    widget.onChanged(_variants
        .where((v) => v.size.isNotEmpty)
        .map((v) => {
              'size': v.size,
              'stock': v.stock,
              'sku': v.sku,
              'price': v.price,
              if (v.color != null) 'color': v.color,
            })
        .toList());
  }

  void _addVariant([String? size]) {
    if (_hasColors) {
      // Add one entry per color for this size
      setState(() {
        for (final pc in widget.colors) {
          _variants.add(_VariantEntry(
            size: size ?? '',
            stock: 0,
            color: pc.name,
          ));
        }
      });
    } else {
      setState(() {
        _variants.add(_VariantEntry(size: size ?? '', stock: 0));
      });
    }
    _notifyChange();
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
    _notifyChange();
  }

  /// Remove all entries for a given size
  void _removeSize(String size) {
    setState(() {
      _variants.removeWhere((v) => v.size == size);
    });
    _notifyChange();
  }

  void _addQuickSizes() {
    final existing = _variants.map((v) => v.size.toUpperCase()).toSet();
    final basicSizes = ['S', 'M', 'L', 'XL'];

    for (final size in basicSizes) {
      if (!existing.contains(size)) {
        if (_hasColors) {
          for (final pc in widget.colors) {
            _variants.add(_VariantEntry(size: size, stock: 10, color: pc.name));
          }
        } else {
          _variants.add(_VariantEntry(size: size, stock: 10));
        }
      }
    }
    setState(() {});
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _hasColors ? 'Stock por Talla × Color' : 'Variantes / Tallas',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _addQuickSizes,
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('S-M-L-XL', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _addVariant(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Añadir', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Empty state: show predefined size chips
        if (_variants.isEmpty) ...[
          Text(
            'Selecciona tallas para añadir:',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _predefinedSizes.map((size) {
              return ActionChip(
                label: Text(size,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: const Color(0xFF1A1A24),
                side: BorderSide(color: AppColors.neonCyan.withValues(alpha: 0.3)),
                onPressed: () => _addVariant(size),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // =========== COLOR GRID MODE ===========
        if (_hasColors && _variants.isNotEmpty)
          _buildColorGrid()
        // =========== SIMPLE LIST MODE ===========
        else
          ...List.generate(_variants.length, (index) {
            final variant = _variants[index];
            return _buildVariantRow(variant, index);
          }),

        // Total stock
        if (_variants.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Stock total: ${_variants.fold<int>(0, (sum, v) => sum + v.stock)} unidades',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Build grid mode: rows = sizes, columns = colors
  Widget _buildColorGrid() {
    // Get unique sizes preserving order
    final sizes = <String>[];
    for (final v in _variants) {
      if (!sizes.contains(v.size) && v.size.isNotEmpty) sizes.add(v.size);
    }

    return Column(
      children: [
        // Header row with color indicators
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A24),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('Talla',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              ...widget.colors.map((pc) => Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: pc.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            pc.name,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(width: 32), // space for delete button
            ],
          ),
        ),

        // Data rows per size
        ...sizes.map((size) => _buildGridRow(size)),
      ],
    );
  }

  Widget _buildGridRow(String size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          // Size label
          SizedBox(
            width: 60,
            child: Text(
              size,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Stock input per color
          ...widget.colors.map((pc) {
            final variant = _variants.firstWhere(
              (v) => v.size == size && v.color == pc.name,
              orElse: () {
                final nv = _VariantEntry(size: size, stock: 0, color: pc.name);
                _variants.add(nv);
                return nv;
              },
            );
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextField(
                  controller: TextEditingController(text: variant.stock.toString()),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: variant.stock > 0 ? Colors.white : Colors.grey[600],
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0D0D14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    variant.stock = int.tryParse(value) ?? 0;
                    _notifyChange();
                    setState(() {});
                  },
                ),
              ),
            );
          }),
          // Delete button for this size row
          SizedBox(
            width: 32,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.grey[600], size: 16),
              onPressed: () => _removeSize(size),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple row for non-color mode
  Widget _buildVariantRow(_VariantEntry variant, int index) {
    final sizeController = TextEditingController(text: variant.size);
    final stockController = TextEditingController(text: variant.stock.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Talla
          SizedBox(
            width: 70,
            child: TextField(
              controller: sizeController,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Talla',
                hintStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0D0D14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                variant.size = value;
                _notifyChange();
              },
            ),
          ),
          const SizedBox(width: 8),

          // Stock
          SizedBox(
            width: 70,
            child: TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Stock',
                hintStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0D0D14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                variant.stock = int.tryParse(value) ?? 0;
                _notifyChange();
              },
            ),
          ),
          const SizedBox(width: 8),

          // Indicadores
          Expanded(
            child: Row(
              children: [
                if (variant.stock == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Sin stock',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  )
                else if (variant.stock <= 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${variant.stock} uds',
                      style: const TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),

          // Eliminar
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600], size: 18),
            onPressed: () => _removeVariant(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _VariantEntry {
  String size;
  int stock;
  String? sku;
  double? price;
  String? color;

  _VariantEntry({
    required this.size,
    required this.stock,
    this.sku,
    this.price,
    this.color,
  });
}
