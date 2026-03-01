import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/admin_model.dart';

/// Provider para la sesión de admin actual
final adminSessionProvider = StateProvider<AdminModel?>((ref) => null);

/// Provider para verificar si hay sesión de admin activa
final isAdminLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(adminSessionProvider) != null;
});

/// Notifier para manejar autenticación de admin
class AdminAuthNotifier extends Notifier<AsyncValue<AdminModel?>> {
  @override
  AsyncValue<AdminModel?> build() {
    return const AsyncData(null);
  }

  /// Iniciar sesión como admin
  Future<AdminModel?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final supabase = Supabase.instance.client;

      print('Intentando login admin con email: $email');

      // Llamar a la función de verificación de credenciales
      final response = await supabase.rpc(
        'verify_admin_credentials',
        params: {
          'p_email': email,
          'p_password': password,
        },
      );

      print('Respuesta RPC: $response');

      if (response == null || (response as List).isEmpty) {
        print('Credenciales incorrectas o admin no encontrado');
        state = const AsyncData(null);
        throw Exception('Credenciales de administrador incorrectas');
      }

      final adminData = response[0] as Map<String, dynamic>;
      print('Admin encontrado: $adminData');
      
      final admin = AdminModel.fromJson(adminData);

      // Guardar la sesión
      ref.read(adminSessionProvider.notifier).state = admin;
      
      state = AsyncData(admin);
      print('Login exitoso para: ${admin.email}');
      return admin;
    } catch (e, stack) {
      print('Error en login admin: $e');
      print('Stack: $stack');
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Cerrar sesión de admin
  void signOut() {
    ref.read(adminSessionProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}

final adminAuthProvider =
    NotifierProvider<AdminAuthNotifier, AsyncValue<AdminModel?>>(
  AdminAuthNotifier.new,
);

/// Provider para estadísticas del dashboard - Usa RPC para bypassear RLS
/// La función admin_get_dashboard_stats ahora devuelve TODOS los campos necesarios
final adminDashboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final admin = ref.read(adminSessionProvider);

  if (admin == null) {
    throw Exception('No hay sesión de admin activa');
  }

  try {
    final response = await supabase.rpc(
      'admin_get_dashboard_stats',
      params: {'p_admin_email': admin.email},
    );

    if (response != null) {
      final data = response as Map<String, dynamic>;
      return {
        'totalProducts': data['totalProducts'] ?? 0,
        'totalCustomers': data['totalCustomers'] ?? 0,
        'pendingOrders': data['pendingOrders'] ?? 0,
        'monthlySales': (data['monthlySales'] as num?)?.toDouble() ?? 0.0,
        'lowStockProducts': data['lowStockCount'] ?? 0,
        'offerProducts': data['offerProducts'] ?? 0,
        'topProductName': data['topProductName'],
        'topProductQty': data['topProductQty'] ?? 0,
      };
    }

    return {
      'totalProducts': 0,
      'totalCustomers': 0,
      'pendingOrders': 0,
      'monthlySales': 0.0,
      'lowStockProducts': 0,
      'offerProducts': 0,
      'topProductName': null,
      'topProductQty': 0,
    };
  } catch (e) {
    print('Error fetching dashboard stats: $e');
    rethrow;
  }
});

/// Provider para productos recientes (admin)
final adminRecentProductsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('products')
      .select('*, images:product_images(image_url, order, color, color_hex)')
      .eq('active', true)
      .order('created_at', ascending: false)
      .limit(5);

  return List<Map<String, dynamic>>.from(response);
});

/// Provider para pedidos recientes (admin) - Usa RPC para bypassear RLS
final adminRecentOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final admin = ref.read(adminSessionProvider);

  try {
    // Intentar usar la función RPC (bypassea RLS)
    if (admin != null) {
      try {
        final response = await supabase.rpc(
          'admin_get_orders',
          params: {'p_admin_email': admin.email, 'p_status': null},
        );

        if (response != null) {
          final orders = List<Map<String, dynamic>>.from(response as List);
          return orders.take(10).toList();
        }
      } catch (rpcError) {
        print('RPC admin_get_orders no disponible: $rpcError');
      }
    }

    // Fallback: Query directa
    final response = await supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error obteniendo pedidos recientes: $e');
    return [];
  }
});

