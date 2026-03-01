// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  bool get isOffer => throw _privateConstructorUsedError;
  double? get originalPrice => throw _privateConstructorUsedError;
  int? get discountPercent => throw _privateConstructorUsedError;
  List<String> get sizes => throw _privateConstructorUsedError;
  Map<String, int>? get stockBySize => throw _privateConstructorUsedError;

  /// Stock por color y talla: { "Rojo": { "M": 5, "L": 3 }, "Azul": { "M": 2 } }
  Map<String, Map<String, int>>? get stockByColorSize =>
      throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError; // Relaciones
  CategoryModel? get category => throw _privateConstructorUsedError;
  List<ProductImageModel> get images => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String slug,
      String? description,
      double price,
      int stock,
      String? categoryId,
      bool isOffer,
      double? originalPrice,
      int? discountPercent,
      List<String> sizes,
      Map<String, int>? stockBySize,
      Map<String, Map<String, int>>? stockByColorSize,
      bool active,
      DateTime? createdAt,
      DateTime? updatedAt,
      CategoryModel? category,
      List<ProductImageModel> images,
      List<String> tags});

  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? price = null,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? isOffer = null,
    Object? originalPrice = freezed,
    Object? discountPercent = freezed,
    Object? sizes = null,
    Object? stockBySize = freezed,
    Object? stockByColorSize = freezed,
    Object? active = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? category = freezed,
    Object? images = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOffer: null == isOffer
          ? _value.isOffer
          : isOffer // ignore: cast_nullable_to_non_nullable
              as bool,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      sizes: null == sizes
          ? _value.sizes
          : sizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stockBySize: freezed == stockBySize
          ? _value.stockBySize
          : stockBySize // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      stockByColorSize: freezed == stockByColorSize
          ? _value.stockByColorSize
          : stockByColorSize // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, int>>?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ProductImageModel>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String slug,
      String? description,
      double price,
      int stock,
      String? categoryId,
      bool isOffer,
      double? originalPrice,
      int? discountPercent,
      List<String> sizes,
      Map<String, int>? stockBySize,
      Map<String, Map<String, int>>? stockByColorSize,
      bool active,
      DateTime? createdAt,
      DateTime? updatedAt,
      CategoryModel? category,
      List<ProductImageModel> images,
      List<String> tags});

  @override
  $CategoryModelCopyWith<$Res>? get category;
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? price = null,
    Object? stock = null,
    Object? categoryId = freezed,
    Object? isOffer = null,
    Object? originalPrice = freezed,
    Object? discountPercent = freezed,
    Object? sizes = null,
    Object? stockBySize = freezed,
    Object? stockByColorSize = freezed,
    Object? active = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? category = freezed,
    Object? images = null,
    Object? tags = null,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOffer: null == isOffer
          ? _value.isOffer
          : isOffer // ignore: cast_nullable_to_non_nullable
              as bool,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      sizes: null == sizes
          ? _value._sizes
          : sizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stockBySize: freezed == stockBySize
          ? _value._stockBySize
          : stockBySize // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      stockByColorSize: freezed == stockByColorSize
          ? _value._stockByColorSize
          : stockByColorSize // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, int>>?,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ProductImageModel>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      required this.name,
      required this.slug,
      this.description,
      required this.price,
      this.stock = 0,
      this.categoryId,
      this.isOffer = false,
      this.originalPrice,
      this.discountPercent,
      final List<String> sizes = const <String>[],
      final Map<String, int>? stockBySize,
      final Map<String, Map<String, int>>? stockByColorSize,
      this.active = true,
      this.createdAt,
      this.updatedAt,
      this.category,
      final List<ProductImageModel> images = const <ProductImageModel>[],
      final List<String> tags = const <String>[]})
      : _sizes = sizes,
        _stockBySize = stockBySize,
        _stockByColorSize = stockByColorSize,
        _images = images,
        _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? description;
  @override
  final double price;
  @override
  @JsonKey()
  final int stock;
  @override
  final String? categoryId;
  @override
  @JsonKey()
  final bool isOffer;
  @override
  final double? originalPrice;
  @override
  final int? discountPercent;
  final List<String> _sizes;
  @override
  @JsonKey()
  List<String> get sizes {
    if (_sizes is EqualUnmodifiableListView) return _sizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sizes);
  }

  final Map<String, int>? _stockBySize;
  @override
  Map<String, int>? get stockBySize {
    final value = _stockBySize;
    if (value == null) return null;
    if (_stockBySize is EqualUnmodifiableMapView) return _stockBySize;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Stock por color y talla: { "Rojo": { "M": 5, "L": 3 }, "Azul": { "M": 2 } }
  final Map<String, Map<String, int>>? _stockByColorSize;

  /// Stock por color y talla: { "Rojo": { "M": 5, "L": 3 }, "Azul": { "M": 2 } }
  @override
  Map<String, Map<String, int>>? get stockByColorSize {
    final value = _stockByColorSize;
    if (value == null) return null;
    if (_stockByColorSize is EqualUnmodifiableMapView) return _stockByColorSize;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool active;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Relaciones
  @override
  final CategoryModel? category;
  final List<ProductImageModel> _images;
  @override
  @JsonKey()
  List<ProductImageModel> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, slug: $slug, description: $description, price: $price, stock: $stock, categoryId: $categoryId, isOffer: $isOffer, originalPrice: $originalPrice, discountPercent: $discountPercent, sizes: $sizes, stockBySize: $stockBySize, stockByColorSize: $stockByColorSize, active: $active, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, images: $images, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isOffer, isOffer) || other.isOffer == isOffer) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            const DeepCollectionEquality().equals(other._sizes, _sizes) &&
            const DeepCollectionEquality()
                .equals(other._stockBySize, _stockBySize) &&
            const DeepCollectionEquality()
                .equals(other._stockByColorSize, _stockByColorSize) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        slug,
        description,
        price,
        stock,
        categoryId,
        isOffer,
        originalPrice,
        discountPercent,
        const DeepCollectionEquality().hash(_sizes),
        const DeepCollectionEquality().hash(_stockBySize),
        const DeepCollectionEquality().hash(_stockByColorSize),
        active,
        createdAt,
        updatedAt,
        category,
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_tags)
      ]);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel(
      {required final String id,
      required final String name,
      required final String slug,
      final String? description,
      required final double price,
      final int stock,
      final String? categoryId,
      final bool isOffer,
      final double? originalPrice,
      final int? discountPercent,
      final List<String> sizes,
      final Map<String, int>? stockBySize,
      final Map<String, Map<String, int>>? stockByColorSize,
      final bool active,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final CategoryModel? category,
      final List<ProductImageModel> images,
      final List<String> tags}) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get description;
  @override
  double get price;
  @override
  int get stock;
  @override
  String? get categoryId;
  @override
  bool get isOffer;
  @override
  double? get originalPrice;
  @override
  int? get discountPercent;
  @override
  List<String> get sizes;
  @override
  Map<String, int>? get stockBySize;

  /// Stock por color y talla: { "Rojo": { "M": 5, "L": 3 }, "Azul": { "M": 2 } }
  @override
  Map<String, Map<String, int>>? get stockByColorSize;
  @override
  bool get active;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Relaciones
  @override
  CategoryModel? get category;
  @override
  List<ProductImageModel> get images;
  @override
  List<String> get tags;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductListResponse {
  List<ProductModel> get products => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;

  /// Create a copy of ProductListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductListResponseCopyWith<ProductListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductListResponseCopyWith<$Res> {
  factory $ProductListResponseCopyWith(
          ProductListResponse value, $Res Function(ProductListResponse) then) =
      _$ProductListResponseCopyWithImpl<$Res, ProductListResponse>;
  @useResult
  $Res call({List<ProductModel> products, int total, int page, int pageSize});
}

