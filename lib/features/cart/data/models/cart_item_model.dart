import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Modelo de Item del Carrito
/// Representa un producto añadido al carrito con su talla y cantidad
@freezed
@HiveType(typeId: 0)
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    @HiveField(0) required String id,
    @HiveField(1) required String productId,
    @HiveField(2) required String name,
    @HiveField(3) required String slug,
    @HiveField(4) required double price,
    @HiveField(5) required int quantity,
    @HiveField(6) required String size,
    @HiveField(7) required String imageUrl,
    @HiveField(8) double? originalPrice,
    @HiveField(9) @Default(0) int discountPercent,
    @HiveField(10) String? color,
  }) = _CartItemModel;

  const CartItemModel._();

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  /// ID único del item (productId + size + color)
  String get uniqueId => '${productId}_${size}_${color ?? ''}';

  /// Subtotal del item (precio * cantidad)
  double get subtotal => price * quantity;

  /// Precio original si tiene descuento
  double get originalSubtotal => (originalPrice ?? price) * quantity;

  /// Cantidad de ahorro
  double get savings => originalSubtotal - subtotal;

  /// ¿Tiene descuento?
  bool get hasDiscount => discountPercent > 0 && originalPrice != null;

  /// Precio formateado
  String get formattedPrice => '€${price.toStringAsFixed(2)}';

  /// Subtotal formateado
  String get formattedSubtotal => '€${subtotal.toStringAsFixed(2)}';

  /// Crear copia con cantidad incrementada
  CartItemModel incrementQuantity([int amount = 1]) =>
      copyWith(quantity: quantity + amount);

  /// Crear copia con cantidad decrementada
  CartItemModel decrementQuantity([int amount = 1]) =>
      copyWith(quantity: (quantity - amount).clamp(1, 999));
}
