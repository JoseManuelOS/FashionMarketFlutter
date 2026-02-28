import 'package:freezed_annotation/freezed_annotation.dart';

part 'carousel_slide_model.freezed.dart';

/// Modelo de Slide del Carousel
/// Representa un slide del hero carousel en la homepage
/// DB columns: id, title, subtitle, description, image_url, cta_text, cta_link,
///   duration, sort_order, is_active, discount_code, style_config, created_at, updated_at
@Freezed(fromJson: false, toJson: false)
class CarouselSlideModel with _$CarouselSlideModel {
  const factory CarouselSlideModel({
    required String id,
    String? title,
    String? subtitle,
    String? description,
    required String imageUrl,
    String? ctaText,
    String? ctaLink,
    @Default(5000) int duration,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    String? discountCode,
    Map<String, dynamic>? styleConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CarouselSlideModel;

  const CarouselSlideModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory CarouselSlideModel.fromJson(Map<String, dynamic> json) =>
      CarouselSlideModel(
        id: json['id'] as String,
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String? ?? '',
        ctaText: json['cta_text'] as String?,
        ctaLink: json['cta_link'] as String?,
        duration: json['duration'] as int? ?? 5000,
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        discountCode: json['discount_code'] as String?,
        styleConfig: json['style_config'] as Map<String, dynamic>?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  /// Serializar para escritura a Supabase (solo campos editables)
  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'image_url': imageUrl,
        'cta_text': ctaText,
        'cta_link': ctaLink,
        'duration': duration,
        'sort_order': sortOrder,
        'is_active': isActive,
        'discount_code': discountCode,
        'style_config': styleConfig,
      };

  /// Serializar con ID (para upsert)
  Map<String, dynamic> toFullJson() => {
        'id': id,
        ...toJson(),
      };

  /// ¿Tiene CTA?
  bool get hasCta => ctaText != null && ctaLink != null;

  /// Duración en segundos
  double get durationSeconds => duration / 1000.0;
}
