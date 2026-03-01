import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_colors.dart';

/// Resultado de la recomendación de talla
class SizeResult {
  final String? size;
  final String confidence; // 'alta', 'media', 'baja'
  final String tip;

  const SizeResult({
    required this.size,
    required this.confidence,
    required this.tip,
  });
}

/// Tabla de medidas de referencia (cm)
const Map<String, Map<String, String>> sizeChart = {
  'XS': {'pecho': '86-91', 'cintura': '71-76', 'cadera': '86-91'},
  'S': {'pecho': '91-96', 'cintura': '76-81', 'cadera': '91-96'},
  'M': {'pecho': '96-101', 'cintura': '81-86', 'cadera': '96-101'},
  'L': {'pecho': '101-106', 'cintura': '86-91', 'cadera': '101-106'},
  'XL': {'pecho': '106-111', 'cintura': '91-96', 'cadera': '106-111'},
  'XXL': {'pecho': '111-116', 'cintura': '96-101', 'cadera': '111-116'},
};

/// Calcula la talla recomendada basándose en altura (cm) y peso (kg).
/// Lógica portada de FashionStore SizeRecommender.tsx
SizeResult calculateSize(double altura, double peso) {
  // Validaciones
  if (altura < 140 || altura > 220 || peso < 40 || peso > 150) {
    return const SizeResult(
      size: null,
      confidence: 'baja',
      tip:
          'Los valores ingresados están fuera del rango típico. Por favor, verifica los datos.',
    );
  }

  // IMC como referencia adicional
  final alturaM = altura / 100;
  final imc = peso / (alturaM * alturaM);

  String? size;
  String confidence;
  String tip;

  if (peso < 60 && altura < 170) {
    size = 'S';
    confidence = 'alta';
    tip = 'La talla S es ideal para tu contextura. Ajuste ceñido y cómodo.';
  } else if (peso < 70 && altura < 175) {
    size = 'M';
    confidence = 'alta';
    tip = 'La talla M te quedará perfecta. Es nuestra talla más versátil.';
  } else if (peso >= 70 && peso <= 85 && altura >= 175 && altura <= 185) {
    size = 'L';
    confidence = 'alta';
    tip =
        'La talla L es perfecta para tu complexión. Buen equilibrio entre comodidad y estilo.';
  } else if (peso > 90) {
    size = 'XL';
    confidence = 'alta';
    tip = 'La talla XL te proporcionará el mejor ajuste y comodidad.';
  } else if (altura > 185) {
    if (peso < 75) {
      size = 'L';
      confidence = 'media';
      tip =
          'Recomendamos L. Si prefieres más holgura en longitud, considera XL.';
    } else {
      size = 'XL';
      confidence = 'alta';
      tip =
          'XL es ideal para tu altura. Te dará la longitud perfecta en mangas y torso.';
    }
  } else if (peso < 65 && altura >= 175) {
    size = 'M';
    confidence = 'media';
    tip = 'M debería funcionar bien. Si buscas más longitud, prueba L.';
  } else if (peso >= 85 && peso <= 90) {
    size = 'L';
    confidence = 'media';
    tip = 'Estás entre L y XL. Si prefieres ajuste holgado, ve por XL.';
  } else if (peso >= 60 && peso < 70 && altura >= 175) {
    size = 'M';
    confidence = 'media';
    tip = 'M es una buena opción. Si prefieres más amplitud, considera L.';
  } else {
    // Caso general - usar IMC como guía adicional
    if (imc < 20) {
      size = 'S';
      confidence = 'media';
      tip = 'Basándonos en tu contextura, S sería ideal.';
    } else if (imc < 24) {
      size = 'M';
      confidence = 'media';
      tip = 'Tu complexión indica que M sería una buena elección.';
    } else if (imc < 28) {
      size = 'L';
      confidence = 'media';
      tip = 'Recomendamos L para mejor comodidad.';
    } else {
      size = 'XL';
      confidence = 'alta';
      tip = 'XL te dará el mejor ajuste y confort.';
    }
  }

  return SizeResult(size: size, confidence: confidence, tip: tip);
}

/// Modal bottom-sheet para el recomendador de talla.
/// Muestra formulario con altura/peso, calcula talla y permite seleccionarla.
class SizeRecommenderModal extends StatefulWidget {
  final String productName;
  final List<String> availableSizes;
  final ValueChanged<String>? onSizeSelect;

  const SizeRecommenderModal({
    super.key,
    this.productName = 'esta prenda',
    required this.availableSizes,
    this.onSizeSelect,
  });

