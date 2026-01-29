import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Modelo de Producto - Capa de Datos
/// Representa la estructura de datos de un producto desde Supabase/API
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'stock_quantity') @Default(0) int stockQuantity,
    @Default(true) bool available,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ProductModel;

  /// Constructor privado para métodos adicionales
  const ProductModel._();

  /// Factory para crear desde JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Verifica si el producto tiene stock
  bool get hasStock => stockQuantity > 0;

  /// Verifica si el producto está disponible para compra
  bool get canBePurchased => available && hasStock;

  /// Precio formateado
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

/// Modelo para la lista de productos con paginación
@freezed
class ProductListResponse with _$ProductListResponse {
  const factory ProductListResponse({
    required List<ProductModel> products,
    @Default(0) int total,
    @Default(1) int page,
    @Default(20) int pageSize,
  }) = _ProductListResponse;

  const ProductListResponse._();

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);

  /// Verifica si hay más páginas
  bool get hasMore => (page * pageSize) < total;

  /// Número total de páginas
  int get totalPages => (total / pageSize).ceil();
}
