import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/services/supabase_service.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

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
    return repository.getProducts(page: page, categoryId: categoryId);
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
    return repository.getProductById(productId);
  }

  /// Refresca los detalles del producto
  Future<void> refresh() async {
    final productId = this.productId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      return repository.getProductById(productId);
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
    return repository.searchProducts(query);
  }
}

/// Provider para el término de búsqueda actual
final searchQueryProvider = StateProvider<String>((ref) => '');
