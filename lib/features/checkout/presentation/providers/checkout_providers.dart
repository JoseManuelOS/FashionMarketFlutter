import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/services/fashion_store_api_service.dart';

/// Estado actual del paso de checkout
final checkoutStepProvider = StateProvider<int>((ref) => 0);

/// Modelo de datos del checkout
class CheckoutData {
  final String email;
  final String phone;
  final String fullName;
  final String street;
  final String postalCode;
  final String city;
  final String province;
  final String country;
  final int? shippingMethodId;
  final String? shippingMethodName;
  final double shippingCost;
  final String? discountCode;
  final double discountAmount;
  final String? discountType;
  final int? discountValue;

  const CheckoutData({
    this.email = '',
    this.phone = '',
    this.fullName = '',
    this.street = '',
    this.postalCode = '',
    this.city = '',
    this.province = '',
    this.country = 'ES',
    this.shippingMethodId,
    this.shippingMethodName,
    this.shippingCost = 0,
    this.discountCode,
    this.discountAmount = 0,
    this.discountType,
    this.discountValue,
  });

  CheckoutData copyWith({
    String? email,
    String? phone,
    String? fullName,
    String? street,
    String? postalCode,
    String? city,
    String? province,
    String? country,
    int? shippingMethodId,
    String? shippingMethodName,
    double? shippingCost,
    String? discountCode,
    double? discountAmount,
    String? discountType,
    int? discountValue,
    bool clearDiscount = false,
  }) {
    return CheckoutData(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      province: province ?? this.province,
      country: country ?? this.country,
      shippingMethodId: shippingMethodId ?? this.shippingMethodId,
      shippingMethodName: shippingMethodName ?? this.shippingMethodName,
      shippingCost: shippingCost ?? this.shippingCost,
      discountCode: clearDiscount ? null : (discountCode ?? this.discountCode),
      discountAmount: clearDiscount ? 0 : (discountAmount ?? this.discountAmount),
      discountType: clearDiscount ? null : (discountType ?? this.discountType),
      discountValue: clearDiscount ? null : (discountValue ?? this.discountValue),
    );
  }

  String get formattedAddress =>
      '$street, $postalCode $city${province.isNotEmpty ? ', $province' : ''}';
}

/// Notifier para los datos del checkout
class CheckoutDataNotifier extends Notifier<CheckoutData> {
  @override
  CheckoutData build() => const CheckoutData();

  void setShippingData({
    required String email,
    required String phone,
    required String fullName,
    required String street,
    required String postalCode,
    required String city,
    required String province,
    required String country,
  }) {
    state = state.copyWith(
      email: email,
      phone: phone,
      fullName: fullName,
      street: street,
      postalCode: postalCode,
      city: city,
      province: province,
      country: country,
    );
  }

  void setShippingMethod({
    required int id,
    required String name,
    required double cost,
  }) {
    state = state.copyWith(
      shippingMethodId: id,
      shippingMethodName: name,
      shippingCost: cost,
    );
  }

  void setDiscount({
    required String code,
    required double amount,
    required String type,
    required int value,
  }) {
    state = state.copyWith(
      discountCode: code,
      discountAmount: amount,
      discountType: type,
      discountValue: value,
    );
  }

  void clearDiscount() {
    state = state.copyWith(clearDiscount: true);
  }

  void reset() {
    state = const CheckoutData();
  }
}

final checkoutDataProvider =
    NotifierProvider<CheckoutDataNotifier, CheckoutData>(
  CheckoutDataNotifier.new,
);

/// Modelo de método de envío
class ShippingMethod {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? estimatedDays;

  const ShippingMethod({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.estimatedDays,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      estimatedDays: json['estimated_days'] as String?,
    );
  }
}

/// Provider para métodos de envío
final shippingMethodsProvider = FutureProvider<List<ShippingMethod>>((ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('shipping_methods')
      .select()
      .eq('is_active', true)
      .order('price', ascending: true);

  return (response as List)
      .map((json) => ShippingMethod.fromJson(json))
      .toList();
});

/// Provider para validar código de descuento usando el API de FashionStore
/// (validación completa: uso único por cliente, límites globales, fechas)
final validateDiscountProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, code) async {
  if (code.isEmpty) return null;

  // Obtener email del usuario actual para verificación de uso único
  final user = Supabase.instance.client.auth.currentUser;
  final customerEmail = user?.email;

  try {
    final result = await FashionStoreApiService.validateDiscountCode(
      code: code,
      customerEmail: customerEmail,
    );

    if (result['valid'] == true) {
      final discount = result['discount'];
      return {
        'valid': true,
        'discount': {
          'code': discount['code'],
          'type': discount['type'],
          'value': (discount['value'] is double)
              ? (discount['value'] as double).toInt()
              : discount['value'],
          'description': discount['description'],
        }
      };
    } else {
      return {
        'valid': false,
        'error': result['error'] ?? 'Código no válido',
      };
    }
  } catch (e) {
    return {'valid': false, 'error': 'Error al validar el código'};
  }
});

/// Estado de carga del pago
final paymentLoadingProvider = StateProvider<bool>((ref) => false);

/// Modelo de dirección guardada del cliente
class SavedAddress {
  final String id;
  final String label;
  final String fullName;
  final String? phone;
  final String street;
  final String city;
  final String postalCode;
  final String province;
  final String country;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.province,
    required this.country,
    this.isDefault = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String?,
        street: json['street'] as String? ?? '',
        city: json['city'] as String? ?? '',
        postalCode: json['postal_code'] as String? ?? '',
        province: json['province'] as String? ?? '',
        country: json['country'] as String? ?? 'ES',
        isDefault: json['is_default'] as bool? ?? false,
      );
}

/// Provider para las direcciones guardadas del usuario
final savedAddressesProvider = FutureProvider<List<SavedAddress>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  final data = await supabase
      .from('customer_addresses')
      .select()
      .eq('customer_id', userId)
      .order('is_default', ascending: false)
      .order('created_at', ascending: false);

  return (data as List)
      .map((json) => SavedAddress.fromJson(json as Map<String, dynamic>))
      .toList();
});
