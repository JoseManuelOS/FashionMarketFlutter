// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      available: json['available'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'category_id': instance.categoryId,
      'stock_quantity': instance.stockQuantity,
      'available': instance.available,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$ProductListResponseImpl _$$ProductListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ProductListResponseImpl(
  products: (json['products'] as List<dynamic>)
      .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$$ProductListResponseImplToJson(
  _$ProductListResponseImpl instance,
) => <String, dynamic>{
  'products': instance.products,
  'total': instance.total,
  'page': instance.page,
  'pageSize': instance.pageSize,
};
