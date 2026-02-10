// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartTotalHash() => r'912856a720c20ed1f032465bd02933d5dcc96f22';

/// Provider para el total del carrito
///
/// Copied from [cartTotal].
@ProviderFor(cartTotal)
final cartTotalProvider = AutoDisposeProvider<double>.internal(
  cartTotal,
  name: r'cartTotalProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartTotalRef = AutoDisposeProviderRef<double>;
String _$cartItemCountHash() => r'00d2782f20e5a278e7205c6fa0ae5b211f1aaa04';

/// Provider para el número de items en el carrito
///
/// Copied from [cartItemCount].
@ProviderFor(cartItemCount)
final cartItemCountProvider = AutoDisposeProvider<int>.internal(
  cartItemCount,
  name: r'cartItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemCountRef = AutoDisposeProviderRef<int>;
String _$cartSavingsHash() => r'865abcc1f6697fe60a89240873a9f914bca36a3f';

/// Provider para el ahorro total (descuentos)
///
/// Copied from [cartSavings].
@ProviderFor(cartSavings)
final cartSavingsProvider = AutoDisposeProvider<double>.internal(
  cartSavings,
  name: r'cartSavingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartSavingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartSavingsRef = AutoDisposeProviderRef<double>;
String _$isCartEmptyHash() => r'67c51c5a87ee6cbc3fcea55a9800d6fbaf68acc6';

/// Provider para verificar si el carrito está vacío
///
/// Copied from [isCartEmpty].
@ProviderFor(isCartEmpty)
final isCartEmptyProvider = AutoDisposeProvider<bool>.internal(
  isCartEmpty,
  name: r'isCartEmptyProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isCartEmptyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsCartEmptyRef = AutoDisposeProviderRef<bool>;
String _$cartNotifierHash() => r'fc61c2f654d5b05098dbbbd72f5dd505be7116a6';

/// Notifier para gestionar el estado del carrito
///
/// Copied from [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, List<CartItemModel>>.internal(
  CartNotifier.new,
  name: r'cartNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cartNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartNotifier = AutoDisposeNotifier<List<CartItemModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
