// Modelo para notificaciones del admin
class AdminNotification {
  final String id;
  final AdminNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  AdminNotification copyWith({
    String? id,
    AdminNotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

// Tipos de notificaciones
enum AdminNotificationType {
  newOrder,     // Nuevo pedido
  lowStock,     // Stock bajo
  outOfStock,   // Sin stock
  pendingOrders // Pedidos pendientes
}

// Extensión para obtener datos visuales de cada tipo
extension AdminNotificationTypeExtension on AdminNotificationType {
  String get iconEmoji {
    switch (this) {
      case AdminNotificationType.newOrder:
        return '🛒';
      case AdminNotificationType.lowStock:
        return '⚠️';
      case AdminNotificationType.outOfStock:
        return '🚫';
      case AdminNotificationType.pendingOrders:
        return '📦';
    }
  }

  String get color {
    switch (this) {
      case AdminNotificationType.newOrder:
        return '#06b6d4'; // cyan
      case AdminNotificationType.lowStock:
        return '#f59e0b'; // amber
      case AdminNotificationType.outOfStock:
        return '#ef4444'; // red
      case AdminNotificationType.pendingOrders:
        return '#d946ef'; // fuchsia
    }
  }
}

// Modelo para resumen de notificaciones
class NotificationSummary {
  final int newOrdersCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int pendingOrdersCount;
  final int totalUnread;

  const NotificationSummary({
    required this.newOrdersCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.pendingOrdersCount,
    required this.totalUnread,
  });

  const NotificationSummary.empty()
      : newOrdersCount = 0,
        lowStockCount = 0,
        outOfStockCount = 0,
        pendingOrdersCount = 0,
        totalUnread = 0;

  NotificationSummary copyWith({
    int? newOrdersCount,
    int? lowStockCount,
    int? outOfStockCount,
    int? pendingOrdersCount,
    int? totalUnread,
  }) {
    return NotificationSummary(
      newOrdersCount: newOrdersCount ?? this.newOrdersCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      pendingOrdersCount: pendingOrdersCount ?? this.pendingOrdersCount,
      totalUnread: totalUnread ?? this.totalUnread,
    );
  }
}