/// @nodoc
class _$ProductListResponseCopyWithImpl<$Res, $Val extends ProductListResponse>
    implements $ProductListResponseCopyWith<$Res> {
  _$ProductListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? total = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_value.copyWith(
      products: null == products
          ? _value.products
          : products // ignore: cast_nullable_to_non_nullable
              as List<ProductModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductListResponseImplCopyWith<$Res>
    implements $ProductListResponseCopyWith<$Res> {
  factory _$$ProductListResponseImplCopyWith(_$ProductListResponseImpl value,
          $Res Function(_$ProductListResponseImpl) then) =
      __$$ProductListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ProductModel> products, int total, int page, int pageSize});
}

/// @nodoc
class __$$ProductListResponseImplCopyWithImpl<$Res>
    extends _$ProductListResponseCopyWithImpl<$Res, _$ProductListResponseImpl>
    implements _$$ProductListResponseImplCopyWith<$Res> {
  __$$ProductListResponseImplCopyWithImpl(_$ProductListResponseImpl _value,
      $Res Function(_$ProductListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? total = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_$ProductListResponseImpl(
      products: null == products
          ? _value._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<ProductModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProductListResponseImpl extends _ProductListResponse {
  const _$ProductListResponseImpl(
      {required final List<ProductModel> products,
      this.total = 0,
      this.page = 1,
      this.pageSize = 20})
      : _products = products,
        super._();

  final List<ProductModel> _products;
  @override
  List<ProductModel> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;

  @override
  String toString() {
    return 'ProductListResponse(products: $products, total: $total, page: $page, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductListResponseImpl &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_products), total, page, pageSize);

  /// Create a copy of ProductListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductListResponseImplCopyWith<_$ProductListResponseImpl> get copyWith =>
      __$$ProductListResponseImplCopyWithImpl<_$ProductListResponseImpl>(
          this, _$identity);
}

abstract class _ProductListResponse extends ProductListResponse {
  const factory _ProductListResponse(
      {required final List<ProductModel> products,
      final int total,
      final int page,
      final int pageSize}) = _$ProductListResponseImpl;
  const _ProductListResponse._() : super._();

  @override
  List<ProductModel> get products;
  @override
  int get total;
  @override
  int get page;
  @override
  int get pageSize;

  /// Create a copy of ProductListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductListResponseImplCopyWith<_$ProductListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProductFilters {
  String? get categorySlug => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  List<String>? get sizes => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  bool? get isOffer => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  ProductSortBy get sortBy => throw _privateConstructorUsedError;

  /// Create a copy of ProductFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductFiltersCopyWith<ProductFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductFiltersCopyWith<$Res> {
  factory $ProductFiltersCopyWith(
          ProductFilters value, $Res Function(ProductFilters) then) =
      _$ProductFiltersCopyWithImpl<$Res, ProductFilters>;
  @useResult
  $Res call(
      {String? categorySlug,
      String? search,
      List<String>? sizes,
      double? minPrice,
      double? maxPrice,
      bool? isOffer,
      List<String>? tags,
      ProductSortBy sortBy});
}

/// @nodoc
class _$ProductFiltersCopyWithImpl<$Res, $Val extends ProductFilters>
    implements $ProductFiltersCopyWith<$Res> {
  _$ProductFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categorySlug = freezed,
    Object? search = freezed,
    Object? sizes = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? isOffer = freezed,
    Object? tags = freezed,
    Object? sortBy = null,
  }) {
    return _then(_value.copyWith(
      categorySlug: freezed == categorySlug
          ? _value.categorySlug
          : categorySlug // ignore: cast_nullable_to_non_nullable
              as String?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      sizes: freezed == sizes
          ? _value.sizes
          : sizes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      isOffer: freezed == isOffer
          ? _value.isOffer
          : isOffer // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ProductSortBy,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductFiltersImplCopyWith<$Res>
    implements $ProductFiltersCopyWith<$Res> {
  factory _$$ProductFiltersImplCopyWith(_$ProductFiltersImpl value,
          $Res Function(_$ProductFiltersImpl) then) =
      __$$ProductFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? categorySlug,
      String? search,
      List<String>? sizes,
      double? minPrice,
      double? maxPrice,
      bool? isOffer,
      List<String>? tags,
      ProductSortBy sortBy});
}

/// @nodoc
class __$$ProductFiltersImplCopyWithImpl<$Res>
    extends _$ProductFiltersCopyWithImpl<$Res, _$ProductFiltersImpl>
    implements _$$ProductFiltersImplCopyWith<$Res> {
  __$$ProductFiltersImplCopyWithImpl(
      _$ProductFiltersImpl _value, $Res Function(_$ProductFiltersImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categorySlug = freezed,
    Object? search = freezed,
    Object? sizes = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? isOffer = freezed,
    Object? tags = freezed,
    Object? sortBy = null,
  }) {
    return _then(_$ProductFiltersImpl(
      categorySlug: freezed == categorySlug
          ? _value.categorySlug
          : categorySlug // ignore: cast_nullable_to_non_nullable
              as String?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      sizes: freezed == sizes
          ? _value._sizes
          : sizes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      isOffer: freezed == isOffer
          ? _value.isOffer
          : isOffer // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as ProductSortBy,
    ));
  }
}

/// @nodoc

class _$ProductFiltersImpl extends _ProductFilters {
  const _$ProductFiltersImpl(
      {this.categorySlug,
      this.search,
      final List<String>? sizes,
      this.minPrice,
      this.maxPrice,
      this.isOffer,
      final List<String>? tags,
      this.sortBy = ProductSortBy.newest})
      : _sizes = sizes,
        _tags = tags,
        super._();

  @override
  final String? categorySlug;
  @override
  final String? search;
  final List<String>? _sizes;
  @override
  List<String>? get sizes {
    final value = _sizes;
    if (value == null) return null;
    if (_sizes is EqualUnmodifiableListView) return _sizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  final bool? isOffer;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final ProductSortBy sortBy;

  @override
  String toString() {
    return 'ProductFilters(categorySlug: $categorySlug, search: $search, sizes: $sizes, minPrice: $minPrice, maxPrice: $maxPrice, isOffer: $isOffer, tags: $tags, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductFiltersImpl &&
            (identical(other.categorySlug, categorySlug) ||
                other.categorySlug == categorySlug) &&
            (identical(other.search, search) || other.search == search) &&
            const DeepCollectionEquality().equals(other._sizes, _sizes) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.isOffer, isOffer) || other.isOffer == isOffer) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      categorySlug,
      search,
      const DeepCollectionEquality().hash(_sizes),
      minPrice,
      maxPrice,
      isOffer,
      const DeepCollectionEquality().hash(_tags),
      sortBy);

  /// Create a copy of ProductFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductFiltersImplCopyWith<_$ProductFiltersImpl> get copyWith =>
      __$$ProductFiltersImplCopyWithImpl<_$ProductFiltersImpl>(
          this, _$identity);
}

abstract class _ProductFilters extends ProductFilters {
  const factory _ProductFilters(
      {final String? categorySlug,
      final String? search,
      final List<String>? sizes,
      final double? minPrice,
      final double? maxPrice,
      final bool? isOffer,
      final List<String>? tags,
      final ProductSortBy sortBy}) = _$ProductFiltersImpl;
  const _ProductFilters._() : super._();

  @override
  String? get categorySlug;
  @override
  String? get search;
  @override
  List<String>? get sizes;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  bool? get isOffer;
  @override
  List<String>? get tags;
  @override
  ProductSortBy get sortBy;

  /// Create a copy of ProductFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductFiltersImplCopyWith<_$ProductFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
