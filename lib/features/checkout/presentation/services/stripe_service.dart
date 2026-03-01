import 'package:flutter/foundation.dart';
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

  /// Resuelve el color real de la variante en product_variants para un item del carrito.
  /// 
  /// El carrito almacena colores de product_images (ej. "brown", "Rojo"),
  /// pero product_variants puede tener color = '' (vacío).
  /// El backend valida stock con product_variants.color, por lo que debemos
  /// enviar el color exacto de la variante, no el de la imagen.
  /// 
  /// Usa stockBySizeColor del API de stock para encontrar la clave correcta.
  /// Las claves son "S" (color='') o "S|red" (color='red').
  static Future<Map<String, String>> _resolveVariantColors(
    List<CartItemModel> items,
  ) async {
    // Cache: productId → { size → variantColor }
    final Map<String, Map<String, String>> productSizeColorMap = {};
    // Result: cartItemUniqueId → variantColor
    final Map<String, String> resolved = {};

    for (final item in items) {
      // Fetch stock data once per product
      if (!productSizeColorMap.containsKey(item.productId)) {
        try {
          // Call without color filter to get ALL variants
          final result = await FashionStoreApiService.getStockBySize(
            productId: item.productId,
          );
          final stockBySizeColor = result['stockBySizeColor'] as Map?;
          final sizeColorMap = <String, String>{};

          if (stockBySizeColor != null) {
            for (final key in stockBySizeColor.keys) {
              final keyStr = key.toString();
              // Key format: "S" (no color) or "S|red" (with color)
              if (keyStr.contains('|')) {
                final parts = keyStr.split('|');
                final size = parts[0];
                final color = parts[1];
                // Si ya existe otra entrada para esta talla, guardar como lista
                // usando separador ; para no perder colores alternativos
                if (sizeColorMap.containsKey(size)) {
                  sizeColorMap[size] = '${sizeColorMap[size]};$color';
                } else {
                  sizeColorMap[size] = color;
                }
              } else {
                sizeColorMap[keyStr] = ''; // size → '' (empty color)
              }
            }
          }
          productSizeColorMap[item.productId] = sizeColorMap;
        } catch (e) {
          debugPrint('[Checkout] Error resolviendo color para ${item.productId}: $e');
          productSizeColorMap[item.productId] = {};
        }
      }

      final sizeMap = productSizeColorMap[item.productId]!;
      final variantColors = sizeMap[item.size] ?? item.color ?? '';
      // Si hay múltiples colores (separados por ;), buscar el que coincida
      // con el color del carrito. Si no coincide ninguno, usar el primero.
      if (variantColors.contains(';')) {
        final colors = variantColors.split(';');
        final cartColor = (item.color ?? '').toLowerCase();
        final match = colors.firstWhere(
          (c) => c.toLowerCase() == cartColor,
          orElse: () => colors.first,
        );
        resolved[item.uniqueId] = match;
      } else {
        resolved[item.uniqueId] = variantColors;
      }
    }

    return resolved;
  }

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
      // Resolver el color real de las variantes en product_variants.
      // El carrito guarda colores de product_images (ej. "brown"), pero
      // product_variants puede tener color = '' (vacío). Si no coinciden,
      // el backend rechaza el pago por "stock insuficiente".
      final variantColors = await _resolveVariantColors(items);

      // Convertir CartItemModel a formato que espera el API
      final apiItems = items.map((item) => {
        'id': item.productId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'size': item.size,
        'color': variantColors[item.uniqueId] ?? item.color ?? '',
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
