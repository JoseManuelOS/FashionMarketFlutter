import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementación concreta del repositorio de productos
/// Une el datasource con la interface del dominio
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  }) async {
    return _remoteDataSource.getProducts(
      page: page,
      pageSize: pageSize,
      categoryId: categoryId,
    );
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    return _remoteDataSource.getProductById(id);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    return _remoteDataSource.searchProducts(query);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    return _remoteDataSource.createProduct(product);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    return _remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    return _remoteDataSource.deleteProduct(id);
  }
}
