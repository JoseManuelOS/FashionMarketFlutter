import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/services/fashion_store_api_service.dart';
import '../models/order_model.dart';

/// Repositorio de pedidos
/// - getMyOrders: consulta directa a Supabase
/// - cancelOrder / requestReturn: vía API de FashionStore
///   (envían emails al cliente y admin + restauran stock)
class OrderRepository {
  const OrderRepository();

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  /// Obtiene los pedidos del usuario autenticado (Supabase directo)
  Future<List<OrderModel>> getMyOrders() async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    final data = await _supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('customer_id', _userId!)
        .order('created_at', ascending: false);

    return (data as List).map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Cancela un pedido vía API (envía emails + restaura stock)
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final result = await FashionStoreApiService.cancelOrder(
      orderId: orderId,
      reason: reason,
    );
    return result['success'] == true;
  }

  /// Solicita devolución vía API (envía emails al cliente y admin)
  Future<bool> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    final result = await FashionStoreApiService.requestReturn(
      orderId: orderId,
      reason: reason,
    );
    return result['success'] == true;
  }
}
