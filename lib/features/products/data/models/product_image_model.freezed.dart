// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductImageModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get altText => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of ProductImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductImageModelCopyWith<ProductImageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductImageModelCopyWith<$Res> {
  factory $ProductImageModelCopyWith(
          ProductImageModel value, $Res Function(ProductImageModel) then) =
      _$ProductImageModelCopyWithImpl<$Res, ProductImageModel>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String imageUrl,
      int sortOrder,
      String? color,
      String? altText,
      DateTime? createdAt});
}

/// @nodoc
class _$ProductImageModelCopyWithImpl<$Res, $Val extends ProductImageModel>
    implements $ProductImageModelCopyWith<$Res> {
  _$ProductImageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? imageUrl = null,
    Object? sortOrder = null,
    Object? color = freezed,
    Object? altText = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      altText: freezed == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductImageModelImplCopyWith<$Res>
    implements $ProductImageModelCopyWith<$Res> {
  factory _$$ProductImageModelImplCopyWith(_$ProductImageModelImpl value,
          $Res Function(_$ProductImageModelImpl) then) =
      __$$ProductImageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String imageUrl,
      int sortOrder,
      String? color,
      String? altText,
      DateTime? createdAt});
}

/// @nodoc
class __$$ProductImageModelImplCopyWithImpl<$Res>
    extends _$ProductImageModelCopyWithImpl<$Res, _$ProductImageModelImpl>
    implements _$$ProductImageModelImplCopyWith<$Res> {
  __$$ProductImageModelImplCopyWithImpl(_$ProductImageModelImpl _value,
      $Res Function(_$ProductImageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductImageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? imageUrl = null,
    Object? sortOrder = null,
    Object? color = freezed,
    Object? altText = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ProductImageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      altText: freezed == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$ProductImageModelImpl extends _ProductImageModel {
  const _$ProductImageModelImpl(
      {required this.id,
      required this.productId,
      required this.imageUrl,
      this.sortOrder = 0,
      this.color,
      this.altText,
      this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String productId;
  @override
  final String imageUrl;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String? color;
  @override
  final String? altText;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ProductImageModel(id: $id, productId: $productId, imageUrl: $imageUrl, sortOrder: $sortOrder, color: $color, altText: $altText, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.altText, altText) || other.altText == altText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, productId, imageUrl,
      sortOrder, color, altText, createdAt);

  /// Create a copy of ProductImageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImageModelImplCopyWith<_$ProductImageModelImpl> get copyWith =>
      __$$ProductImageModelImplCopyWithImpl<_$ProductImageModelImpl>(
          this, _$identity);
}

abstract class _ProductImageModel extends ProductImageModel {
  const factory _ProductImageModel(
      {required final String id,
      required final String productId,
      required final String imageUrl,
      final int sortOrder,
      final String? color,
      final String? altText,
      final DateTime? createdAt}) = _$ProductImageModelImpl;
  const _ProductImageModel._() : super._();

  @override
  String get id;
  @override
  String get productId;
  @override
  String get imageUrl;
  @override
  int get sortOrder;
  @override
  String? get color;
  @override
  String? get altText;
  @override
  DateTime? get createdAt;

  /// Create a copy of ProductImageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImageModelImplCopyWith<_$ProductImageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
