import '../../data/models/cart_item_model.dart';

/// Contrato del repositorio de carrito.
/// Abstrae la persistencia del carrito (Hive, SharedPreferences, etc.)
abstract class CartRepository {
  /// Obtiene todos los items del carrito
  List<CartItemModel> getItems();

  /// Añade un item al carrito (o incrementa cantidad si ya existe)
  Future<void> addItem(CartItemModel item);

  /// Elimina un item por su ID único
  Future<void> removeItem(String itemId);

  /// Actualiza la cantidad de un item
  Future<void> updateQuantity(String itemId, int quantity);

  /// Limpia todo el carrito
  Future<void> clearCart();

  /// Obtiene el total del carrito
  double getTotal();
}
