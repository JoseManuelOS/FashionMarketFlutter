import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_image_model.dart';
import 'category_model.dart';

part 'product_model.freezed.dart';

/// Modelo de Producto - Capa de Datos
/// Representa la estructura de datos de un producto desde Supabase
/// Coincide con la tabla `products` del esquema de FashionStore
@Freezed(fromJson: false, toJson: false)
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    required double price,
    @Default(0) int stock,
    String? categoryId,
    @Default(false) bool isOffer,
    double? originalPrice,
    int? discountPercent,
    @Default(<String>[]) List<String> sizes,
    Map<String, int>? stockBySize,
    /// Stock por color y talla: { "Rojo": { "M": 5, "L": 3 }, "Azul": { "M": 2 } }
    Map<String, Map<String, int>>? stockByColorSize,
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Relaciones
    CategoryModel? category,
    @Default(<ProductImageModel>[]) List<ProductImageModel> images,
    @Default(<String>[]) List<String> tags,
  }) = _ProductModel;

  const ProductModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Construir stockBySize y stockByColorSize desde product_variants
    Map<String, int>? stockBySize;
    Map<String, Map<String, int>>? stockByColorSize;
    final variants = json['variants'] as List<dynamic>?;
    if (variants != null && variants.isNotEmpty) {
      stockBySize = {};
      stockByColorSize = {};
      for (final v in variants) {
        final m = v as Map<String, dynamic>;
        final size = m['size'] as String? ?? '';
        final stock = m['stock'] as int? ?? 0;
        final color = m['color'] as String?;
        if (size.isNotEmpty) {
          // Acumulado total por talla (todas las colores)
          stockBySize[size] = (stockBySize[size] ?? 0) + stock;
          // Por color y talla
          if (color != null && color.isNotEmpty) {
            stockByColorSize[color] ??= {};
            stockByColorSize[color]![size] = (stockByColorSize[color]![size] ?? 0) + stock;
          }
        }
      }
    } else if (json['stock_by_size'] != null) {
      stockBySize = Map<String, int>.from(json['stock_by_size'] as Map);
    }

    // Calcular stock total real desde variantes si están disponibles
    final int totalStock;
    if (stockBySize != null && stockBySize.isNotEmpty) {
      totalStock = stockBySize.values.fold(0, (sum, s) => sum + s);
    } else {
      totalStock = json['stock'] as int? ?? 0;
    }

    // Construir lista de tallas desde variantes si no viene del campo sizes
    final sizesFromJson = (json['sizes'] as List<dynamic>?)?.cast<String>() ?? [];
    final List<String> sizes;
    if (sizesFromJson.isNotEmpty) {
      sizes = sizesFromJson;
    } else if (stockBySize != null && stockBySize.isNotEmpty) {
      sizes = stockBySize.keys.toList();
    } else {
      sizes = [];
    }

    return ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String? ?? json['name'].toString().toLowerCase().replaceAll(' ', '-'),
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        stock: totalStock,
        categoryId: json['category_id'] as String?,
        isOffer: json['is_offer'] as bool? ?? false,
        originalPrice: json['original_price'] != null 
            ? (json['original_price'] as num).toDouble() 
            : null,
        discountPercent: json['discount_percent'] as int?,
        sizes: sizes,
        stockBySize: stockBySize,
        stockByColorSize: stockByColorSize,
        active: json['active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        images: (json['images'] as List<dynamic>?)
                ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'is_offer': isOffer,
        'original_price': originalPrice,
        'discount_percent': discountPercent,
        'sizes': sizes,
        'stock_by_size': stockBySize,
        'active': active,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS DE COLORES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Colores únicos extraídos de las imágenes del producto [{name, hex}]
  List<({String name, String hex})> get colors {
    final seen = <String>{};
    final result = <({String name, String hex})>[];
    for (final img in images) {
      if (img.color != null && img.color!.isNotEmpty && img.colorHex != null && img.colorHex!.isNotEmpty) {
        if (!seen.contains(img.color)) {
          seen.add(img.color!);
          result.add((name: img.color!, hex: img.colorHex!));
        }
      }
    }
    return result;
  }

  /// Imágenes filtradas por color
  List<ProductImageModel> imagesForColor(String? colorName) {
    if (colorName == null || colorName.isEmpty) return images;
    final filtered = images.where((img) => img.color == colorName).toList();
    return filtered.isNotEmpty ? filtered : images;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS DE STOCK
  // ═══════════════════════════════════════════════════════════════════════════

  /// Verifica si el producto tiene stock (general)
  bool get hasStock => stock > 0;

  /// Verifica si el producto está disponible para compra
  bool get canBePurchased => active && hasStock;

  /// Stock disponible para una talla específica
  int stockForSize(String size) {
    if (stockBySize != null && stockBySize!.containsKey(size)) {
      return stockBySize![size] ?? 0;
    }
    // Si no hay stock por talla, devolver 0 (no usar stock total,
    // que es la suma de todas las tallas y podría ser engañoso)
    return 0;
  }

  /// Stock por talla filtrado por color.
  /// Si no hay datos por color, devuelve stockBySize general.
  Map<String, int> stockForColor(String? colorName) {
    if (colorName != null &&
        colorName.isNotEmpty &&
        stockByColorSize != null &&
        stockByColorSize!.containsKey(colorName)) {
      return stockByColorSize![colorName]!;
    }
    return stockBySize ?? {};
  }

  /// Verificar si una talla tiene stock
  bool hasSizeInStock(String size) => stockForSize(size) > 0;

  /// Tallas disponibles (con stock)
  List<String> get availableSizes {
    if (stockBySize != null) {
      return sizes.where((size) => (stockBySize![size] ?? 0) > 0).toList();
    }
    return hasStock ? sizes : [];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS DE PRECIO
  // ═══════════════════════════════════════════════════════════════════════════

  /// ¿Tiene descuento activo?
  bool get hasDiscount =>
      isOffer && discountPercent != null && discountPercent! > 0;

  /// Precio formateado
  String get formattedPrice => '€${price.toStringAsFixed(2)}';

  /// Precio original formateado (si tiene descuento)
  String? get formattedOriginalPrice =>
      hasDiscount && originalPrice != null
          ? '€${originalPrice!.toStringAsFixed(2)}'
          : null;

  /// Cantidad de ahorro
  double get savings =>
      hasDiscount && originalPrice != null ? originalPrice! - price : 0;

  /// Ahorro formateado
  String get formattedSavings => '€${savings.toStringAsFixed(2)}';

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS DE IMÁGENES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Imagen principal (primera imagen o placeholder)
  String get mainImage {
    if (images.isNotEmpty) {
      return images.first.imageUrl;
    }
    return 'https://via.placeholder.com/400x500?text=Sin+imagen';
  }

  /// Alias para mainImage (usado en ProductDetailScreen)
  String get mainImageUrl => mainImage;

  /// Thumbnail de la imagen principal
  String get thumbnailImage {
    if (images.isNotEmpty) {
      return images.first.thumbnailUrl;
    }
    return 'https://via.placeholder.com/300x400?text=Sin+imagen';
  }

  /// Porcentaje de descuento calculado
  double? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return discountPercent?.toDouble();
  }

  /// Todas las URLs de imágenes
  List<String> get imageUrls => images.map((img) => img.imageUrl).toList();

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGES
  // ═══════════════════════════════════════════════════════════════════════════

  /// ¿Es nuevo? (creado en los últimos 7 días)
  bool get isNew {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays <= 7;
  }

  /// ¿Está agotado?
  bool get isSoldOut => !hasStock;
}

/// Modelo para la lista de productos con paginación
@Freezed(fromJson: false, toJson: false)
class ProductListResponse with _$ProductListResponse {
  const factory ProductListResponse({
    required List<ProductModel> products,
    @Default(0) int total,
    @Default(1) int page,
    @Default(20) int pageSize,
  }) = _ProductListResponse;

  const ProductListResponse._();

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        products: (json['products'] as List<dynamic>?)
                ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
      );

  /// Verifica si hay más páginas
  bool get hasMore => (page * pageSize) < total;

  /// Número total de páginas
  int get totalPages => (total / pageSize).ceil();
}

