import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Modelo interno de color para productos
class ProductColor {
  String name;
  String hex;

  ProductColor({required this.name, required this.hex});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      name: json['name'] as String? ?? '',
      hex: json['hex'] as String? ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'hex': hex};

  Color get color {
    try {
      final hexStr = hex.replaceFirst('#', '');
      return Color(int.parse('FF$hexStr', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductColor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          hex == other.hex;

  @override
  int get hashCode => name.hashCode ^ hex.hashCode;
}

/// Widget para editar colores de un producto.
/// Permite añadir/eliminar colores con nombre y selector de color hex.
class ColorEditorWidget extends StatefulWidget {
  final List<ProductColor> initialColors;
  final ValueChanged<List<ProductColor>> onChanged;

  const ColorEditorWidget({
    super.key,
    this.initialColors = const [],
    required this.onChanged,
  });

  @override
  State<ColorEditorWidget> createState() => _ColorEditorWidgetState();
}

class _ColorEditorWidgetState extends State<ColorEditorWidget> {
  late List<ProductColor> _colors;

  @override
  void initState() {
    super.initState();
    _colors = List.from(widget.initialColors);
  }

  void _notifyChange() {
    widget.onChanged(List.from(_colors));
  }

  void _addColor() {
    _showColorDialog(null);
  }

  void _editColor(int index) {
    _showColorDialog(index);
  }

  void _removeColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
    _notifyChange();
  }

  void _showColorDialog(int? editIndex) {
    final isEditing = editIndex != null;
    final nameCtrl = TextEditingController(
      text: isEditing ? _colors[editIndex].name : '',
    );
    String selectedHex = isEditing ? _colors[editIndex].hex : '#000000';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Color previewColor;
            try {
              final h = selectedHex.replaceFirst('#', '');
              previewColor = Color(int.parse('FF$h', radix: 16));
            } catch (_) {
              previewColor = Colors.grey;
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF12121A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isEditing ? 'Editar Color' : 'Añadir Color',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre del color
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre del color',
                      labelStyle: TextStyle(color: Colors.grey[500]),
                      hintText: 'Ej: Negro, Blanco, Rojo...',
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preview + hex input
                  Row(
                    children: [
                      // Color preview circle
                      GestureDetector(
                        onTap: () => _showColorPicker(
                          ctx,
                          selectedHex,
                          (hex) {
                            setDialogState(() => selectedHex = hex);
                          },
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: previewColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Hex input
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                          controller: TextEditingController(text: selectedHex),
                          onChanged: (v) {
                            if (v.startsWith('#') && v.length == 7) {
                              setDialogState(() => selectedHex = v);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Código HEX',
                            labelStyle: TextStyle(color: Colors.grey[500]),
                            hintText: '#000000',
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: const Color(0xFF0A0A0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Paleta rápida
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Colores rápidos',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickColors.map((qc) {
                      final isSelected = qc['hex'] == selectedHex;
                      Color qColor;
                      try {
                        final h = (qc['hex'] as String).replaceFirst('#', '');
                        qColor = Color(int.parse('FF$h', radix: 16));
                      } catch (_) {
                        qColor = Colors.grey;
                      }
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedHex = qc['hex']!;
                            if (nameCtrl.text.isEmpty) {
                              nameCtrl.text = qc['name']!;
                            }
                          });
                        },
                        child: Tooltip(
                          message: qc['name']!,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: qColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.neonCyan
                                    : Colors.white.withValues(alpha: 0.2),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    setState(() {
                      if (isEditing) {
                        _colors[editIndex] = ProductColor(
                          name: name,
                          hex: selectedHex,
                        );
                      } else {
                        _colors.add(ProductColor(
                          name: name,
                          hex: selectedHex,
                        ));
                      }
                    });
                    _notifyChange();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(isEditing ? 'Guardar' : 'Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showColorPicker(
    BuildContext ctx,
    String currentHex,
    ValueChanged<String> onPick,
  ) {
    showDialog(
      context: ctx,
      builder: (pickerCtx) {
        String tempHex = currentHex;
        return StatefulBuilder(
          builder: (pickerCtx, setPickerState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF12121A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Seleccionar color',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              content: SizedBox(
                width: 280,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _extendedColors.map((hex) {
                    final isSelected = hex == tempHex;
                    Color c;
                    try {
                      final h = hex.replaceFirst('#', '');
                      c = Color(int.parse('FF$h', radix: 16));
                    } catch (_) {
                      c = Colors.grey;
                    }
                    return GestureDetector(
                      onTap: () {
                        setPickerState(() => tempHex = hex);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonCyan
                                : Colors.white.withValues(alpha: 0.2),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(pickerCtx),
                  child: Text('Cancelar',
                      style: TextStyle(color: Colors.grey[500])),
                ),
                ElevatedButton(
                  onPressed: () {
                    onPick(tempHex);
                    Navigator.pop(pickerCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonCyan,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Seleccionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.palette_outlined,
                color: AppColors.neonCyan, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Colores del producto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addColor,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neonCyan,
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_colors.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.grey[600], size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sin colores definidos. El stock será solo por talla.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_colors.length, (i) {
              final pc = _colors[i];
              return GestureDetector(
                onTap: () => _editColor(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: pc.color.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: pc.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pc.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeColor(i),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  static const _quickColors = [
    {'name': 'Negro', 'hex': '#000000'},
    {'name': 'Blanco', 'hex': '#FFFFFF'},
    {'name': 'Gris', 'hex': '#808080'},
    {'name': 'Rojo', 'hex': '#FF0000'},
    {'name': 'Azul', 'hex': '#0066CC'},
    {'name': 'Verde', 'hex': '#228B22'},
    {'name': 'Amarillo', 'hex': '#FFD700'},
    {'name': 'Rosa', 'hex': '#FF69B4'},
    {'name': 'Naranja', 'hex': '#FF8C00'},
    {'name': 'Marrón', 'hex': '#8B4513'},
    {'name': 'Beige', 'hex': '#F5DEB3'},
    {'name': 'Morado', 'hex': '#8B008B'},
  ];

  static const _extendedColors = [
    '#000000', '#333333', '#666666', '#999999', '#CCCCCC', '#FFFFFF',
    '#FF0000', '#FF4444', '#FF6666', '#CC0000', '#990000',
    '#FF8C00', '#FFA500', '#FFD700', '#FFFF00',
    '#228B22', '#32CD32', '#00FF00', '#006400', '#2E8B57',
    '#0066CC', '#0000FF', '#4169E1', '#000080', '#00CED1',
    '#8B008B', '#9932CC', '#800080', '#FF00FF', '#DA70D6',
    '#FF69B4', '#FF1493', '#C71585',
    '#8B4513', '#A0522D', '#D2691E', '#F5DEB3', '#DEB887',
  ];
}
