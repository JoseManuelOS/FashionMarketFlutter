import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/models/product_model.dart';

/// Contrato/Interface del repositorio de productos
/// Define QUÉ operaciones se pueden hacer, no CÓMO se hacen
/// Esto permite cambiar la implementación (ej. de Supabase a Firebase)
/// sin afectar el resto de la aplicación (Inversión de Dependencias)
///
/// Usa Either<Failure, T> de fpdart para manejo funcional de errores:
///   Left(Failure)  → error
///   Right(T)       → éxito
abstract class ProductRepository {
  /// Obtiene la lista de productos con paginación opcional
  Future<Either<Failure, List<ProductModel>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  });

  /// Obtiene un producto específico por su ID o slug
  Future<Either<Failure, ProductModel>> getProductById(String id);

  /// Busca productos por texto
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query);

  /// Crea un nuevo producto
  Future<Either<Failure, ProductModel>> createProduct(ProductModel product);

  /// Actualiza un producto existente
  Future<Either<Failure, ProductModel>> updateProduct(ProductModel product);

  /// Elimina un producto por su ID
  Future<Either<Failure, Unit>> deleteProduct(String id);
}
