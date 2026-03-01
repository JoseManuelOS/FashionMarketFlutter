import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/app_exception.dart';
import '../../../../shared/exceptions/failure.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementación concreta del repositorio de productos.
/// Envuelve las llamadas al datasource con Either<Failure, T>
/// para manejo funcional de errores.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
  }) async {
    try {
      final products = await _remoteDataSource.getProducts(
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> getProductById(String id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);
      return Right(product);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(
      String query) async {
    try {
      final products = await _remoteDataSource.searchProducts(query);
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> createProduct(
      ProductModel product) async {
    try {
      final created = await _remoteDataSource.createProduct(product);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> updateProduct(
      ProductModel product) async {
    try {
      final updated = await _remoteDataSource.updateProduct(product);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) async {
    try {
      await _remoteDataSource.deleteProduct(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