  /// Abre el modal como bottom sheet
  static Future<String?> show(
    BuildContext context, {
    String productName = 'esta prenda',
    required List<String> availableSizes,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizeRecommenderModal(
        productName: productName,
        availableSizes: availableSizes,
        onSizeSelect: (size) => Navigator.of(context).pop(size),
      ),
    );
  }

  @override
  State<SizeRecommenderModal> createState() => _SizeRecommenderModalState();
}

class _SizeRecommenderModalState extends State<SizeRecommenderModal> {
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  SizeResult? _result;
  bool _showChart = false;

  @override
  void dispose() {
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _calculate() {
    final altura = double.tryParse(_alturaController.text);
    final peso = double.tryParse(_pesoController.text);

    if (altura == null || peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce valores numéricos válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _result = calculateSize(altura, peso));
  }

  void _reset() {
    setState(() {
      _alturaController.clear();
      _pesoController.clear();
      _result = null;
      _showChart = false;
    });
  }

  void _selectSize() {
    if (_result?.size != null) {
      HapticFeedback.selectionClick();
      widget.onSizeSelect?.call(_result!.size!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF12121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Encuentra tu talla perfecta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Te ayudamos a elegir la talla ideal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.08)),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _result == null ? _buildForm() : _buildResult(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Text(
              'Esta es una recomendacion orientativa. El ajuste puede variar segun el modelo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formulario con campos de altura y peso
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Altura
        Text(
          'Altura (cm)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _alturaController,
          hint: 'Ej: 175',
        ),
        const SizedBox(height: 16),

        // Peso
        Text(
          'Peso (kg)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _pesoController,
          hint: 'Ej: 75',
        ),
        const SizedBox(height: 24),

        // Calcular
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.neonCyan, AppColors.neonFuchsia],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: (_alturaController.text.isNotEmpty &&
                      _pesoController.text.isNotEmpty)
                  ? _calculate
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Calcular mi talla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Guía de tallas toggle
        GestureDetector(
          onTap: () => setState(() => _showChart = !_showChart),
          child: Row(
            children: [
              Icon(
                _showChart
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Ver guía de tallas completa',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        if (_showChart) ...[
          const SizedBox(height: 16),
          _buildSizeChart(),
        ],
      ],
    );
  }

  /// Resultado de la recomendación
  Widget _buildResult() {
    final result = _result!;

    if (result.size == null) {
      // Error o fuera de rango
      return Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pudimos calcular tu talla',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.tip,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildSecondaryButton('Intentar de nuevo', onTap: _reset),
        ],
      );
    }

    // Resultado con talla
    final confidenceColor = switch (result.confidence) {
      'alta' => Colors.green[400]!,
      'media' => Colors.amber[400]!,
      _ => Colors.red[400]!,
    };

    final isAvailable = widget.availableSizes.contains(result.size);

    return Column(
      children: [
        // Talla grande
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.neonCyan.withValues(alpha: 0.2),
                AppColors.neonFuchsia.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.neonCyan, width: 2),
          ),
          child: Center(
            child: Text(
              result.size!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Tu talla recomendada',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Confianza badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: confidenceColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: confidenceColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Confianza ${result.confidence}',
                style: TextStyle(
                  color: confidenceColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tip
        Text(
          result.tip,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Botón seleccionar o aviso
        if (isAvailable) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectSize,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: const Color(0xFF0A0A0F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Seleccionar talla ${result.size}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber[400], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La talla ${result.size} no está disponible para este producto',
                    style: TextStyle(
                      color: Colors.amber[300],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildSecondaryButton('Calcular de nuevo', onTap: _reset),
      ],
    );
  }

  /// Campo de texto para números (altura / peso)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }

  /// Tabla de tallas
  Widget _buildSizeChart() {
    final filtered = sizeChart.entries
        .where((e) => widget.availableSizes.contains(e.key))
        .toList();

    return Table(
      border: TableBorder(
        horizontalInside:
            BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      columnWidths: const {
        0: FixedColumnWidth(60),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          children: [
            _tableHeaderCell('Talla'),
            _tableHeaderCell('Pecho'),
            _tableHeaderCell('Cintura'),
            _tableHeaderCell('Cadera'),
          ],
        ),
        // Data rows
        ...filtered.map(
          (e) => TableRow(
            children: [
              _tableCell(e.key, bold: true),
              _tableCell(e.value['pecho']!),
              _tableCell(e.value['cintura']!),
              _tableCell(e.value['cadera']!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: bold ? Colors.white : Colors.white.withValues(alpha: 0.7),
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
