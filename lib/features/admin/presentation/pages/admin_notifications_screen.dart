import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_notification_providers.dart';
import '../../data/models/admin_notification_model.dart';

/// Función helper para formatear tiempo relativo
String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'hace un momento';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return 'hace $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'hace $hours ${hours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return 'hace $days ${days == 1 ? 'día' : 'días'}';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return 'hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
  } else {
    final months = (difference.inDays / 30).floor();
    return 'hace $months ${months == 1 ? 'mes' : 'meses'}';
  }
}

/// Pantalla de notificaciones del admin
class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all, color: AppColors.neonCyan, size: 18),
            label: const Text(
              'Marcar todas',
              style: TextStyle(color: AppColors.neonCyan, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async {
          await ref.read(notificationsProvider.notifier).refresh();
        },
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar notificaciones',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(notificationsProvider.notifier).refresh();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.neonCyan.withValues(alpha: 0.1),
                            AppColors.neonPurple.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¡Todo al día!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tienes notificaciones pendientes',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onDismiss: () {
                    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AdminNotification notification) {
    // Marcar como leída
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);

    // Navegar según el tipo
    switch (notification.type) {
      case AdminNotificationType.newOrder:
      case AdminNotificationType.pendingOrders:
        final orderId = notification.data?['orderId'];
        if (orderId != null) {
          context.push('${AppRoutes.adminOrders}/$orderId');
        } else {
          context.push(AppRoutes.adminOrders);
        }
        break;
      
      case AdminNotificationType.lowStock:
      case AdminNotificationType.outOfStock:
        final productId = notification.data?['productId'];
        if (productId != null) {
          context.push('${AppRoutes.adminProducts}/$productId');
        } else {
          context.push(AppRoutes.adminProducts);
        }
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  Color _getTypeColor() {
    final colorString = notification.type.color;
    return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check, color: Colors.green),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF12121A)
                : const Color(0xFF1A1A24),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.white.withValues(alpha: 0.05)
                  : typeColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withValues(alpha: 0.2),
                      typeColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    notification.type.iconData,
                    color: typeColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: typeColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flecha
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
