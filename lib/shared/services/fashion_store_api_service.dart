import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants/app_constants.dart';

/// Servicio para comunicarse con las APIs de FashionStore (backend Astro)
/// Reutiliza las pasarelas de pago, validación de descuentos,
/// gestión de pedidos y emails ya implementados en el servidor.
class FashionStoreApiService {
  FashionStoreApiService._();

  static const String _baseUrl = AppConstants.fashionStoreBaseUrl;

  /// Headers base para las peticiones
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Origin': _baseUrl,
      };

  /// Headers con autenticación del usuario actual de Supabase
  static Map<String, String> get _authHeaders {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      ..._headers,
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  // ════════════════════════════════════════════════════════════════════════
  // CHECKOUT / STRIPE
  // ════════════════════════════════════════════════════════════════════════

  /// Crea una sesión de Stripe Checkout
  /// Retorna { sessionId, url } donde url es la URL de Stripe para pagar
  static Future<Map<String, dynamic>> createCheckoutSession({
    required List<Map<String, dynamic>> items,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    required Map<String, String> shippingAddress,
    Map<String, dynamic>? discount,
    int? shippingMethodId,
    double shippingCost = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/checkout/create-session'),
      headers: _headers,
      body: jsonEncode({
        'items': items,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'customerName': customerName,
        'shippingAddress': shippingAddress,
        'discount': discount,
        'shippingMethodId': shippingMethodId,
        'shippingCost': shippingCost,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al crear sesión de pago');
    }
  }

  /// Verifica una sesión de Stripe después del pago
  /// Retorna { success, orderId }
  static Future<Map<String, dynamic>> verifyCheckoutSession({
    required String sessionId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/checkout/verify-session'),
      headers: _headers,
      body: jsonEncode({'sessionId': sessionId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al verificar el pago');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // DESCUENTOS
  // ════════════════════════════════════════════════════════════════════════

  /// Valida un código de descuento con la API completa del backend
  /// (incluye verificación de uso único por cliente, límites, fechas)
  static Future<Map<String, dynamic>> validateDiscountCode({
    required String code,
    String? customerEmail,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/discount/validate'),
      headers: _headers,
      body: jsonEncode({
        'code': code,
        'customerEmail': customerEmail,
      }),
    );

    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════════════════════════════
  // PEDIDOS
  // ════════════════════════════════════════════════════════════════════════

  /// Obtiene los pedidos del usuario autenticado
  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/orders/my-orders'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    } else {
      throw Exception('Error al obtener pedidos');
    }
  }

  /// Cancela un pedido
  static Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders/cancel'),
      headers: _authHeaders,
      body: jsonEncode({
        'orderId': orderId,
        'reason': reason,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Solicita devolución de un pedido
  static Future<Map<String, dynamic>> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders/request-return'),
      headers: _authHeaders,
      body: jsonEncode({
        'orderId': orderId,
        'reason': reason,
      }),
    );

    return jsonDecode(response.body);
  }
}
