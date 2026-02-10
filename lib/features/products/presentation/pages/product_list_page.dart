import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/product_providers.dart';
import '../providers/filter_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';

/// Página de catálogo de productos
/// Muestra productos con filtros por categoría, búsqueda y ofertas
class ProductListPage extends ConsumerWidget {
  final String? categorySlug;
  final String? searchQuery;
  final bool isOffers;

  const ProductListPage({
    super.key,
    this.categorySlug,
    this.searchQuery,
    this.isOffers = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(sortedProductListProvider);
    final filters = ref.watch(productFiltersProvider);
    final hasActiveFilters = filters.hasActiveFilters;

    // Determinar título según el contexto
    String title = 'Todos los productos';
    if (isOffers) {
      title = 'Ofertas';
    } else if (categorySlug != null) {
      title = _getCategoryTitle(categorySlug!);
    } else if (searchQuery != null) {
      title = 'Resultados de búsqueda';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark500.withOpacity(0.95),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: hasActiveFilters ? AppColors.neonCyan : AppColors.textPrimary,
                ),
                onPressed: () => _showFiltersBottomSheet(context),
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: AppColors.dark400,
        onRefresh: () => ref.read(productListProvider.notifier).refresh(),
        child: productsAsync.when(
          loading: () => _buildLoadingGrid(),
          error: (error, stack) => AppErrorWidget(
            title: 'Error al cargar productos',
            message: error.toString(),
            onRetry: () => ref.read(productListProvider.notifier).refresh(),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.textSubtle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay productos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOffers
                          ? 'No hay ofertas disponibles en este momento'
                          : 'No hay productos en esta categoría',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // Info de resultados
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${products.length} productos',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        // Sort dropdown
                        DropdownButton<String>(
                          value: filters.sortBy,
                          dropdownColor: AppColors.dark400,
                          style: const TextStyle(color: AppColors.textSecondary),
                          underline: const SizedBox.shrink(),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textMuted),
                          items: const [
                            DropdownMenuItem(
                                value: 'newest', child: Text('Más recientes')),
                            DropdownMenuItem(
                                value: 'price_asc', child: Text('Precio: menor')),
                            DropdownMenuItem(
                                value: 'price_desc', child: Text('Precio: mayor')),
                            DropdownMenuItem(
                                value: 'name_asc', child: Text('Nombre: A-Z')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(productFiltersProvider.notifier).setSortBy(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid de productos
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        final isFav = ref.watch(isFavoriteProvider(product.id));
                        return ProductCard(
                          product: product,
                          isFavorite: isFav,
                          onFavorite: () {
                            ref.read(favoriteIdsProvider.notifier).toggle(product.id);
                          },
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),

                // Espacio al final
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getCategoryTitle(String slug) {
    switch (slug) {
      case 'camisas':
        return 'Camisas';
      case 'pantalones':
        return 'Pantalones';
      case 'trajes':
        return 'Trajes';
      case 'accesorios':
        return 'Accesorios';
      default:
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.dark400,
        highlightColor: AppColors.dark300,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.dark400,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
