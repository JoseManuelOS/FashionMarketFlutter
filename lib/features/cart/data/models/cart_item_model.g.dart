// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 0;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      name: fields[2] as String,
      slug: fields[3] as String,
      price: fields[4] as double,
      quantity: fields[5] as int,
      size: fields[6] as String,
      imageUrl: fields[7] as String,
      originalPrice: fields[8] as double?,
      discountPercent: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.slug)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.size)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.originalPrice)
      ..writeByte(9)
      ..write(obj.discountPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      size: json['size'] as String,
      imageUrl: json['imageUrl'] as String,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'name': instance.name,
      'slug': instance.slug,
      'price': instance.price,
      'quantity': instance.quantity,
      'size': instance.size,
      'imageUrl': instance.imageUrl,
      'originalPrice': instance.originalPrice,
      'discountPercent': instance.discountPercent,
    };