/// Provider para todos los pedidos (con filtros) - Usa RPC para bypassear RLS
final adminOrdersProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, status) async {
  final supabase = Supabase.instance.client;
  final admin = ref.read(adminSessionProvider);

  // Intentar usar la función RPC (bypassea RLS)
  if (admin != null) {
    try {
      print('Obteniendo pedidos con RPC para admin: ${admin.email}');
      final response = await supabase.rpc(
        'admin_get_orders',
        params: {
          'p_admin_email': admin.email,
          'p_status': status?.isNotEmpty == true ? status : null,
        },
      );

      print('Respuesta RPC pedidos: $response');
      
      if (response != null) {
        final orders = List<Map<String, dynamic>>.from(response as List);
        print('Pedidos obtenidos: ${orders.length}');
        return orders;
      }
    } catch (rpcError) {
      print('RPC admin_get_orders falló: $rpcError');
      // Continuar al fallback
    }
  }

  // Fallback: Query directa
  print('Intentando fallback con query directa...');
  var query = supabase
      .from('orders')
      .select('*, items:order_items(*)');

  if (status != null && status.isNotEmpty) {
    query = query.eq('status', status);
  }

  final response = await query.order('created_at', ascending: false);
  print('Respuesta fallback pedidos: ${(response as List).length} resultados');

  return List<Map<String, dynamic>>.from(response);
});

/// Provider para todos los productos (admin) - Usa RPC para bypassear RLS
final adminProductsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final admin = ref.read(adminSessionProvider);

  // Intentar usar la función RPC (bypassea RLS)
  if (admin != null) {
    try {
      print('Obteniendo productos con RPC para admin: ${admin.email}');
      final response = await supabase.rpc(
        'admin_get_products',
        params: {'p_admin_email': admin.email},
      );

      print('Respuesta RPC productos tipo: ${response.runtimeType}');

      if (response != null) {
        List<Map<String, dynamic>> products;
        
        if (response is List) {
          products = List<Map<String, dynamic>>.from(
            response.map((item) {
              if (item is Map) {
                final map = Map<String, dynamic>.from(item);
                // Asegurar que variants sea una lista
                if (map['variants'] != null && map['variants'] is! List) {
                  map['variants'] = [];
                }
                return map;
              }
              return <String, dynamic>{};
            }),
          );
        } else {
          print('Respuesta no es lista, es: ${response.runtimeType}');
          products = [];
        }
        
        // Debug: verificar si hay variants
        if (products.isNotEmpty) {
          final firstProduct = products.first;
          print('Primer producto: ${firstProduct['name']}');
          print('Variants del primer producto: ${firstProduct['variants']}');
          print('Variants tipo: ${firstProduct['variants'].runtimeType}');
        }
        
        print('Productos obtenidos: ${products.length}');
        return products;
      }
    } catch (rpcError) {
      print('RPC admin_get_products falló: $rpcError');
      // Continuar al fallback
    }
  } else {
    print('No hay sesión de admin activa');
  }

  // Fallback: Query directa (puede tener restricciones RLS)
  print('Intentando fallback con query directa...');
  final response = await supabase
      .from('products')
      .select('*, category:categories(*), images:product_images(image_url, order, color, color_hex), variants:product_variants(id, size, stock, sku, color)')
      .order('created_at', ascending: false);

  print('Respuesta fallback productos: ${(response as List).length} resultados');
  return List<Map<String, dynamic>>.from(response);
});

/// Provider para variantes de un producto específico
final adminProductVariantsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, productId) async {
  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('product_variants')
      .select('*')
      .eq('product_id', productId)
      .order('size', ascending: true);

  return List<Map<String, dynamic>>.from(response);
});

// ═══════════════════════════════════════════════════════════════════════════
// KPIs & VENTAS - Dashboard Ejecutivo
// ═══════════════════════════════════════════════════════════════════════════

