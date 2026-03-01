import '../../../products/data/models/product_model.dart';

/// Contrato del repositorio de favoritos.
/// Abstrae la capa de sincronización con Supabase + caché local.
abstract class FavoritesRepository {
  /// Obtiene los IDs de productos favoritos del usuario
  Future<Set<String>> getFavoriteIds();

  /// Marca/desmarca un producto como favorito (toggle)
  Future<void> toggleFavorite(String productId);

  /// Obtiene los productos completos favoritos del usuario
  Future<List<ProductModel>> getFavoriteProducts();

  /// Verifica si un producto es favorito
  Future<bool> isFavorite(String productId);
}
