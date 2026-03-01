// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  int get orderNumber => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get customerEmail => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  String? get shippingAddress => throw _privateConstructorUsedError;
  String? get billingAddress => throw _privateConstructorUsedError;
  int? get shippingMethodId => throw _privateConstructorUsedError;
  double get shippingPrice => throw _privateConstructorUsedError;
  String? get discountCode => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  String? get stripeSessionId => throw _privateConstructorUsedError;
  String? get stripePaymentIntent => throw _privateConstructorUsedError;
  String? get trackingNumber => throw _privateConstructorUsedError;
  String? get shippingCarrier => throw _privateConstructorUsedError;
  DateTime? get shippedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<OrderItemModel> get items => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      int orderNumber,
      double totalPrice,
      OrderStatus status,
      String? customerId,
      String? customerEmail,
      String? customerName,
      String? customerPhone,
      String? shippingAddress,
      String? billingAddress,
      int? shippingMethodId,
      double shippingPrice,
      String? discountCode,
      double discountAmount,
      String? stripeSessionId,
      String? stripePaymentIntent,
      String? trackingNumber,
      String? shippingCarrier,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<OrderItemModel> items});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? totalPrice = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? customerEmail = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? shippingAddress = freezed,
    Object? billingAddress = freezed,
    Object? shippingMethodId = freezed,
    Object? shippingPrice = null,
    Object? discountCode = freezed,
    Object? discountAmount = null,
    Object? stripeSessionId = freezed,
    Object? stripePaymentIntent = freezed,
    Object? trackingNumber = freezed,
    Object? shippingCarrier = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerEmail: freezed == customerEmail
          ? _value.customerEmail
          : customerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingMethodId: freezed == shippingMethodId
          ? _value.shippingMethodId
          : shippingMethodId // ignore: cast_nullable_to_non_nullable
              as int?,
      shippingPrice: null == shippingPrice
          ? _value.shippingPrice
          : shippingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discountCode: freezed == discountCode
          ? _value.discountCode
          : discountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      stripeSessionId: freezed == stripeSessionId
          ? _value.stripeSessionId
          : stripeSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripePaymentIntent: freezed == stripePaymentIntent
          ? _value.stripePaymentIntent
          : stripePaymentIntent // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCarrier: freezed == shippingCarrier
          ? _value.shippingCarrier
          : shippingCarrier // ignore: cast_nullable_to_non_nullable
              as String?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int orderNumber,
      double totalPrice,
      OrderStatus status,
      String? customerId,
      String? customerEmail,
      String? customerName,
      String? customerPhone,
      String? shippingAddress,
      String? billingAddress,
      int? shippingMethodId,
      double shippingPrice,
      String? discountCode,
      double discountAmount,
      String? stripeSessionId,
      String? stripePaymentIntent,
      String? trackingNumber,
      String? shippingCarrier,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<OrderItemModel> items});
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? totalPrice = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? customerEmail = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? shippingAddress = freezed,
    Object? billingAddress = freezed,
    Object? shippingMethodId = freezed,
    Object? shippingPrice = null,
    Object? discountCode = freezed,
    Object? discountAmount = null,
    Object? stripeSessionId = freezed,
    Object? stripePaymentIntent = freezed,
    Object? trackingNumber = freezed,
    Object? shippingCarrier = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? items = null,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerEmail: freezed == customerEmail
          ? _value.customerEmail
          : customerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _value.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingAddress: freezed == shippingAddress
          ? _value.shippingAddress
          : shippingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      billingAddress: freezed == billingAddress
          ? _value.billingAddress
          : billingAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingMethodId: freezed == shippingMethodId
          ? _value.shippingMethodId
          : shippingMethodId // ignore: cast_nullable_to_non_nullable
              as int?,
      shippingPrice: null == shippingPrice
          ? _value.shippingPrice
          : shippingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discountCode: freezed == discountCode
          ? _value.discountCode
          : discountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      stripeSessionId: freezed == stripeSessionId
          ? _value.stripeSessionId
          : stripeSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      stripePaymentIntent: freezed == stripePaymentIntent
          ? _value.stripePaymentIntent
          : stripePaymentIntent // ignore: cast_nullable_to_non_nullable
              as String?,
      trackingNumber: freezed == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      shippingCarrier: freezed == shippingCarrier
          ? _value.shippingCarrier
          : shippingCarrier // ignore: cast_nullable_to_non_nullable
              as String?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItemModel>,
    ));
  }
}

