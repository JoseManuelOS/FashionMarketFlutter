import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image_model.freezed.dart';

/// Modelo de Imagen de Producto
/// Representa una imagen asociada a un producto (puede haber múltiples por producto)
@Freezed(fromJson: false, toJson: false)
class ProductImageModel with _$ProductImageModel {
  const factory ProductImageModel({
    required String id,
    required String productId,
    required String imageUrl,
    @Default(0) int sortOrder,
    String? color,
    String? colorHex,
    String? altText,
    DateTime? createdAt,
  }) = _ProductImageModel;

  const ProductImageModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory ProductImageModel.fromJson(Map<String, dynamic> json) => ProductImageModel(
        id: json['id'] as String,
        productId: json['product_id'] as String,
        imageUrl: json['image_url'] as String,
        sortOrder: json['order'] as int? ?? json['sort_order'] as int? ?? 0,
        color: json['color'] as String?,
        colorHex: json['color_hex'] as String?,
        altText: json['alt_text'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'image_url': imageUrl,
        'sort_order': sortOrder,
        'color': color,
        'color_hex': colorHex,
        'alt_text': altText,
        'created_at': createdAt?.toIso8601String(),
      };

  /// URL optimizada para thumbnail (Cloudinary)
  String get thumbnailUrl {
    if (imageUrl.contains('cloudinary')) {
      return imageUrl.replaceFirst('/upload/', '/upload/w_300,h_400,c_fill/');
    }
    return imageUrl;
  }

  /// URL optimizada para detalle (Cloudinary)
  String get detailUrl {
    if (imageUrl.contains('cloudinary')) {
      return imageUrl.replaceFirst('/upload/', '/upload/w_800,h_1000,c_fill/');
    }
    return imageUrl;
  }
}
