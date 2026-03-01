import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/product_model.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../providers/product_providers.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/add_to_cart_btn.dart';
import '../widgets/size_selector.dart';
import '../widgets/color_selector.dart';
import '../widgets/quantity_selector.dart';
import '../../../../shared/widgets/size_recommender_modal.dart';
import '../widgets/product_features.dart';
import '../../../cart/presentation/widgets/cart_slide_over.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  final String? heroTag;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  /// Stock en tiempo real por talla (obtenido de la API)
  Map<String, int>? _liveStockBySize;

  @override
  void initState() {
    super.initState();
    // Seleccionar primer color disponible
    final colors = widget.product.colors;
    if (colors.isNotEmpty) {
      _selectedColor = colors.first.name;
    }
    // Seleccionar primera talla disponible
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    // Obtener stock en tiempo real desde la API
    _fetchLiveStock();
  }

  /// Obtiene el stock real por talla desde la API de FashionStore
  Future<void> _fetchLiveStock() async {
    try {
      var result = await FashionStoreApiService.getStockBySize(
        productId: widget.product.id,
        color: _selectedColor,
      );
      var stockBySize = result['stockBySize'];

      // Si el filtro por color no devolvió variantes, reintentar sin color.
      // Esto ocurre cuando product_variants.color está vacío ('') pero
      // la app usa nombres de color de product_images (ej. "Rojo").
      if (_selectedColor != null &&
          (stockBySize == null ||
              (stockBySize is Map && stockBySize.isEmpty))) {
        result = await FashionStoreApiService.getStockBySize(
          productId: widget.product.id,
        );
        stockBySize = result['stockBySize'];
      }

      if (mounted && stockBySize != null && stockBySize is Map && stockBySize.isNotEmpty) {
        setState(() {
          _liveStockBySize = Map<String, int>.from(
            stockBySize.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
          );
        });
      }
    } catch (_) {
      // Silently fall back to initial stockBySize from model
    }
  }

  /// Stock por talla: prioriza datos en tiempo real, luego per-color del modelo, luego general
  Map<String, int> get _effectiveStockBySize {
    if (_liveStockBySize != null) return _liveStockBySize!;
    return widget.product.stockForColor(_selectedColor);
  }

  int get _currentSizeStock {
    if (_selectedSize == null) return widget.product.stock;
    final sizeStock = _effectiveStockBySize[_selectedSize];
    if (sizeStock != null) return sizeStock;
    // Fallback: stock por talla (agregado entre colores), NO el stock total
    return widget.product.stockBySize?[_selectedSize] ?? 0;
  }

  bool get _isOutOfStock => _currentSizeStock <= 0;

  void _shareProduct() {
    Share.share(
      '¡Mira este producto! ${widget.product.name} en FashionMarket',
      subject: widget.product.name,
    );
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    if (!SupabaseService.isAuthenticated) {
      _showLoginRequired();
      return;
    }
    ref.read(favoriteIdsProvider.notifier).toggle(widget.product.id);
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Inicia sesión para añadir favoritos'),
        backgroundColor: AppColors.dark500,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Iniciar sesión',
          textColor: AppColors.neonCyan,
          onPressed: () => context.push(AppRoutes.login),
        ),
      ),
    );
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
                        // Selector de color
                        if (product.colors.isNotEmpty) ...[                          ColorSelector(
                            colors: product.colors,
                            selectedColor: _selectedColor,
                            onColorSelected: (color) {
                              setState(() {
                                _selectedColor = color;
                                _quantity = 1;
                                _liveStockBySize = null;
                              });
                              _fetchLiveStock();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Selector de talla
                        if (product.sizes.isNotEmpty) ...[
                          SizeSelector(
                            sizes: product.sizes,
                            selectedSize: _selectedSize,
                            stockBySize: _effectiveStockBySize,
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
                        AddToCartButton(
                          product: widget.product,
                          selectedSize: _selectedSize,
                          selectedColor: _selectedColor,
                          quantity: _quantity,
                          currentSizeStock: _currentSizeStock,
                        ),
                        
                        // Aviso si ya está en carrito
                        if (itemInCart.isNotEmpty)
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
        const SizedBox(width: 8),
        // Carrito con badge de cantidad
        _buildCartButton(context),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Galería de imágenes (filtrada por color si hay seleccionado)
            ProductImageGallery(
              images: widget.product.imagesForColor(_selectedColor),
              isOffer: widget.product.isOffer,
              discountPercentage: widget.product.discountPercentage,
              heroTag: widget.heroTag ?? 'product-hero-${widget.product.slug}',
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

  Widget _buildCartButton(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: AppColors.dark500.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => CartSlideOver.show(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                if (cartCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.neonFuchsia,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
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
        Text(
          '€${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontSize: 32,
            fontWeight: FontWeight.bold,
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
}
