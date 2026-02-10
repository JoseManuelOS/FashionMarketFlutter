import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../providers/product_providers.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/size_selector.dart';
import '../widgets/quantity_selector.dart';
import '../../../../shared/widgets/size_recommender_modal.dart';
import '../widgets/product_features.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  int _quantity = 1;
  bool _isAdding = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    // Seleccionar primera talla disponible
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
  }

  int get _currentSizeStock {
    if (_selectedSize == null) return widget.product.stock;
    return widget.product.stockBySize?[_selectedSize] ?? widget.product.stock;
  }

  bool get _isOutOfStock => _currentSizeStock <= 0;

  void _handleAddToCart() async {
    if (_isOutOfStock || _selectedSize == null) return;

    final cart = ref.read(cartNotifierProvider);
    final existingItem = cart.where(
      (item) => item.productId == widget.product.id && item.size == _selectedSize,
    ).toList();

    final currentQty = existingItem.isNotEmpty ? existingItem.first.quantity : 0;

    if (currentQty + _quantity > _currentSizeStock) {
      _showStockAlert();
      return;
    }

    setState(() => _isAdding = true);

    // Añadir al carrito
    ref.read(cartNotifierProvider.notifier).addItem(
      CartItemModel(
        id: '${widget.product.id}_$_selectedSize',
        productId: widget.product.id,
        name: widget.product.name,
        slug: widget.product.slug,
        price: widget.product.price,
        imageUrl: widget.product.mainImageUrl,
        size: _selectedSize!,
        quantity: _quantity,
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
          'Solo hay $_currentSizeStock unidades de talla $_selectedSize disponibles',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.neonFuchsia,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareProduct() {
    Share.share(
      '¡Mira este producto! ${widget.product.name} en FashionMarket',
      subject: widget.product.name,
    );
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    ref.read(favoriteIdsProvider.notifier).toggle(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cart = ref.watch(cartNotifierProvider);
    
    // Buscar si ya está en carrito con la talla seleccionada
    final itemInCart = _selectedSize != null
        ? cart.where((item) => 
            item.productId == product.id && item.size == _selectedSize
          ).toList()
        : [];

    return Scaffold(
      backgroundColor: AppColors.dark600,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          _buildSliverAppBar(context),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  if (product.category != null)
                    GestureDetector(
                      onTap: () => context.push('/categoria/${product.category!.slug}'),
                      child: Text(
                        product.category!.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Precio
                  _buildPriceSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Descripción
                  if (product.description != null && product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        product.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  
                  // Card de selección
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de talla
                        if (product.sizes.isNotEmpty) ...[
                          SizeSelector(
                            sizes: product.sizes,
                            selectedSize: _selectedSize,
                            stockBySize: product.stockBySize ?? {},
                            onSizeSelected: (size) {
                              setState(() {
                                _selectedSize = size;
                                _quantity = 1;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Botón recomendador de talla
                          GestureDetector(
                            onTap: () async {
                              final size = await SizeRecommenderModal.show(
                                context,
                                productName: product.name,
                                availableSizes: product.sizes,
                              );
                              if (size != null && mounted) {
                                setState(() {
                                  _selectedSize = size;
                                  _quantity = 1;
                                });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.straighten,
                                  size: 16,
                                  color: AppColors.neonCyan,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '¿Cuál es mi talla?',
                                  style: TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.neonCyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Selector de cantidad
                        QuantitySelector(
                          quantity: _quantity,
                          maxQuantity: _currentSizeStock,
                          onChanged: (qty) => setState(() => _quantity = qty),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Info de stock
                        _buildStockInfo(),
                        
                        const SizedBox(height: 24),
                        
                        // Botón añadir al carrito
                        _buildAddToCartButton(),
                        
                        // Aviso si ya está en carrito
                        if (itemInCart.isNotEmpty && !_showSuccess)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Ya tienes ${itemInCart.first.quantity} unidad(es) de talla ${itemInCart.first.size} en el carrito',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Features del producto
                  const ProductFeatures(),
                  
                  const SizedBox(height: 32),
                  
                  // Productos relacionados
                  _buildRelatedProducts(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    final params = (
      productId: widget.product.id,
      categoryId: widget.product.categoryId,
    );
    final relatedAsync = ref.watch(relatedProductsProvider(params));

    return relatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.glassBorder, height: 32),
            const Text(
              'También te puede gustar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = related[index];
                  return _buildRelatedProductCard(context, product);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildRelatedProductCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () => context.push('/productos/${product.slug}'),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 160,
                color: AppColors.dark400,
                child: product.mainImageUrl.isNotEmpty
                    ? Image.network(
                        product.mainImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported,
                              color: AppColors.textSubtle, size: 28),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined,
                            color: AppColors.textSubtle, size: 28),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Nombre
            Text(
              product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Precio
            Text(
              '€${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.neonCyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final isFav = ref.watch(isFavoriteProvider(widget.product.id));
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.55,
      pinned: true,
      backgroundColor: AppColors.dark600,
      leading: _buildCircularButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        _buildCircularButton(
          icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          onTap: _toggleFavorite,
          iconColor: isFav ? AppColors.neonFuchsia : Colors.white,
        ),
        const SizedBox(width: 8),
        _buildCircularButton(
          icon: Icons.share_rounded,
          onTap: _shareProduct,
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Galería de imágenes
            ProductImageGallery(
              images: widget.product.images,
              isOffer: widget.product.isOffer,
              discountPercentage: widget.product.discountPercentage,
            ),
            
            // Gradient overlay inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.dark600.withValues(alpha: 0.8),
                      AppColors.dark600,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: AppColors.dark500.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final product = widget.product;
    final hasDiscount = product.originalPrice != null && 
                        product.originalPrice! > product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Precio actual
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            '€${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        if (hasDiscount) ...[
          const SizedBox(width: 12),
          Text(
            '€${product.originalPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonFuchsia.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-${product.discountPercentage?.toStringAsFixed(0) ?? ''}%',
              style: const TextStyle(
                color: AppColors.neonFuchsia,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockInfo() {
    final stockColor = _currentSizeStock > 5
        ? Colors.green
        : _currentSizeStock > 0
            ? AppColors.neonFuchsia
            : Colors.red;

    final stockText = _isOutOfStock
        ? 'Talla $_selectedSize agotada'
        : _currentSizeStock <= 3
            ? '¡Solo quedan $_currentSizeStock unidades en talla $_selectedSize!'
            : '$_currentSizeStock unidades en talla $_selectedSize';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: stockColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          stockText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
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
            shadowColor: _showSuccess ? Colors.green : AppColors.neonCyan.withValues(alpha: 0.5),
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
