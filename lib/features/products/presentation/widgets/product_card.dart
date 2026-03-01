import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/theme/app_colors.dart';
import '../../data/models/product_model.dart';

/// Tarjeta visual para mostrar un producto
/// Estilo glassmorphism con tema oscuro neón
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final String heroTagPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.heroTagPrefix = 'product-hero',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        final heroTag = '$heroTagPrefix-${product.slug}';
        context.push('/producto/${product.slug}', extra: heroTag);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // IMAGEN DEL PRODUCTO
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen con cache + Hero animation
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Hero(
                      tag: '$heroTagPrefix-${product.slug}',
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnailImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.dark400,
                          highlightColor: AppColors.dark300,
                          child: Container(color: AppColors.dark400),
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      ),
                    ),
                  ),

                  // Badges (Nuevo, Oferta, Agotado)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isNew) _buildBadge('NUEVO', AppColors.neonCyan),
                        if (product.hasDiscount) ...[
                          if (product.isNew) const SizedBox(height: 4),
                          _buildBadge(
                            '-${product.discountPercent}%',
                            AppColors.neonFuchsia,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Botón de favorito
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.glassMedium,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite
                              ? AppColors.neonFuchsia
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Badge de agotado
                  if (product.isSoldOut)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                        child: const Text(
                          'AGOTADO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // INFORMACIÓN DEL PRODUCTO
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría
                  if (product.category != null) ...[
                    Text(
                      product.category!.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Nombre
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Precio
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.hasDiscount &&
                          product.formattedOriginalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          product.formattedOriginalPrice!,
                          style: const TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Tallas disponibles
                  if (product.availableSizes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: product.availableSizes.take(4).map((size) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.glassLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Text(
                            size,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.dark400,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
