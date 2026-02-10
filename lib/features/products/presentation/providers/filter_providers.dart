import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de filtros de productos
class ProductFilters {
  final String search;
  final String? categorySlug;
  final List<String> sizes;
  final double priceMin;
  final double priceMax;
  final bool offersOnly;
  final String? color;
  final String sortBy;

  const ProductFilters({
    this.search = '',
    this.categorySlug,
    this.sizes = const [],
    this.priceMin = 0,
    this.priceMax = 500,
    this.offersOnly = false,
    this.color,
    this.sortBy = 'newest',
  });

  ProductFilters copyWith({
    String? search,
    String? categorySlug,
    List<String>? sizes,
    double? priceMin,
    double? priceMax,
    bool? offersOnly,
    String? color,
    String? sortBy,
    bool clearCategory = false,
    bool clearColor = false,
  }) {
    return ProductFilters(
      search: search ?? this.search,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      sizes: sizes ?? this.sizes,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      offersOnly: offersOnly ?? this.offersOnly,
      color: clearColor ? null : (color ?? this.color),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      categorySlug != null ||
      sizes.isNotEmpty ||
      priceMin > 0 ||
      priceMax < 500 ||
      offersOnly ||
      color != null;

  int get activeFiltersCount {
    int count = 0;
    if (search.isNotEmpty) count++;
    if (categorySlug != null) count++;
    if (sizes.isNotEmpty) count++;
    if (priceMin > 0 || priceMax < 500) count++;
    if (offersOnly) count++;
    if (color != null) count++;
    return count;
  }
}

/// Notifier para los filtros de productos
class ProductFiltersNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  void setCategory(String? slug) {
    if (slug == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categorySlug: slug);
    }
  }

  void toggleSize(String size) {
    final newSizes = List<String>.from(state.sizes);
    if (newSizes.contains(size)) {
      newSizes.remove(size);
    } else {
      newSizes.add(size);
    }
    state = state.copyWith(sizes: newSizes);
  }

  void setPriceRange(double min, double max) {
    state = state.copyWith(priceMin: min, priceMax: max);
  }

  void toggleOffers() {
    state = state.copyWith(offersOnly: !state.offersOnly);
  }

  void setColor(String? color) {
    if (color == null) {
      state = state.copyWith(clearColor: true);
    } else {
      state = state.copyWith(color: color);
    }
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearAll() {
    state = const ProductFilters();
  }
}

/// Provider para los filtros
final productFiltersProvider =
    NotifierProvider<ProductFiltersNotifier, ProductFilters>(
  ProductFiltersNotifier.new,
);

/// Provider para las categorías
final categoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('categories')
      .select()
      .order('name', ascending: true);

  return List<Map<String, dynamic>>.from(response);
});

/// Provider para las tallas disponibles
final availableSizesProvider = FutureProvider<List<String>>((ref) async {
  // Tallas estándar
  return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
});

/// Provider para colores disponibles
final availableColorsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'Blanco', 'value': 'white'},
    {'name': 'Negro', 'value': 'black'},
    {'name': 'Azul', 'value': 'blue'},
    {'name': 'Gris', 'value': 'gray'},
    {'name': 'Rojo', 'value': 'red'},
    {'name': 'Verde', 'value': 'green'},
    {'name': 'Marrón', 'value': 'brown'},
    {'name': 'Beige', 'value': 'beige'},
  ];
});
