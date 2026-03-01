import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../models/order_model.dart';

/// Repositorio de pedidos.
///
/// - getMyOrders : consulta directa a Supabase
/// - cancelOrder / requestReturn / requestInvoice:
///     • Móvil  → API de FashionStore (emails + Stripe + stock)
///     • Web    → Supabase Edge Function `orders-relay` (proxy S2S, sin CORS)
///               que reenvía la petición al servidor de FashionStore
class OrderRepository {
  const OrderRepository();

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  /// URL de la Edge Function desplegada en Supabase.
  static const String _relayUrl =
      '${AppConstants.supabaseUrl}/functions/v1/orders-relay';

  // ─── helper ──────────────────────────────────────────────────────────
  /// Llama a la Edge Function `orders-relay` con la acción indicada.
  /// La función reenvía la petición a FashionStore servidor-a-servidor,
  /// por lo que los emails, Stripe y notificaciones admin funcionan igual
  /// que si lo llamara la app nativa.
  Future<Map<String, dynamic>> _callRelay({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Usuario no autenticado');

    final response = await http.post(
      Uri.parse(_relayUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
        'apikey': AppConstants.supabaseAnonKey,
      },
      body: jsonEncode({'action': action, ...body}),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─── getMyOrders ─────────────────────────────────────────────────────
  /// Obtiene los pedidos del usuario autenticado (Supabase directo)
  Future<List<OrderModel>> getMyOrders() async {
    if (_userId == null) throw Exception('Usuario no autenticado');

    final data = await _supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('customer_id', _userId!)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ─── cancelOrder ─────────────────────────────────────────────────────
  /// Cancela un pedido (Stripe refund + emails + restaura stock).
  /// • Web    → Edge Function relay (evita CORS del navegador)
  /// • Móvil  → API directa de FashionStore
  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    if (kIsWeb) {
      final result = await _callRelay(
        action: 'cancel',
        body: {'orderId': orderId, 'reason': reason},
      );
      return result['success'] == true;
    }
    try {
      final result = await FashionStoreApiService.cancelOrder(
        orderId: orderId,
        reason: reason,
      );
      return result['success'] == true;
    } catch (_) {
      // Fallback: actualiza estado si la API no responde
      await _supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);
      return true;
    }
  }

  // ─── requestReturn ───────────────────────────────────────────────────
  /// Solicita devolución (actualiza estado + emails al cliente y admin).
  /// • Web    → Edge Function relay
  /// • Móvil  → API directa de FashionStore
  Future<bool> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    if (kIsWeb) {
      final result = await _callRelay(
        action: 'request-return',
        body: {'orderId': orderId, 'reason': reason},
      );
      return result['success'] == true;
    }
    try {
      final result = await FashionStoreApiService.requestReturn(
        orderId: orderId,
        reason: reason,
      );
      return result['success'] == true;
    } catch (_) {
      // Fallback: actualiza estado si la API no responde
      await _supabase
          .from('orders')
          .update({'status': 'return_requested'})
          .eq('id', orderId);
      return true;
    }
  }

  // ─── requestInvoice ──────────────────────────────────────────────────
  /// Solicita la factura por email (genera PDF + Resend).
  /// • Web    → Edge Function relay
  /// • Móvil  → API directa de FashionStore
  Future<Map<String, dynamic>> requestInvoice({
    required String orderId,
    String? type,
  }) async {
    if (kIsWeb) {
      return _callRelay(
        action: 'request-invoice',
        body: {
          'orderId': orderId,
          if (type != null) 'type': type,
        },
      );
    }
    return FashionStoreApiService.requestInvoice(
      orderId: orderId,
      type: type,
    );
  }
}
