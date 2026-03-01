import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/services/fashion_store_api_service.dart';
import '../../../cart/data/models/cart_item_model.dart';

/// Servicio para integrar Stripe Checkout a través del backend de FashionStore
/// Utiliza las APIs ya desplegadas en el servidor para crear sesiones de pago reales
/// con soporte para tarjeta (Visa, Mastercard, Apple Pay, Google Pay), PayPal y Revolut Pay
class StripeService {
  StripeService._();

  // Stripe publishable key (from FashionStore .env)
  static const String publishableKey =
      'pk_test_51SLMKqPdrdVG7wyai3GefN69zdF4z70PatD0TL0BnOzBhdf3GqGQFkI3lg8ArG3hIn1urgvySQPtERzKXSYBIP7W00aJ234hMU';

  /// Crea una sesión de Stripe Checkout llamando al API de FashionStore
  /// Retorna la URL de Stripe para redirigir al usuario al pago
  static Future<Map<String, dynamic>> createCheckoutSession({
    required List<CartItemModel> items,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    required Map<String, String> shippingAddress,
    String? discountCode,
    double discountAmount = 0,
    String? discountType,
    int? discountValue,
    int? shippingMethodId,
    double shippingCost = 0,
  }) async {
    try {
      // Convertir CartItemModel a formato que espera el API
      final apiItems = items.map((item) => {
        'id': item.productId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'size': item.size,
        'color': item.color ?? '',
        'image': item.imageUrl,
      }).toList();

      // Preparar descuento si existe
      Map<String, dynamic>? discount;
      if (discountCode != null && discountType != null && discountValue != null) {
        discount = {
          'code': discountCode,
          'type': discountType,
          'value': discountValue,
        };
      }

      // Llamar al API real de FashionStore
      final result = await FashionStoreApiService.createCheckoutSession(
        items: apiItems,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        customerName: customerName,
        shippingAddress: shippingAddress,
        discount: discount,
        shippingMethodId: shippingMethodId,
        shippingCost: shippingCost,
      );

      return {
        'success': true,
        'sessionId': result['sessionId'],
        'url': result['url'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Abre la URL de Stripe Checkout en el navegador externo
  static Future<bool> openCheckoutUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Verifica el pago después del redirect de Stripe
  static Future<Map<String, dynamic>> verifyPayment(String sessionId) async {
    try {
      final result = await FashionStoreApiService.verifyCheckoutSession(
        sessionId: sessionId,
      );
      return {
        'success': result['success'] == true,
        'orderId': result['orderId'],
        'orderNumber': result['orderNumber'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
