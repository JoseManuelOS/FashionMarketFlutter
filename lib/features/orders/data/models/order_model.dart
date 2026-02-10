import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';

/// Estados posibles de un pedido
enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.paid:
        return 'Pagado';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Tu pedido está pendiente de pago';
      case OrderStatus.paid:
        return 'Pago confirmado, preparando envío';
      case OrderStatus.shipped:
        return 'Tu pedido ha sido enviado';
      case OrderStatus.delivered:
        return 'Pedido entregado';
      case OrderStatus.cancelled:
        return 'Pedido cancelado';
    }
  }

  bool get canCancel => this == OrderStatus.pending || this == OrderStatus.paid;
  bool get canRequestReturn => this == OrderStatus.delivered;
}

/// Modelo de Pedido
@Freezed(fromJson: false, toJson: false)
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required int id,
    required int orderNumber,
    required double totalPrice,
    required OrderStatus status,
    String? customerId,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? billingAddress,
    int? shippingMethodId,
    @Default(0.0) double shippingPrice,
    String? discountCode,
    @Default(0.0) double discountAmount,
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
    @Default([]) List<OrderItemModel> items,
  }) = _OrderModel;

  const OrderModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        orderNumber: json['order_number'] as int,
        totalPrice: (json['total_price'] as num).toDouble(),
        status: OrderStatus.fromString(json['status'] as String?),
        customerId: json['customer_id'] as String?,
        customerEmail: json['customer_email'] as String?,
        customerName: json['customer_name'] as String?,
        customerPhone: json['customer_phone'] as String?,
        shippingAddress: json['shipping_address'] as String?,
        billingAddress: json['billing_address'] as String?,
        shippingMethodId: json['shipping_method_id'] as int?,
        shippingPrice: (json['shipping_price'] as num?)?.toDouble() ?? 0.0,
        discountCode: json['discount_code'] as String?,
        discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
        stripeSessionId: json['stripe_session_id'] as String?,
        stripePaymentIntent: json['stripe_payment_intent'] as String?,
        trackingNumber: json['tracking_number'] as String?,
        shippingCarrier: json['shipping_carrier'] as String?,
        shippedAt: json['shipped_at'] != null
            ? DateTime.tryParse(json['shipped_at'] as String)
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.tryParse(json['delivered_at'] as String)
            : null,
        cancelledAt: json['cancelled_at'] != null
            ? DateTime.tryParse(json['cancelled_at'] as String)
            : null,
        cancellationReason: json['cancellation_reason'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Número de pedido formateado
  String get formattedOrderNumber => '#${orderNumber.toString().padLeft(6, '0')}';

  /// Total formateado
  String get formattedTotal => '€${totalPrice.toStringAsFixed(2)}';

  /// Subtotal (sin envío ni descuento)
  double get subtotal => totalPrice - shippingPrice + discountAmount;

  /// ¿Tiene tracking?
  bool get hasTracking => trackingNumber != null && trackingNumber!.isNotEmpty;

  /// URL de seguimiento (si tiene carrier conocido)
  String? get trackingUrl {
    if (!hasTracking) return null;
    final carrier = shippingCarrier?.toLowerCase();
    if (carrier == null) return null;

    if (carrier.contains('seur')) {
      return 'https://www.seur.com/livetracking/?segOnlineIdentificador=$trackingNumber';
    } else if (carrier.contains('correos')) {
      return 'https://www.correos.es/es/es/herramientas/localizador/envios/detalle?tracking-number=$trackingNumber';
    } else if (carrier.contains('mrw')) {
      return 'https://www.mrw.es/seguimiento_envios/MRW_resultados_702498.asp?codigo=$trackingNumber';
    }
    return null;
  }
}

/// Modelo de Item del Pedido
@Freezed(fromJson: false, toJson: false)
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required int id,
    required int orderId,
    required String productId,
    required String productName,
    String? productSlug,
    String? productImage,
    required int quantity,
    required String size,
    required double priceAtPurchase,
    DateTime? createdAt,
  }) = _OrderItemModel;

  const OrderItemModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        productId: json['product_id'] as String,
        productName: json['product_name'] as String,
        productSlug: json['product_slug'] as String?,
        productImage: json['product_image'] as String?,
        quantity: json['quantity'] as int,
        size: json['size'] as String,
        priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Subtotal del item
  double get subtotal => priceAtPurchase * quantity;

  /// Precio formateado
  String get formattedPrice => '€${priceAtPurchase.toStringAsFixed(2)}';

  /// Subtotal formateado
  String get formattedSubtotal => '€${subtotal.toStringAsFixed(2)}';
}

/// Modelo de Método de Envío
@Freezed(fromJson: false, toJson: false)
class ShippingMethodModel with _$ShippingMethodModel {
  const factory ShippingMethodModel({
    required int id,
    required String name,
    String? description,
    required double price,
    int? estimatedDaysMin,
    int? estimatedDaysMax,
    @Default(true) bool isActive,
  }) = _ShippingMethodModel;

  const ShippingMethodModel._();

  /// Factory con manejo de snake_case desde Supabase
  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) =>
      ShippingMethodModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        estimatedDaysMin: json['estimated_days_min'] as int?,
        estimatedDaysMax: json['estimated_days_max'] as int?,
        isActive: json['is_active'] as bool? ?? true,
      );

  /// Precio formateado
  String get formattedPrice =>
      price == 0 ? 'Gratis' : '€${price.toStringAsFixed(2)}';

  /// Estimación de entrega
  String get estimatedDelivery {
    if (estimatedDaysMin == null && estimatedDaysMax == null) {
      return 'Consultar';
    }
    if (estimatedDaysMin == estimatedDaysMax) {
      return '$estimatedDaysMin días laborables';
    }
    return '$estimatedDaysMin-$estimatedDaysMax días laborables';
  }
}