/// Provider configurable para ventas de los últimos N días
final adminSalesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, days) async {
  final supabase = Supabase.instance.client;

  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: days));

  final response = await supabase
      .from('orders')
      .select('created_at, total_price, status')
      .gte('created_at', startDate.toIso8601String())
      .inFilter('status', ['paid', 'shipped', 'delivered', 'completed']);

  final orders = List<Map<String, dynamic>>.from(response);

  // Agrupar por día
  final Map<String, double> dailySales = {};
  final Map<String, int> dailyOrders = {};

  // Inicializar todos los días del período
  for (int i = days - 1; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    dailySales[dateKey] = 0;
    dailyOrders[dateKey] = 0;
  }

  // Sumar ventas y pedidos por día
  for (final order in orders) {
    final createdAt = DateTime.parse(order['created_at'] as String);
    final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    final total = (order['total_price'] as num?)?.toDouble() ?? 0;
    dailySales[dateKey] = (dailySales[dateKey] ?? 0) + total;
    dailyOrders[dateKey] = (dailyOrders[dateKey] ?? 0) + 1;
  }

  return dailySales.entries
      .map((e) => {
            'date': e.key,
            'total': e.value,
            'orders': dailyOrders[e.key] ?? 0,
          })
      .toList();
});

/// Provider retrocompatible para ventas de los últimos 7 días
final adminSalesLast7DaysProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminSalesProvider(7).future);
});

// ═══════════════════════════════════════════════════════════════════════════
// CÓDIGOS DE DESCUENTO
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para códigos de descuento
class AdminDiscountCodesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchCodes();
  }

  Future<List<Map<String, dynamic>>> _fetchCodes() async {
    final supabase = Supabase.instance.client;
    
    final response = await supabase
        .from('discount_codes')
        .select('*')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> createCode({
    required String code,
    required String description,
    required String discountType,
    required double discountValue,
    required double minPurchase,
    int? usageLimit,
    required bool singleUse,
    DateTime? expiresAt,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('discount_codes').insert({
        'code': code,
        'description': description,
        'discount_type': discountType,
        'discount_value': discountValue,
        'min_purchase': minPurchase,
        'usage_limit': usageLimit,
        'single_use_per_customer': singleUse,
        'expires_at': expiresAt?.toIso8601String(),
        'active': true,
      });

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error creating discount code: $e');
      return false;
    }
  }

  Future<bool> toggleCode(dynamic id, bool active) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('discount_codes')
          .update({'active': active})
          .eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error toggling discount code: $e');
      return false;
    }
  }

  Future<bool> deleteCode(dynamic id) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('discount_codes')
          .delete()
          .eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error deleting discount code: $e');
      return false;
    }
  }
}

final adminDiscountCodesProvider =
    AsyncNotifierProvider<AdminDiscountCodesNotifier, List<Map<String, dynamic>>>(
  AdminDiscountCodesNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// CARRUSEL
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para slides del carrusel
class AdminCarouselSlidesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchSlides();
  }

  Future<List<Map<String, dynamic>>> _fetchSlides() async {
    final supabase = Supabase.instance.client;
    
    final response = await supabase
        .from('carousel_slides')
        .select('*')
        .order('sort_order', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> createSlide({
    required String title,
    String? subtitle,
    String? description,
    required String imageUrl,
    required String ctaText,
    required String ctaLink,
    required int duration,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Obtener el máximo orden
      final orderResponse = await supabase
          .from('carousel_slides')
          .select('sort_order')
          .order('sort_order', ascending: false)
          .limit(1);

      final maxOrder = orderResponse.isNotEmpty 
          ? ((orderResponse[0]['sort_order'] as int?) ?? 0) + 1 
          : 0;

      await supabase.from('carousel_slides').insert({
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'image_url': imageUrl,
        'cta_text': ctaText,
        'cta_link': ctaLink,
        'duration': duration,
        'sort_order': maxOrder,
        'is_active': true,
      });

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error creating carousel slide: $e');
      return false;
    }
  }

  Future<bool> toggleSlide(dynamic id, bool active) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('carousel_slides')
          .update({'is_active': active})
          .eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error toggling carousel slide: $e');
      return false;
    }
  }

  Future<bool> deleteSlide(dynamic id) async {
    try {
      final supabase = Supabase.instance.client;
      
      await supabase
          .from('carousel_slides')
          .delete()
          .eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error deleting carousel slide: $e');
      return false;
    }
  }
}

