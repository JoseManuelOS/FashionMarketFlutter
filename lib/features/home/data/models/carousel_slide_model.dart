import 'package:freezed_annotation/freezed_annotation.dart';

part 'carousel_slide_model.freezed.dart';

/// Modelo de Slide del Carousel
/// Representa un slide del hero carousel en la homepage
@Freezed(fromJson: false, toJson: false)
class CarouselSlideModel with _$CarouselSlideModel {
  const factory CarouselSlideModel({
    required String id,
    String? title,
    String? subtitle,
    required String imageUrl,
    String? mobileImageUrl,
    String? ctaText,
    String? ctaLink,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _CarouselSlideModel;

  const CarouselSlideModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory CarouselSlideModel.fromJson(Map<String, dynamic> json) =>
      CarouselSlideModel(
        id: json['id'] as String,
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        imageUrl: json['image_url'] as String,
        mobileImageUrl: json['mobile_image_url'] as String?,
        ctaText: json['cta_text'] as String?,
        ctaLink: json['cta_link'] as String?,
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Imagen optimizada para móvil
  String get responsiveImage => mobileImageUrl ?? imageUrl;

  /// ¿Tiene CTA?
  bool get hasCta => ctaText != null && ctaLink != null;
}
