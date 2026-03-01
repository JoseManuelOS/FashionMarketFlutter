import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../data/models/product_model.dart';

/// Botón reutilizable de "Añadir al Carrito".
///
/// Encapsula toda la lógica de:
/// - Validación de stock
/// - Creación del CartItemModel
/// - Feedback visual (loading, success, agotado)
///
/// Uso:
/// ```dart
/// AddToCartButton(
///   product: product,
///   selectedSize: 'M',
///   selectedColor: 'Negro',
///   quantity: 1,
///   currentSizeStock: 5,
/// )
/// ```
class AddToCartButton extends ConsumerStatefulWidget {
  final ProductModel product;
  final String? selectedSize;
  final String? selectedColor;
  final int quantity;
  final int currentSizeStock;

  /// Callback opcional ejecutado cuando se añade exitosamente al carrito.
  final VoidCallback? onAdded;

  const AddToCartButton({
    super.key,
    required this.product,
    required this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
    required this.currentSizeStock,
    this.onAdded,
  });

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _isAdding = false;
  bool _showSuccess = false;

  bool get _isOutOfStock => widget.currentSizeStock <= 0;

  void _handleAddToCart() async {
    if (_isOutOfStock || widget.selectedSize == null) return;

    final cart = ref.read(cartNotifierProvider);
    final existingItem = cart
        .where(
          (item) =>
              item.productId == widget.product.id &&
              item.size == widget.selectedSize &&
              item.color == widget.selectedColor,
        )
        .toList();

    final currentQty =
        existingItem.isNotEmpty ? existingItem.first.quantity : 0;

    if (currentQty + widget.quantity > widget.currentSizeStock) {
      _showStockAlert();
      return;
    }

    setState(() => _isAdding = true);

    // Obtener imagen del color seleccionado
    final colorImages = widget.product.imagesForColor(widget.selectedColor);
    final itemImage = colorImages.isNotEmpty
        ? colorImages.first.imageUrl
        : widget.product.mainImageUrl;

    // Añadir al carrito
    ref.read(cartNotifierProvider.notifier).addItem(
          CartItemModel(
            id: '${widget.product.id}_${widget.selectedSize}_${widget.selectedColor ?? ''}',
            productId: widget.product.id,
            name: widget.product.name,
            slug: widget.product.slug,
            price: widget.product.price,
            imageUrl: itemImage,
            size: widget.selectedSize!,
            color: widget.selectedColor,
            quantity: widget.quantity,
            originalPrice: widget.product.originalPrice,
            discountPercent: widget.product.discountPercent ?? 0,
          ),
        );

    // Feedback visual
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _isAdding = false;
        _showSuccess = true;
      });

      widget.onAdded?.call();

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _showSuccess = false);
      }
    }
  }

  void _showStockAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Solo hay ${widget.currentSizeStock} unidades de talla ${widget.selectedSize} disponibles',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.neonFuchsia,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _isOutOfStock || _isAdding ? null : _handleAddToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: _showSuccess
                ? Colors.green
                : _isOutOfStock
                    ? AppColors.dark400
                    : null,
            disabledBackgroundColor: _isAdding
                ? AppColors.neonCyan.withValues(alpha: 0.5)
                : AppColors.dark400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _showSuccess ? 0 : 8,
            shadowColor: _showSuccess
                ? Colors.green
                : AppColors.neonCyan.withValues(alpha: 0.5),
          ),
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isAdding) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Añadiendo...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_showSuccess) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, color: Colors.white),
          SizedBox(width: 8),
          Text(
            '¡Añadido al carrito!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_isOutOfStock) {
      return Text(
        'Agotado',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const Text(
      'Añadir al Carrito',
      style: TextStyle(
        color: AppColors.dark600,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
