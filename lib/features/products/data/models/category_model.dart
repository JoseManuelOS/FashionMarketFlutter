import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';

/// Modelo de Categoría - Capa de Datos
/// Representa una categoría de productos (camisas, pantalones, trajes, etc.)
@Freezed(fromJson: false, toJson: false)
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    String? parentId,
    @Default(0) int sortOrder,
    @Default(true) bool active,
    DateTime? createdAt,
  }) = _CategoryModel;

  const CategoryModel._();

  /// Factory con manejo de snake_case desde Supabase
  /// DB columns: id, name, slug, description, image_url, display_order, created_at
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String? ?? json['name'].toString().toLowerCase(),
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        parentId: json['parent_id'] as String?,
        sortOrder: json['display_order'] as int? ?? json['sort_order'] as int? ?? 0,
        active: json['active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Convertir a JSON para Supabase (usa display_order, no sort_order)
  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'description': description,
        'image_url': imageUrl,
        'display_order': sortOrder,
      };

  /// JSON completo incluyendo campos de solo lectura
  Map<String, dynamic> toFullJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'image_url': imageUrl,
        'display_order': sortOrder,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Categorías predefinidas del sistema
  static const String camisas = 'camisas';
  static const String pantalones = 'pantalones';
  static const String trajes = 'trajes';
  static const String accesorios = 'accesorios';
}
