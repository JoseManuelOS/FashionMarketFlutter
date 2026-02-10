import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/router/app_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../providers/admin_notification_providers.dart';

/// Widget para el icono de notificaciones con badge en el AppBar del admin
class AdminNotificationButton extends ConsumerWidget {
  const AdminNotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 26,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.neonFuchsia,
                      AppColors.neonPurple,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonFuchsia.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        context.push(AppRoutes.adminNotifications);
      },
      tooltip: unreadCount > 0
          ? '$unreadCount notificación${unreadCount == 1 ? '' : 'es'} sin leer'
          : 'Notificaciones',
    );
  }
}

/// Widget compacto para mostrar resumen de notificaciones
class AdminNotificationSummaryCard extends ConsumerWidget {
  const AdminNotificationSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(notificationSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final s = summary; // Variable local non-null
        if (s.totalUnread == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            border: Border.all(
              color: AppColors.neonFuchsia.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.neonFuchsia,
                          AppColors.neonPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notificaciones Pendientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${s.totalUnread} asunto${s.totalUnread == 1 ? '' : 's'} requiere${s.totalUnread == 1 ? '' : 'n'} tu atención',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (s.newOrdersCount > 0)
                    _NotificationBadge(
                      icon: '🛒',
                      count: s.newOrdersCount,
                      label: 'Pedidos nuevos',
                      color: AppColors.neonCyan,
                    ),
                  if (s.pendingOrdersCount > 0)
                    _NotificationBadge(
                      icon: '📦',
                      count: s.pendingOrdersCount,
                      label: 'Por enviar',
                      color: AppColors.neonPurple,
                    ),
                  if (s.lowStockCount > 0)
                    _NotificationBadge(
                      icon: '⚠️',
                      count: s.lowStockCount,
                      label: 'Stock bajo',
                      color: Colors.amber,
                    ),
                  if (s.outOfStockCount > 0)
                    _NotificationBadge(
                      icon: '🚫',
                      count: s.outOfStockCount,
                      label: 'Agotados',
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final String icon;
  final int count;
  final String label;
  final Color color;

  const _NotificationBadge({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
