import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/admin_notification_model.dart';
import '../../data/services/admin_notification_service.dart';

/// Provider del servicio de notificaciones
final adminNotificationServiceProvider = Provider<AdminNotificationService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminNotificationService(supabase);
});

/// Provider del resumen de notificaciones
final notificationSummaryProvider = StateNotifierProvider<NotificationSummaryNotifier, AsyncValue<NotificationSummary>>((ref) {
  return NotificationSummaryNotifier(ref);
});

/// Notifier para el resumen de notificaciones con auto-refresh
class NotificationSummaryNotifier extends StateNotifier<AsyncValue<NotificationSummary>> {
  final Ref _ref;
  Timer? _refreshTimer;
  
  NotificationSummaryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSummary();
    _startAutoRefresh();
  }

  /// Carga el resumen de notificaciones
  Future<void> _loadSummary() async {
    try {
      final service = _ref.read(adminNotificationServiceProvider);
      final summary = await service.getNotificationSummary();
      state = AsyncValue.data(summary);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Inicia el auto-refresh cada 30 segundos
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadSummary();
    });
  }

  /// Recarga manualmente
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSummary();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Provider de la lista de notificaciones
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AdminNotification>>>((ref) {
  return NotificationsNotifier(ref);
});

/// Notifier para la lista de notificaciones
class NotificationsNotifier extends StateNotifier<AsyncValue<List<AdminNotification>>> {
  final Ref _ref;
  
  NotificationsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  /// Carga las notificaciones
  Future<void> _loadNotifications() async {
    try {
      final service = _ref.read(adminNotificationServiceProvider);
      final notifications = await service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Recarga las notificaciones
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadNotifications();
    // También refrescar el resumen
    _ref.read(notificationSummaryProvider.notifier).refresh();
  }

  /// Marca una notificación como leída (solo localmente)
  void markAsRead(String notificationId) {
    final currentState = state;
    if (currentState is AsyncData<List<AdminNotification>>) {
      final notifications = currentState.value;
      final updatedNotifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      state = AsyncValue.data(updatedNotifications);
    }
  }

  /// Marca todas como leídas
  void markAllAsRead() {
    final currentState = state;
    if (currentState is AsyncData<List<AdminNotification>>) {
      final notifications = currentState.value;
      final updatedNotifications = notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      state = AsyncValue.data(updatedNotifications);
    }
  }
}

/// Provider para el contador de notificaciones sin leer
final unreadNotificationCountProvider = Provider<int>((ref) {
  final summaryAsync = ref.watch(notificationSummaryProvider);
  return summaryAsync.when(
    data: (summary) => summary.totalUnread,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para pedidos pendientes
final pendingOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminNotificationServiceProvider);
  return service.getPendingOrders();
});

/// Provider para productos con stock bajo
final lowStockProductsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(adminNotificationServiceProvider);
  return service.getLowStockProducts();
});