/// @nodoc

class _$OrderModelImpl extends _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      this.orderNumber = 0,
      required this.totalPrice,
      required this.status,
      this.customerId,
      this.customerEmail,
      this.customerName,
      this.customerPhone,
      this.shippingAddress,
      this.billingAddress,
      this.shippingMethodId,
      this.shippingPrice = 0.0,
      this.discountCode,
      this.discountAmount = 0.0,
      this.stripeSessionId,
      this.stripePaymentIntent,
      this.trackingNumber,
      this.shippingCarrier,
      this.shippedAt,
      this.deliveredAt,
      this.cancelledAt,
      this.cancellationReason,
      this.notes,
      this.createdAt,
      this.updatedAt,
      final List<OrderItemModel> items = const []})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final int orderNumber;
  @override
  final double totalPrice;
  @override
  final OrderStatus status;
  @override
  final String? customerId;
  @override
  final String? customerEmail;
  @override
  final String? customerName;
  @override
  final String? customerPhone;
  @override
  final String? shippingAddress;
  @override
  final String? billingAddress;
  @override
  final int? shippingMethodId;
  @override
  @JsonKey()
  final double shippingPrice;
  @override
  final String? discountCode;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  final String? stripeSessionId;
  @override
  final String? stripePaymentIntent;
  @override
  final String? trackingNumber;
  @override
  final String? shippingCarrier;
  @override
  final DateTime? shippedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? cancelledAt;
  @override
  final String? cancellationReason;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final List<OrderItemModel> _items;
  @override
  @JsonKey()
  List<OrderItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, totalPrice: $totalPrice, status: $status, customerId: $customerId, customerEmail: $customerEmail, customerName: $customerName, customerPhone: $customerPhone, shippingAddress: $shippingAddress, billingAddress: $billingAddress, shippingMethodId: $shippingMethodId, shippingPrice: $shippingPrice, discountCode: $discountCode, discountAmount: $discountAmount, stripeSessionId: $stripeSessionId, stripePaymentIntent: $stripePaymentIntent, trackingNumber: $trackingNumber, shippingCarrier: $shippingCarrier, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.billingAddress, billingAddress) ||
                other.billingAddress == billingAddress) &&
            (identical(other.shippingMethodId, shippingMethodId) ||
                other.shippingMethodId == shippingMethodId) &&
            (identical(other.shippingPrice, shippingPrice) ||
                other.shippingPrice == shippingPrice) &&
            (identical(other.discountCode, discountCode) ||
                other.discountCode == discountCode) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.stripeSessionId, stripeSessionId) ||
                other.stripeSessionId == stripeSessionId) &&
            (identical(other.stripePaymentIntent, stripePaymentIntent) ||
                other.stripePaymentIntent == stripePaymentIntent) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.shippingCarrier, shippingCarrier) ||
                other.shippingCarrier == shippingCarrier) &&
            (identical(other.shippedAt, shippedAt) ||
                other.shippedAt == shippedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        orderNumber,
        totalPrice,
        status,
        customerId,
        customerEmail,
        customerName,
        customerPhone,
        shippingAddress,
        billingAddress,
        shippingMethodId,
        shippingPrice,
        discountCode,
        discountAmount,
        stripeSessionId,
        stripePaymentIntent,
        trackingNumber,
        shippingCarrier,
        shippedAt,
        deliveredAt,
        cancelledAt,
        cancellationReason,
        notes,
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(_items)
      ]);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);
}

abstract class _OrderModel extends OrderModel {
  const factory _OrderModel(
      {required final String id,
      final int orderNumber,
      required final double totalPrice,
      required final OrderStatus status,
      final String? customerId,
      final String? customerEmail,
      final String? customerName,
      final String? customerPhone,
      final String? shippingAddress,
      final String? billingAddress,
      final int? shippingMethodId,
      final double shippingPrice,
      final String? discountCode,
      final double discountAmount,
      final String? stripeSessionId,
      final String? stripePaymentIntent,
      final String? trackingNumber,
      final String? shippingCarrier,
      final DateTime? shippedAt,
      final DateTime? deliveredAt,
      final DateTime? cancelledAt,
      final String? cancellationReason,
      final String? notes,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final List<OrderItemModel> items}) = _$OrderModelImpl;
  const _OrderModel._() : super._();

