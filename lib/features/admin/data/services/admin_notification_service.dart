import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_notification_model.dart';

/// Servicio para gestionar notificaciones del admin
class AdminNotificationService {
  final SupabaseClient _supabase;
  
  AdminNotificationService(this._supabase);

  /// Obtiene el resumen de notificaciones pendientes
  Future<NotificationSummary> getNotificationSummary() async {
    try {
      // 1. Contar pedidos nuevos (creados en las últimas 24 horas)
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final newOrdersResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'paid')
          .gte('created_at', yesterday.toIso8601String());
      
      final newOrdersCount = (newOrdersResponse as List).length;

      // 2. Contar pedidos pendientes de envío (paid pero no shipped)
      final pendingOrdersResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'paid');
      
      final pendingOrdersCount = (pendingOrdersResponse as List).length;

      // 3. Contar productos con stock bajo (≤5 unidades)
      // Contar por variantes de talla
      final lowStockResponse = await _supabase
          .from('product_variants')
          .select('id')
          .lte('stock', 5)
          .gt('stock', 0);
      
      final lowStockCount = (lowStockResponse as List).length;

      // 4. Contar productos agotados (stock = 0)
      final outOfStockResponse = await _supabase
          .from('product_variants')
          .select('id')
          .eq('stock', 0);
      
      final outOfStockCount = (outOfStockResponse as List).length;

      // Total de notificaciones sin leer
      final totalUnread = newOrdersCount + lowStockCount + outOfStockCount;

      return NotificationSummary(
        newOrdersCount: newOrdersCount,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
        pendingOrdersCount: pendingOrdersCount,
        totalUnread: totalUnread,
      );
    } catch (e) {
      print('Error al obtener resumen de notificaciones: $e');
      return const NotificationSummary.empty();
    }
  }

  /// Obtiene lista detallada de notificaciones
  Future<List<AdminNotification>> getNotifications() async {
    try {
      final notifications = <AdminNotification>[];

      // 1. Obtener pedidos nuevos (últimas 24 horas)
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final newOrders = await _supabase
          .from('orders')
          .select('id, order_number, created_at, customer_name, total_price')
          .eq('status', 'paid')
          .gte('created_at', yesterday.toIso8601String())
          .order('created_at', ascending: false);

      for (var order in (newOrders as List)) {
        notifications.add(AdminNotification(
          id: 'order_${order['id']}',
          type: AdminNotificationType.newOrder,
          title: 'Nuevo pedido #${order['order_number'] ?? order['id'].toString().substring(0, 8)}',
          message: 'Pedido de ${order['customer_name'] ?? 'Cliente'} por €${(order['total_price'] as num).toStringAsFixed(2)}',
          createdAt: DateTime.parse(order['created_at']),
          data: {
            'orderId': order['id'],
            'orderNumber': order['order_number'],
            'totalPrice': order['total_price'],
          },
        ));
      }

      // 2. Obtener productos con stock bajo
      final lowStockProducts = await _supabase
          .from('product_variants')
          .select('''
            id, 
            stock, 
            size,
            product_id,
            products!inner(name, slug)
          ''')
          .lte('stock', 5)
          .gt('stock', 0)
          .order('stock', ascending: true)
          .limit(10);

      for (var variant in (lowStockProducts as List)) {
        final product = variant['products'];
        notifications.add(AdminNotification(
          id: 'stock_low_${variant['id']}',
          type: AdminNotificationType.lowStock,
          title: 'Stock bajo: ${product['name']}',
          message: 'Talla ${variant['size']}: Solo quedan ${variant['stock']} unidades',
          createdAt: DateTime.now(),
          data: {
            'productId': variant['product_id'],
            'productSlug': product['slug'],
            'productName': product['name'],
            'size': variant['size'],
            'stock': variant['stock'],
          },
        ));
      }

      // 3. Obtener productos agotados
      final outOfStockProducts = await _supabase
          .from('product_variants')
          .select('''
            id, 
            size,
            product_id,
            products!inner(name, slug)
          ''')
          .eq('stock', 0)
          .order('product_id', ascending: false)
          .limit(10);

      for (var variant in (outOfStockProducts as List)) {
        final product = variant['products'];
        notifications.add(AdminNotification(
          id: 'stock_out_${variant['id']}',
          type: AdminNotificationType.outOfStock,
          title: 'Agotado: ${product['name']}',
          message: 'Talla ${variant['size']}: Sin stock',
          createdAt: DateTime.now(),
          data: {
            'productId': variant['product_id'],
            'productSlug': product['slug'],
            'productName': product['name'],
            'size': variant['size'],
          },
        ));
      }

      // Ordenar por fecha (más reciente primero)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      print('Error al obtener notificaciones: $e');
      return [];
    }
  }

  /// Obtiene pedidos pendientes de envío
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('id, order_number, customer_name, total_price, created_at')
          .eq('status', 'paid')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error al obtener pedidos pendientes: $e');
      return [];
    }
  }

  /// Obtiene productos con stock crítico
  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    try {
      final response = await _supabase
          .from('product_variants')
          .select('''
            id,
            stock,
            size,
            product_id,
            products!inner(id, name, slug, price)
          ''')
          .lte('stock', 5)
          .order('stock', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error al obtener productos con stock bajo: $e');
      return [];
    }
  }
}
