import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  // STOCK EN TIEMPO REAL
  // ════════════════════════════════════════════════════════════════════════

  /// Obtiene stock por talla de un producto desde el backend
  /// Retorna { productId, stockBySize: { "S": 10, "M": 5 }, totalStock: 15 }
  /// En Web usa el relay de Supabase para evitar CORS.
  static Future<Map<String, dynamic>> getStockBySize({
    required String productId,
    String? color,
  }) async {
    if (kIsWeb) {
      return _callPublicRelay(
        action: 'stock',
        body: {
          'productId': productId,
          if (color != null && color.isNotEmpty) 'color': color,
        },
      );
    }
    final params = <String, String>{'productId': productId};
    if (color != null && color.isNotEmpty) params['color'] = color;
    final uri = Uri.parse('$_baseUrl/api/products/stock')
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener stock');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // CHECKOUT / STRIPE
  // ════════════════════════════════════════════════════════════════════════

  /// Crea una sesión de Stripe Checkout
  /// Retorna { sessionId, url } donde url es la URL de Stripe para pagar
  /// Usa siempre el relay para garantizar autenticación correcta en todas las plataformas.
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
    // Construir URLs de éxito/cancelación según plataforma
    // El backend de FashionStore las necesita para crear la sesión de Stripe
    final String successUrl;
    final String cancelUrl;
    if (kIsWeb) {
      final origin = Uri.base.origin;
      successUrl = '$origin/checkout/success';
      cancelUrl = '$origin/checkout';
    } else {
      successUrl = 'io.supabase.fashionmarket://checkout/success';
      cancelUrl = 'io.supabase.fashionmarket://checkout';
    }

    final body = {
      'items': items,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerName': customerName,
      'shippingAddress': shippingAddress,
      'discount': discount,
      'shippingMethodId': shippingMethodId,
      'shippingCost': shippingCost,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    };

    // Usar siempre el relay (autentica con JWT en todas las plataformas)
    final result = await _callUserRelay(action: 'checkout', body: body);
    debugPrint('[Checkout] Respuesta del relay: $result');

    final url = result['url'] as String?;
    if (result.containsKey('sessionId') && url != null && url.startsWith('http')) {
      return result;
    }

    // Mostrar la respuesta completa para diagnosticar el problema
    final error = result['error'] as String?;
    throw Exception(error ?? 'Respuesta inesperada del servidor: $result');
  }

  /// Verifica una sesión de Stripe después del pago
  /// Retorna { success, orderId }
  /// Usa siempre el relay para garantizar autenticación correcta.
  static Future<Map<String, dynamic>> verifyCheckoutSession({
    required String sessionId,
  }) async {
    final result = await _callUserRelay(
      action: 'verify-checkout',
      body: {'sessionId': sessionId},
    );
    if (result.containsKey('success') || result.containsKey('orderId')) {
      return result;
    }
    // Fallback directo
    final response = await http.post(
      Uri.parse('$_baseUrl/api/checkout/verify-session'),
      headers: _authHeaders,
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

  // ════════════════════════════════════════════════════════════════════════
  // EMAILS
  // ════════════════════════════════════════════════════════════════════════

  /// Envía email de bienvenida al registrarse
  static Future<Map<String, dynamic>> sendWelcomeEmail({
    required String to,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/email/send-welcome'),
      headers: _headers,
      body: jsonEncode({
        'to': to,
        'name': name,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Suscribe al newsletter vía API (envía email de bienvenida con código promo)
  static Future<Map<String, dynamic>> subscribeNewsletter({
    required String email,
    String? name,
    String source = 'flutter_app',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/newsletter/subscribe'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'name': name,
        'source': source,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Envía notificación de envío al cliente
  static Future<Map<String, dynamic>> sendShippingUpdate({
    required String to,
    required String orderId,
    required String trackingNumber,
    String? customerName,
    String? trackingUrl,
    String? carrierName,
    int? orderNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/email/send-shipping-update'),
      headers: _headers,
      body: jsonEncode({
        'to': to,
        'customerName': customerName,
        'orderId': orderId,
        'trackingNumber': trackingNumber,
        'trackingUrl': trackingUrl,
        'carrierName': carrierName,
        'orderNumber': orderNumber,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Envía notificación de pedido entregado al cliente
  static Future<Map<String, dynamic>> sendOrderDelivered({
    required String to,
    required String orderRef,
    String? customerName,
    List<Map<String, dynamic>>? orderItems,
    double? totalPrice,
    String? deliveredDate,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/email/send-order-delivered'),
      headers: _headers,
      body: jsonEncode({
        'to': to,
        'customerName': customerName,
        'orderRef': orderRef,
        'orderItems': orderItems,
        'totalPrice': totalPrice,
        'deliveredDate': deliveredDate ?? DateTime.now().toIso8601String(),
      }),
    );

    return jsonDecode(response.body);
  }

  /// Solicita factura del pedido (cliente autenticado)
  static Future<Map<String, dynamic>> requestInvoice({
    required String orderId,
    String? type,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders/request-invoice'),
      headers: _authHeaders,
      body: jsonEncode({
        'orderId': orderId,
        if (type != null) 'type': type,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Envía factura al cliente (admin)
  static Future<Map<String, dynamic>> sendInvoice({
    required String orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/invoice/send'),
      headers: _headers,
      body: jsonEncode({'orderId': orderId}),
    );

    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════════════════════════════
  // ADMIN — PEDIDOS (con email automático)
  // ════════════════════════════════════════════════════════════════════════

  /// URL de la Edge Function relay de Supabase
  static const String _relayUrl =
      '${AppConstants.supabaseUrl}/functions/v1/orders-relay';

  /// Headers con cookie de admin para APIs protegidas del backend
  static Map<String, String> _adminHeaders(String adminEmail) {
    final session = jsonEncode({
      'email': adminEmail,
      'role': 'admin',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    return {
      ..._headers,
      'Cookie': 'admin-session=${Uri.encodeComponent(session)}',
    };
  }

  /// Envía una acción pública (sin auth) a través del relay de Supabase (para Web/CORS)
  static Future<Map<String, dynamic>> _callPublicRelay({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse(_relayUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': AppConstants.supabaseAnonKey,
      },
      body: jsonEncode({'action': action, ...body}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Relay error: ${response.statusCode}');
    }
  }

  /// Envía una acción de usuario a través del relay de Supabase (para Web/CORS)
  static Future<Map<String, dynamic>> _callUserRelay({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    final supabaseSession = Supabase.instance.client.auth.currentSession;
    final response = await http.post(
      Uri.parse(_relayUrl),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseSession != null)
          'Authorization': 'Bearer ${supabaseSession.accessToken}',
        'apikey': AppConstants.supabaseAnonKey,
      },
      body: jsonEncode({'action': action, ...body}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Envía una acción admin a través del relay de Supabase (para Web/CORS)
  static Future<Map<String, dynamic>> _callAdminRelay({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    final supabaseSession = Supabase.instance.client.auth.currentSession;
    final response = await http.post(
      Uri.parse(_relayUrl),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseSession != null)
          'Authorization': 'Bearer ${supabaseSession.accessToken}',
        'apikey': AppConstants.supabaseAnonKey,
      },
      body: jsonEncode({'action': action, ...body}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Cancelar pedido desde admin (procesa reembolso + envía email de cancelación)
  /// En Web usa el relay de Supabase para evitar CORS.
  static Future<Map<String, dynamic>> adminCancelOrder({
    required String orderId,
    required String adminEmail,
  }) async {
    if (kIsWeb) {
      return _callAdminRelay(
        action: 'admin-cancel',
        body: {'orderId': orderId, 'adminEmail': adminEmail},
      );
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders/admin-cancel'),
      headers: _adminHeaders(adminEmail),
      body: jsonEncode({'orderId': orderId}),
    );
    return jsonDecode(response.body);
  }

  /// Aceptar devolución desde admin (procesa reembolso + envía email con facturas)
  /// En Web usa el relay de Supabase para evitar CORS.
  static Future<Map<String, dynamic>> acceptReturn({
    required String orderId,
    required String adminEmail,
  }) async {
    if (kIsWeb) {
      return _callAdminRelay(
        action: 'accept-return',
        body: {'orderId': orderId, 'adminEmail': adminEmail},
      );
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders/accept-return'),
      headers: _adminHeaders(adminEmail),
      body: jsonEncode({'orderId': orderId}),
    );
    return jsonDecode(response.body);
  }

  /// Envía email de confirmación de pedido
  static Future<Map<String, dynamic>> sendOrderConfirmation({
    required String to,
    required String customerName,
    required List<Map<String, dynamic>> orderItems,
    required double total,
    String? sessionId,
    Map<String, dynamic>? shippingAddress,
    int? orderNumber,
    String? orderId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/email/send-order-confirmation'),
      headers: _headers,
      body: jsonEncode({
        'to': to,
        'customerName': customerName,
        'orderItems': orderItems,
        'total': total,
        'sessionId': sessionId,
        'shippingAddress': shippingAddress,
        'orderNumber': orderNumber,
        'orderId': orderId,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Envía newsletter masivo (admin)
  static Future<Map<String, dynamic>> sendNewsletter({
    required String subject,
    required String content,
    String? headerTitle,
    String? imageUrl,
    String? promoCode,
    String? promoDiscount,
    String? buttonText,
    String? buttonUrl,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'content': content,
    };
    if (headerTitle != null) body['headerTitle'] = headerTitle;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (promoCode != null) body['promoCode'] = promoCode;
    if (promoDiscount != null) body['promoDiscount'] = promoDiscount;
    if (buttonText != null) body['buttonText'] = buttonText;
    if (buttonUrl != null) body['buttonUrl'] = buttonUrl;

    final response = await http.post(
      Uri.parse('$_baseUrl/api/email/send-newsletter'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }
}
