import '../../data/models/order_model.dart';

/// Contrato del repositorio de pedidos.
/// Separa la lógica de acceso a datos de la capa de presentación.
abstract class OrderRepositoryContract {
  /// Obtiene todos los pedidos del usuario autenticado
  Future<List<OrderModel>> getMyOrders();

  /// Obtiene un pedido por su ID
  Future<OrderModel> getOrderById(String orderId);

  /// Cancela un pedido
  Future<void> cancelOrder(String orderId, {String? reason});

  /// Solicita la devolución de un pedido
  Future<void> requestReturn(String orderId, {required String reason});

  /// Solicita la factura de un pedido
  Future<void> requestInvoice(String orderId);
}