  @override
  String get id;
  @override
  int get orderNumber;
  @override
  double get totalPrice;
  @override
  OrderStatus get status;
  @override
  String? get customerId;
  @override
  String? get customerEmail;
  @override
  String? get customerName;
  @override
  String? get customerPhone;
  @override
  String? get shippingAddress;
  @override
  String? get billingAddress;
  @override
  int? get shippingMethodId;
  @override
  double get shippingPrice;
  @override
  String? get discountCode;
  @override
  double get discountAmount;
  @override
  String? get stripeSessionId;
  @override
  String? get stripePaymentIntent;
  @override
  String? get trackingNumber;
  @override
  String? get shippingCarrier;
  @override
  DateTime? get shippedAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get cancelledAt;
  @override
  String? get cancellationReason;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  List<OrderItemModel> get items;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderItemModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String? get productSlug => throw _privateConstructorUsedError;
  String? get productImage => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String get size => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  double get priceAtPurchase => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemModelCopyWith<OrderItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemModelCopyWith<$Res> {
  factory $OrderItemModelCopyWith(
          OrderItemModel value, $Res Function(OrderItemModel) then) =
      _$OrderItemModelCopyWithImpl<$Res, OrderItemModel>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String productId,
      String productName,
      String? productSlug,
      String? productImage,
      int quantity,
      String size,
      String? color,
      double priceAtPurchase,
      DateTime? createdAt});
}

/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res, $Val extends OrderItemModel>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSlug = freezed,
    Object? productImage = freezed,
    Object? quantity = null,
    Object? size = null,
    Object? color = freezed,
    Object? priceAtPurchase = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSlug: freezed == productSlug
          ? _value.productSlug
          : productSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      priceAtPurchase: null == priceAtPurchase
          ? _value.priceAtPurchase
          : priceAtPurchase // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemModelImplCopyWith<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  factory _$$OrderItemModelImplCopyWith(_$OrderItemModelImpl value,
          $Res Function(_$OrderItemModelImpl) then) =
      __$$OrderItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String productId,
      String productName,
      String? productSlug,
      String? productImage,
      int quantity,
      String size,
      String? color,
      double priceAtPurchase,
      DateTime? createdAt});
}

/// @nodoc
class __$$OrderItemModelImplCopyWithImpl<$Res>
    extends _$OrderItemModelCopyWithImpl<$Res, _$OrderItemModelImpl>
    implements _$$OrderItemModelImplCopyWith<$Res> {
  __$$OrderItemModelImplCopyWithImpl(
      _$OrderItemModelImpl _value, $Res Function(_$OrderItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSlug = freezed,
    Object? productImage = freezed,
    Object? quantity = null,
    Object? size = null,
    Object? color = freezed,
    Object? priceAtPurchase = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$OrderItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSlug: freezed == productSlug
          ? _value.productSlug
          : productSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      productImage: freezed == productImage
          ? _value.productImage
          : productImage // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      priceAtPurchase: null == priceAtPurchase
          ? _value.priceAtPurchase
          : priceAtPurchase // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$OrderItemModelImpl extends _OrderItemModel {
  const _$OrderItemModelImpl(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.productName,
      this.productSlug,
      this.productImage,
      required this.quantity,
      required this.size,
      this.color,
      required this.priceAtPurchase,
      this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String? productSlug;
  @override
  final String? productImage;
  @override
  final int quantity;
  @override
  final String size;
  @override
  final String? color;
  @override
  final double priceAtPurchase;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'OrderItemModel(id: $id, orderId: $orderId, productId: $productId, productName: $productName, productSlug: $productSlug, productImage: $productImage, quantity: $quantity, size: $size, color: $color, priceAtPurchase: $priceAtPurchase, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSlug, productSlug) ||
                other.productSlug == productSlug) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.priceAtPurchase, priceAtPurchase) ||
                other.priceAtPurchase == priceAtPurchase) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      productId,
      productName,
      productSlug,
      productImage,
      quantity,
      size,
      color,
      priceAtPurchase,
      createdAt);

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      __$$OrderItemModelImplCopyWithImpl<_$OrderItemModelImpl>(
          this, _$identity);
}

abstract class _OrderItemModel extends OrderItemModel {
  const factory _OrderItemModel(
      {required final String id,
      required final String orderId,
      required final String productId,
      required final String productName,
      final String? productSlug,
      final String? productImage,
      required final int quantity,
      required final String size,
      final String? color,
      required final double priceAtPurchase,
      final DateTime? createdAt}) = _$OrderItemModelImpl;
  const _OrderItemModel._() : super._();

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get productId;
  @override
  String get productName;
  @override
  String? get productSlug;
  @override
  String? get productImage;
  @override
  int get quantity;
  @override
  String get size;
  @override
  String? get color;
  @override
  double get priceAtPurchase;
  @override
  DateTime? get createdAt;