/// Filtros para búsqueda de productos
@Freezed(fromJson: false, toJson: false)
class ProductFilters with _$ProductFilters {
  const factory ProductFilters({
    String? categorySlug,
    String? search,
    List<String>? sizes,
    double? minPrice,
    double? maxPrice,
    bool? isOffer,
    List<String>? tags,
    @Default(ProductSortBy.newest) ProductSortBy sortBy,
  }) = _ProductFilters;

  const ProductFilters._();

  factory ProductFilters.fromJson(Map<String, dynamic> json) =>
      ProductFilters(
        categorySlug: json['categorySlug'] as String?,
        search: json['search'] as String?,
        sizes: (json['sizes'] as List<dynamic>?)?.cast<String>(),
        minPrice: (json['minPrice'] as num?)?.toDouble(),
        maxPrice: (json['maxPrice'] as num?)?.toDouble(),
        isOffer: json['isOffer'] as bool?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
        sortBy: ProductSortBy.values.firstWhere(
          (e) => e.name == json['sortBy'],
          orElse: () => ProductSortBy.newest,
        ),
      );

  /// ¿Tiene filtros activos?
  bool get hasActiveFilters =>
      categorySlug != null ||
      search != null ||
      (sizes != null && sizes!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      isOffer == true ||
      (tags != null && tags!.isNotEmpty);

  /// Limpiar todos los filtros
  ProductFilters clear() => const ProductFilters();
}

/// Opciones de ordenamiento
enum ProductSortBy {
  newest,
  priceAsc,
  priceDesc,
  nameAsc,
  nameDesc;

  String get displayName {
    switch (this) {
      case ProductSortBy.newest:
        return 'Más recientes';
      case ProductSortBy.priceAsc:
        return 'Precio: menor a mayor';
      case ProductSortBy.priceDesc:
        return 'Precio: mayor a menor';
      case ProductSortBy.nameAsc:
        return 'Nombre: A-Z';
      case ProductSortBy.nameDesc:
        return 'Nombre: Z-A';
    }
  }
}

