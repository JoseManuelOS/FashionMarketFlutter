import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variant_model.freezed.dart';

/// Modelo de Variante de Producto
/// DB columns: id, product_id, size, stock, sku, price, is_offer, created_at
@Freezed(fromJson: false, toJson: false)
class ProductVariantModel with _$ProductVariantModel {
  const factory ProductVariantModel({
    required String id,
    required String productId,
    required String size,
    @Default(0) int stock,
    String? sku,
    double? price,
    @Default(false) bool isOffer,
    DateTime? createdAt,
  }) = _ProductVariantModel;

  const ProductVariantModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      ProductVariantModel(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        size: json['size'] as String? ?? '',
        stock: json['stock'] as int? ?? 0,
        sku: json['sku'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        isOffer: json['is_offer'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Serializar para escritura a Supabase (solo campos editables)
  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'size': size,
        'stock': stock,
        'sku': sku,
        'price': price,
        'is_offer': isOffer,
      };

  /// Serializar con ID (para upsert)
  Map<String, dynamic> toFullJson() => {
        'id': id,
        ...toJson(),
      };

  /// ¿Stock agotado?
  bool get isOutOfStock => stock == 0;

  /// ¿Stock bajo? (≤3 unidades)
  bool get isLowStock => stock > 0 && stock <= 3;
}
