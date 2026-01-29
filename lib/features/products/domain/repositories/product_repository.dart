import '../../data/models/product_model.dart';

/// Contrato/Interface del repositorio de productos
/// Define QUÉ operaciones se pueden hacer, no CÓMO se hacen
/// Esto permite cambiar la implementación (ej. de Supabase a Firebase)
/// sin afectar el resto de la aplicación (Inversión de Dependencias)
abstract class ProductRepository {
  /// Obtiene la lista de productos con paginación opcional
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  });

  /// Obtiene un producto específico por su ID
  Future<ProductModel> getProductById(String id);

  /// Busca productos por texto
  Future<List<ProductModel>> searchProducts(String query);

  /// Crea un nuevo producto
  Future<ProductModel> createProduct(ProductModel product);

  /// Actualiza un producto existente
  Future<ProductModel> updateProduct(ProductModel product);

  /// Elimina un producto por su ID
  Future<void> deleteProduct(String id);
}
