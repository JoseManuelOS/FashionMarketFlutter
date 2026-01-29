import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/product_providers.dart';

/// Página de detalle de un producto
class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: AppLoader()),
        error: (error, stack) => AppErrorWidget(
          title: 'Error al cargar producto',
          message: error.toString(),
          onRetry: () =>
              ref.read(productDetailProvider(productId).notifier).refresh(),
        ),
        data: (product) {
          return CustomScrollView(
            slivers: [
              // App Bar con imagen
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // TODO: Agregar a favoritos
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Compartir producto
                    },
                  ),
                ],
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y precio
                      Text(
                        product.name,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.formattedPrice,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock
                      Row(
                        children: [
                          Icon(
                            product.hasStock
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: product.hasStock
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.hasStock
                                ? 'En stock (${product.stockQuantity} disponibles)'
                                : 'Sin stock',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: product.hasStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Descripción
                      Text(
                        'Descripción',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 100), // Espacio para el botón
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: productAsync.whenOrNull(
        data: (product) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Cantidad
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {},
                      ),
                      const Text('1', style: AppTextStyles.bodyLarge),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Botón agregar al carrito
                Expanded(
                  child: AppButton(
                    text: 'Agregar al carrito',
                    onPressed: product.canBePurchased
                        ? () {
                            // TODO: Agregar al carrito
                          }
                        : null,
                    icon: Icons.shopping_cart,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}
