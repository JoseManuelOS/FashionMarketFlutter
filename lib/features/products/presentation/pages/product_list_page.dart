import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

/// Página principal que muestra la lista de productos
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navegar a búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // TODO: Navegar al carrito
            },
          ),
        ],
      ),
      body: RefreshIndicator(
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
              return const AppEmptyWidget(
                icon: Icons.inventory_2_outlined,
                title: 'Sin productos',
                message: 'No hay productos disponibles en este momento.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push(AppRoutes.productDetailById(product.id));
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a crear producto (si es admin)
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}
