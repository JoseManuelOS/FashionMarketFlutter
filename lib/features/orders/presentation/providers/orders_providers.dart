import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// Provider del repositorio
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return const OrderRepository();
});

/// Provider para la lista de pedidos del usuario
final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getMyOrders();
});

/// Provider para filtrar pedidos por estado
final ordersFilterProvider = StateProvider<OrderStatus?>((ref) => null);

/// Provider de pedidos filtrados
final filteredOrdersProvider = Provider.autoDispose<AsyncValue<List<OrderModel>>>((ref) {
  final ordersAsync = ref.watch(myOrdersProvider);
  final filter = ref.watch(ordersFilterProvider);

  return ordersAsync.whenData((orders) {
    if (filter == null) return orders;
    return orders.where((o) => o.status == filter).toList();
  });
});

/// Provider para cancelar pedido
final cancelOrderProvider = FutureProvider.autoDispose.family<bool, ({String orderId, String reason})>(
  (ref, params) async {
    final repo = ref.watch(orderRepositoryProvider);
    final success = await repo.cancelOrder(
      orderId: params.orderId,
      reason: params.reason,
    );
    if (success) {
      ref.invalidate(myOrdersProvider);
    }
    return success;
  },
);

/// Provider para solicitar devolución
final requestReturnProvider = FutureProvider.autoDispose.family<bool, ({String orderId, String reason})>(
  (ref, params) async {
    final repo = ref.watch(orderRepositoryProvider);
    final success = await repo.requestReturn(
      orderId: params.orderId,
      reason: params.reason,
    );
    if (success) {
      ref.invalidate(myOrdersProvider);
    }
    return success;
  },
);
