import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/product_model.dart';
import 'product_providers.dart';

part 'product_form_provider.g.dart';

/// Estado del formulario de producto
enum ProductFormStatus { initial, loading, success, error }

/// Estado para el formulario de crear/editar producto
class ProductFormState {
  final ProductFormStatus status;
  final String? errorMessage;
  final ProductModel? product;

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.errorMessage,
    this.product,
  });

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? errorMessage,
    ProductModel? product,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      product: product ?? this.product,
    );
  }

  bool get isLoading => status == ProductFormStatus.loading;
  bool get isSuccess => status == ProductFormStatus.success;
  bool get hasError => status == ProductFormStatus.error;
}

/// Provider para manejar el formulario de productos (crear/editar)
@riverpod
class ProductForm extends _$ProductForm {
  @override
  ProductFormState build() {
    return const ProductFormState();
  }

  /// Crea un nuevo producto
  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    String? categoryId,
    int stock = 0,
  }) async {
    state = state.copyWith(status: ProductFormStatus.loading);

    try {
      final repository = ref.read(productRepositoryProvider);

      final newProduct = ProductModel(
        id: '', // Supabase generará el ID
        name: name,
        slug: name.toLowerCase().replaceAll(' ', '-'),
        description: description,
        price: price,
        categoryId: categoryId,
        stock: stock,
      );

      final result = await repository.createProduct(newProduct);

      result.fold(
        (failure) => state = state.copyWith(
          status: ProductFormStatus.error,
          errorMessage: failure.message,
        ),
        (createdProduct) {
          state = state.copyWith(
            status: ProductFormStatus.success,
            product: createdProduct,
          );
          ref.invalidate(productListProvider);
        },
      );
      return;

    } catch (e) {
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Actualiza un producto existente
  Future<void> updateProduct(ProductModel product) async {
    state = state.copyWith(status: ProductFormStatus.loading);

    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.updateProduct(product);

      result.fold(
        (failure) => state = state.copyWith(
          status: ProductFormStatus.error,
          errorMessage: failure.message,
        ),
        (updatedProduct) {
          state = state.copyWith(
            status: ProductFormStatus.success,
            product: updatedProduct,
          );
          ref.invalidate(productListProvider);
          ref.invalidate(productDetailProvider(product.id));
        },
      );
      return;
    } catch (e) {
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Desactiva un producto (soft delete)
  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(status: ProductFormStatus.loading);

    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.deleteProduct(productId);

      result.fold(
        (failure) => state = state.copyWith(
          status: ProductFormStatus.error,
          errorMessage: failure.message,
        ),
        (_) {
          state = state.copyWith(status: ProductFormStatus.success);
          ref.invalidate(productListProvider);
        },
      );
      return;
    } catch (e) {
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resetea el formulario
  void reset() {
    state = const ProductFormState();
  }
}
