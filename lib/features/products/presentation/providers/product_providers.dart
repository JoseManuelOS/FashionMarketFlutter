import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/services/supabase_service.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../providers/filter_providers.dart';

part 'product_providers.g.dart';

/// Provider para el DataSource remoto
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ProductRemoteDataSourceImpl(supabaseClient);
});

/// Provider para el Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

/// Provider para la lista de productos (con Riverpod Generator)
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<ProductModel>> build() async {
    return _fetchProducts();
  }

  Future<List<ProductModel>> _fetchProducts({
    int page = 1,
    String? categoryId,
  }) async {
    final repository = ref.read(productRepositoryProvider);
    final result =
        await repository.getProducts(page: page, categoryId: categoryId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }

  /// Refresca la lista de productos
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts());
  }

  /// Carga más productos (paginación)
  Future<void> loadMore(int page) async {
    final currentProducts = state.valueOrNull ?? [];
    final newProducts = await _fetchProducts(page: page);
    state = AsyncValue.data([...currentProducts, ...newProducts]);
  }

  /// Filtra por categoría
  Future<void> filterByCategory(String? categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts(categoryId: categoryId));
  }
}

/// Provider para los detalles de un producto específico
@riverpod
class ProductDetail extends _$ProductDetail {
  @override
  Future<ProductModel> build(String productId) async {
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.getProductById(productId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (product) => product,
    );
  }

  /// Refresca los detalles del producto
  Future<void> refresh() async {
    final productId = this.productId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.getProductById(productId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (product) => product,
      );
    });
  }
}

/// Provider para la búsqueda de productos
@riverpod
class ProductSearch extends _$ProductSearch {
  @override
  Future<List<ProductModel>> build(String query) async {
    if (query.isEmpty) return [];
    
    // Debounce: espera 300ms antes de buscar
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Verifica si el provider fue descartado durante el delay
    if (!ref.exists(productSearchProvider(query))) return [];
    
    final repository = ref.read(productRepositoryProvider);
    final result = await repository.searchProducts(query);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (products) => products,
    );
  }
}

/// Provider para el término de búsqueda actual
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider que aplica filtros y ordenación client-side (igual que FashionStore)
final sortedProductListProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final filters = ref.watch(productFiltersProvider);

  return productsAsync.whenData((products) {
    var filtered = List<ProductModel>.from(products);

    // Búsqueda por texto (name, description, category.name)
    if (filters.search.isNotEmpty) {
      final query = filters.search.toLowerCase();
      filtered = filtered.where((p) =>
          p.name.toLowerCase().contains(query) ||
          (p.description?.toLowerCase().contains(query) ?? false) ||
          (p.category?.name.toLowerCase().contains(query) ?? false)).toList();
    }

    // Categoría (por slug)
    if (filters.categorySlug != null) {
      filtered = filtered
          .where((p) => p.category?.slug == filters.categorySlug)
          .toList();
    }

    // Rango de precio
    if (filters.priceMin > 0) {
      filtered = filtered.where((p) => p.price >= filters.priceMin).toList();
    }
    if (filters.priceMax < 500) {
      filtered = filtered.where((p) => p.price <= filters.priceMax).toList();
    }

    // Tallas (match si el producto tiene al menos una de las seleccionadas)
    if (filters.sizes.isNotEmpty) {
      filtered = filtered.where((p) =>
          filters.sizes.any((size) => p.sizes.contains(size))).toList();
    }

    // Solo ofertas
    if (filters.offersOnly) {
      filtered = filtered.where((p) => p.isOffer).toList();
    }

    // Color (si está implementado)
    // if (filters.color != null) { ... }

    // Ordenación
    switch (filters.sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case 'name_asc':
        filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case 'newest':
      default:
        filtered.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    }
    return filtered;
  });
});

/// Provider para productos relacionados (misma categoría, excluyendo el actual)
final relatedProductsProvider =
    FutureProvider.family<List<ProductModel>, ({String productId, String? categoryId})>(
  (ref, params) async {
    if (params.categoryId == null) return [];

    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('products')
        .select('''
          *,
          category:categories(*),
          images:product_images(*),
          variants:product_variants(id, size, stock, sku, color)
        ''')
        .eq('active', true)
        .eq('category_id', params.categoryId!)
        .neq('id', params.productId)
        .order('created_at', ascending: false)
        .limit(6);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  },
);
