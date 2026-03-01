// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$carouselSlidesHash() => r'a3257588e495941f12139e9a624a79a5f3ba7e25';

/// Provider para obtener los slides del carousel
///
/// Copied from [carouselSlides].
@ProviderFor(carouselSlides)
final carouselSlidesProvider =
    AutoDisposeFutureProvider<List<CarouselSlideModel>>.internal(
  carouselSlides,
  name: r'carouselSlidesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$carouselSlidesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CarouselSlidesRef
    = AutoDisposeFutureProviderRef<List<CarouselSlideModel>>;
String _$featuredProductsHash() => r'4662c0c5b4d5db40911d15038e4f2550e01ce411';

/// Provider para obtener productos destacados (más recientes)
///
/// Copied from [featuredProducts].
@ProviderFor(featuredProducts)
final featuredProductsProvider =
    AutoDisposeFutureProvider<List<ProductModel>>.internal(
  featuredProducts,
  name: r'featuredProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeaturedProductsRef = AutoDisposeFutureProviderRef<List<ProductModel>>;
String _$offerProductsHash() => r'e43413d129c072aa342377d40c19150e38bb93f1';

/// Provider para obtener productos en oferta
///
/// Copied from [offerProducts].
@ProviderFor(offerProducts)
final offerProductsProvider =
    AutoDisposeFutureProvider<List<ProductModel>>.internal(
  offerProducts,
  name: r'offerProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offerProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferProductsRef = AutoDisposeFutureProviderRef<List<ProductModel>>;
String _$homeCategoriesHash() => r'52d78ed6c626dbc26c413a3cb5ae1e514429f853';

/// Provider para obtener categorías activas
///
/// Copied from [homeCategories].
@ProviderFor(homeCategories)
final homeCategoriesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  homeCategories,
  name: r'homeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeCategoriesRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