final adminCarouselSlidesProvider =
    AsyncNotifierProvider<AdminCarouselSlidesNotifier, List<Map<String, dynamic>>>(
  AdminCarouselSlidesNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// USUARIOS/CLIENTES
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para usuarios/clientes - Usa RPC para bypassear RLS
final adminUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final admin = ref.read(adminSessionProvider);

  try {
    // Intentar usar la función RPC (bypassea RLS)
    if (admin != null) {
      try {
        final response = await supabase.rpc(
          'admin_get_customers',
          params: {'p_admin_email': admin.email},
        );

        if (response != null) {
          return List<Map<String, dynamic>>.from(response as List);
        }
      } catch (rpcError) {
        print('RPC admin_get_customers no disponible: $rpcError');
      }
    }

    // Fallback: Query directa (puede tener restricciones RLS)
    final response = await supabase
        .from('customers')
        .select('*')
        .order('created_at', ascending: false);

    final customers = List<Map<String, dynamic>>.from(response);

    // Obtener estadísticas de pedidos para cada cliente
    for (int i = 0; i < customers.length; i++) {
      final customerId = customers[i]['id'];
      
      try {
        final ordersResponse = await supabase
            .from('orders')
            .select('id, total_price')
            .eq('customer_id', customerId);

        final orders = List<Map<String, dynamic>>.from(ordersResponse);
        customers[i]['orders_count'] = orders.length;
        customers[i]['total_spent'] = orders.fold<double>(
          0,
          (sum, o) => sum + ((o['total_price'] as num?)?.toDouble() ?? 0),
        );
      } catch (_) {
        customers[i]['orders_count'] = 0;
        customers[i]['total_spent'] = 0.0;
      }
    }

    return customers;
  } catch (e) {
    print('Error obteniendo clientes: $e');
    return [];
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// CATEGORÍAS - CRUD completo
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para categorías (admin CRUD)
class AdminCategoriesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchCategories();
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final supabase = Supabase.instance.client;
    final admin = ref.read(adminSessionProvider);

    // Intentar RPC (bypasea RLS y trae products_count)
    if (admin != null) {
      try {
        final response = await supabase.rpc(
          'admin_get_categories',
          params: {'p_admin_email': admin.email},
        );

        if (response != null) {
          return List<Map<String, dynamic>>.from(response as List);
        }
      } catch (rpcError) {
        print('RPC admin_get_categories no disponible: $rpcError');
      }
    }

    // Fallback: Query directa (categories tiene public read)
    final response = await supabase
        .from('categories')
        .select('*')
        .order('display_order', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> createCategory({
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    int displayOrder = 0,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final admin = ref.read(adminSessionProvider);

      if (admin != null) {
        try {
          final data = {
            'name': name,
            'slug': slug,
            'description': description,
            'image_url': imageUrl,
            'display_order': displayOrder,
          };

          await supabase.rpc(
            'admin_upsert_category',
            params: {
              'p_admin_email': admin.email,
              'p_data': jsonEncode(data),
            },
          );

          ref.invalidateSelf();
          return true;
        } catch (rpcError) {
          print('RPC admin_upsert_category falló: $rpcError');
        }
      }

      // Fallback: inserción directa
      await supabase.from('categories').insert({
        'name': name,
        'slug': slug,
        'description': description,
        'image_url': imageUrl,
        'display_order': displayOrder,
      });

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    int displayOrder = 0,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final admin = ref.read(adminSessionProvider);

      if (admin != null) {
        try {
          final data = {
            'id': id,
            'name': name,
            'slug': slug,
            'description': description,
            'image_url': imageUrl,
            'display_order': displayOrder,
          };

          await supabase.rpc(
            'admin_upsert_category',
            params: {
              'p_admin_email': admin.email,
              'p_data': jsonEncode(data),
            },
          );

          ref.invalidateSelf();
          return true;
        } catch (rpcError) {
          print('RPC admin_upsert_category falló: $rpcError');
        }
      }

      // Fallback: update directo
      await supabase
          .from('categories')
          .update({
            'name': name,
            'slug': slug,
            'description': description,
            'image_url': imageUrl,
            'display_order': displayOrder,
          })
          .eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final admin = ref.read(adminSessionProvider);

      if (admin != null) {
        try {
          await supabase.rpc(
            'admin_delete_category',
            params: {
              'p_admin_email': admin.email,
              'p_category_id': id,
            },
          );

          ref.invalidateSelf();
          return true;
        } catch (rpcError) {
          print('RPC admin_delete_category falló: $rpcError');
        }
      }

      // Fallback: delete directo
      await supabase.from('categories').delete().eq('id', id);

      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}

final adminCategoriesProvider =
    AsyncNotifierProvider<AdminCategoriesNotifier, List<Map<String, dynamic>>>(
  AdminCategoriesNotifier.new,
);
