import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/products/data/models/product_model.dart';

/// Repositorio de favoritos — Supabase `customer_favorites`
class FavoritesRepository {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// IDs de productos favoritos del usuario
  Future<Set<String>> getFavoriteIds() async {
    if (_userId == null) return {};
    final data = await _supabase
        .from('customer_favorites')
        .select('product_id')
        .eq('customer_id', _userId!);
    return data.map<String>((row) => row['product_id'] as String).toSet();
  }

  /// Productos favoritos completos
  Future<List<ProductModel>> getFavoriteProducts() async {
    if (_userId == null) return [];
    final data = await _supabase
        .from('customer_favorites')
        .select('product_id, products(*, categories(*), images:product_images(*))')
        .eq('customer_id', _userId!)
        .order('created_at', ascending: false);

    final products = <ProductModel>[];
    for (final row in data) {
      final productData = row['products'];
      if (productData != null) {
        products.add(ProductModel.fromJson(productData as Map<String, dynamic>));
      }
    }
    return products;
  }

  /// Añadir favorito
  Future<void> addFavorite(String productId) async {
    if (_userId == null) return;
    await _supabase.from('customer_favorites').upsert({
      'customer_id': _userId!,
      'product_id': productId,
    });
  }

  /// Quitar favorito
  Future<void> removeFavorite(String productId) async {
    if (_userId == null) return;
    await _supabase
        .from('customer_favorites')
        .delete()
        .eq('customer_id', _userId!)
        .eq('product_id', productId);
  }

  /// Toggle: añade o quita según estado actual
  Future<bool> toggleFavorite(String productId, {required bool currentlyFavorite}) async {
    if (currentlyFavorite) {
      await removeFavorite(productId);
      return false;
    } else {
      await addFavorite(productId);
      return true;
    }
  }
}
