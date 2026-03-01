// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productListHash() => r'aadc18bd23eb76936e68adb66312a651ac50332d';

/// Provider para la lista de productos (con Riverpod Generator)
///
/// Copied from [ProductList].
@ProviderFor(ProductList)
final productListProvider =
    AutoDisposeAsyncNotifierProvider<ProductList, List<ProductModel>>.internal(
  ProductList.new,
  name: r'productListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$productListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProductList = AutoDisposeAsyncNotifier<List<ProductModel>>;
String _$productDetailHash() => r'36a989a7ec90502ba2544d7c67d918e2288691f1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProductDetail
    extends BuildlessAutoDisposeAsyncNotifier<ProductModel> {
  late final String productId;

  FutureOr<ProductModel> build(
    String productId,
  );
}

/// Provider para los detalles de un producto específico
///
/// Copied from [ProductDetail].
@ProviderFor(ProductDetail)
const productDetailProvider = ProductDetailFamily();

/// Provider para los detalles de un producto específico
///
/// Copied from [ProductDetail].
class ProductDetailFamily extends Family<AsyncValue<ProductModel>> {
  /// Provider para los detalles de un producto específico
  ///
  /// Copied from [ProductDetail].
  const ProductDetailFamily();

  /// Provider para los detalles de un producto específico
  ///
  /// Copied from [ProductDetail].
  ProductDetailProvider call(
    String productId,
  ) {
    return ProductDetailProvider(
      productId,
    );
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(
      provider.productId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailProvider';
}

/// Provider para los detalles de un producto específico
///
/// Copied from [ProductDetail].
class ProductDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProductDetail, ProductModel> {
  /// Provider para los detalles de un producto específico
  ///
  /// Copied from [ProductDetail].
  ProductDetailProvider(
    String productId,
  ) : this._internal(
          () => ProductDetail()..productId = productId,
          from: productDetailProvider,
          name: r'productDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productDetailHash,
          dependencies: ProductDetailFamily._dependencies,
          allTransitiveDependencies:
              ProductDetailFamily._allTransitiveDependencies,
          productId: productId,
        );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  FutureOr<ProductModel> runNotifierBuild(
    covariant ProductDetail notifier,
  ) {
    return notifier.build(
      productId,
    );
  }

  @override
  Override overrideWith(ProductDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductDetail, ProductModel>
      createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailRef on AutoDisposeAsyncNotifierProviderRef<ProductModel> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductDetail, ProductModel>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailProvider).productId;
}

String _$productSearchHash() => r'3b8cda9ff163f4372df6cacba9c99a411c341f0a';

abstract class _$ProductSearch
    extends BuildlessAutoDisposeAsyncNotifier<List<ProductModel>> {
  late final String query;

  FutureOr<List<ProductModel>> build(
    String query,
  );
}

/// Provider para la búsqueda de productos
///
/// Copied from [ProductSearch].
@ProviderFor(ProductSearch)
const productSearchProvider = ProductSearchFamily();

/// Provider para la búsqueda de productos
///
/// Copied from [ProductSearch].
class ProductSearchFamily extends Family<AsyncValue<List<ProductModel>>> {
  /// Provider para la búsqueda de productos
  ///
  /// Copied from [ProductSearch].
  const ProductSearchFamily();

  /// Provider para la búsqueda de productos
  ///
  /// Copied from [ProductSearch].
  ProductSearchProvider call(
    String query,
  ) {
    return ProductSearchProvider(
      query,
    );
  }

  @override
  ProductSearchProvider getProviderOverride(
    covariant ProductSearchProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productSearchProvider';
}

/// Provider para la búsqueda de productos
///
/// Copied from [ProductSearch].
class ProductSearchProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProductSearch, List<ProductModel>> {
  /// Provider para la búsqueda de productos
  ///
  /// Copied from [ProductSearch].
  ProductSearchProvider(
    String query,
  ) : this._internal(
          () => ProductSearch()..query = query,
          from: productSearchProvider,
          name: r'productSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$productSearchHash,
          dependencies: ProductSearchFamily._dependencies,
          allTransitiveDependencies:
              ProductSearchFamily._allTransitiveDependencies,
          query: query,
        );

  ProductSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<ProductModel>> runNotifierBuild(
    covariant ProductSearch notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(ProductSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductSearchProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProductSearch, List<ProductModel>>
      createElement() {
    return _ProductSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductSearchRef
    on AutoDisposeAsyncNotifierProviderRef<List<ProductModel>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _ProductSearchProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProductSearch,
        List<ProductModel>> with ProductSearchRef {
  _ProductSearchProviderElement(super.provider);

  @override
  String get query => (origin as ProductSearchProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