  /// Create a copy of OrderItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemModelImplCopyWith<_$OrderItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ShippingMethodModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int? get estimatedDaysMin => throw _privateConstructorUsedError;
  int? get estimatedDaysMax => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Create a copy of ShippingMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingMethodModelCopyWith<ShippingMethodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingMethodModelCopyWith<$Res> {
  factory $ShippingMethodModelCopyWith(
          ShippingMethodModel value, $Res Function(ShippingMethodModel) then) =
      _$ShippingMethodModelCopyWithImpl<$Res, ShippingMethodModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      double price,
      int? estimatedDaysMin,
      int? estimatedDaysMax,
      bool isActive});
}

/// @nodoc
class _$ShippingMethodModelCopyWithImpl<$Res, $Val extends ShippingMethodModel>
    implements $ShippingMethodModelCopyWith<$Res> {
  _$ShippingMethodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? estimatedDaysMin = freezed,
    Object? estimatedDaysMax = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedDaysMin: freezed == estimatedDaysMin
          ? _value.estimatedDaysMin
          : estimatedDaysMin // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedDaysMax: freezed == estimatedDaysMax
          ? _value.estimatedDaysMax
          : estimatedDaysMax // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShippingMethodModelImplCopyWith<$Res>
    implements $ShippingMethodModelCopyWith<$Res> {
  factory _$$ShippingMethodModelImplCopyWith(_$ShippingMethodModelImpl value,
          $Res Function(_$ShippingMethodModelImpl) then) =
      __$$ShippingMethodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      double price,
      int? estimatedDaysMin,
      int? estimatedDaysMax,
      bool isActive});
}

/// @nodoc
class __$$ShippingMethodModelImplCopyWithImpl<$Res>
    extends _$ShippingMethodModelCopyWithImpl<$Res, _$ShippingMethodModelImpl>
    implements _$$ShippingMethodModelImplCopyWith<$Res> {
  __$$ShippingMethodModelImplCopyWithImpl(_$ShippingMethodModelImpl _value,
      $Res Function(_$ShippingMethodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShippingMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? estimatedDaysMin = freezed,
    Object? estimatedDaysMax = freezed,
    Object? isActive = null,
  }) {
    return _then(_$ShippingMethodModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedDaysMin: freezed == estimatedDaysMin
          ? _value.estimatedDaysMin
          : estimatedDaysMin // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedDaysMax: freezed == estimatedDaysMax
          ? _value.estimatedDaysMax
          : estimatedDaysMax // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ShippingMethodModelImpl extends _ShippingMethodModel {
  const _$ShippingMethodModelImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.price,
      this.estimatedDaysMin,
      this.estimatedDaysMax,
      this.isActive = true})
      : super._();

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  final int? estimatedDaysMin;
  @override
  final int? estimatedDaysMax;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ShippingMethodModel(id: $id, name: $name, description: $description, price: $price, estimatedDaysMin: $estimatedDaysMin, estimatedDaysMax: $estimatedDaysMax, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingMethodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.estimatedDaysMin, estimatedDaysMin) ||
                other.estimatedDaysMin == estimatedDaysMin) &&
            (identical(other.estimatedDaysMax, estimatedDaysMax) ||
                other.estimatedDaysMax == estimatedDaysMax) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, price,
      estimatedDaysMin, estimatedDaysMax, isActive);

  /// Create a copy of ShippingMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingMethodModelImplCopyWith<_$ShippingMethodModelImpl> get copyWith =>
      __$$ShippingMethodModelImplCopyWithImpl<_$ShippingMethodModelImpl>(
          this, _$identity);
}

abstract class _ShippingMethodModel extends ShippingMethodModel {
  const factory _ShippingMethodModel(
      {required final int id,
      required final String name,
      final String? description,
      required final double price,
      final int? estimatedDaysMin,
      final int? estimatedDaysMax,
      final bool isActive}) = _$ShippingMethodModelImpl;
  const _ShippingMethodModel._() : super._();

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  int? get estimatedDaysMin;
  @override
  int? get estimatedDaysMax;
  @override
  bool get isActive;

  /// Create a copy of ShippingMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingMethodModelImplCopyWith<_$ShippingMethodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
