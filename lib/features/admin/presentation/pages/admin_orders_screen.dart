import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

/// Datos de transportistas con sus URLs de seguimiento
class _CarrierInfo {
  final String id;
  final String name;
  final String trackingBase;

  const _CarrierInfo({
    required this.id,
    required this.name,
    required this.trackingBase,
  });
}

const _carriers = [
  _CarrierInfo(id: 'seur', name: 'SEUR', trackingBase: 'https://www.seur.com/livetracking/?segOnlineIdentificador='),
  _CarrierInfo(id: 'mrw', name: 'MRW', trackingBase: 'https://www.mrw.es/seguimiento_envios/'),
  _CarrierInfo(id: 'correos', name: 'Correos', trackingBase: 'https://www.correos.es/es/es/herramientas/localizador/envios/'),
  _CarrierInfo(id: 'gls', name: 'GLS', trackingBase: 'https://www.gls-spain.es/es/ayuda/seguimiento-envio/?match='),
  _CarrierInfo(id: 'ups', name: 'UPS', trackingBase: 'https://www.ups.com/track?tracknum='),
  _CarrierInfo(id: 'dhl', name: 'DHL', trackingBase: 'https://www.dhl.com/es-es/home/tracking.html?tracking-id='),
  _CarrierInfo(id: 'envialia', name: 'Envialia', trackingBase: 'https://www.envialia.com/es/tracking/?id='),
  _CarrierInfo(id: 'nacex', name: 'Nacex', trackingBase: 'https://www.nacex.es/seguimiento-envios/?id='),
  _CarrierInfo(id: 'fedex', name: 'FedEx', trackingBase: 'https://www.fedex.com/fedextrack/?trknbr='),
  _CarrierInfo(id: 'otro', name: 'Otro', trackingBase: ''),
];

/// Pantalla de gestión de pedidos (Admin)
class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String? _selectedStatus;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// Todos los valores posibles de filtro para invalidar la cache completa
  static const _allStatusFilters = <String?>[
    null, 'paid', 'shipped', 'delivered',
    'return_requested', 'returned', 'partial_return', 'return_rejected', 'cancelled',
  ];

  /// Invalida TODAS las variantes cacheadas (Todos + cada filtro).
  /// Soluciona que cambiar el estado de un pedido solo actualizaba la
  /// pestaña activa y las demás mostraban datos obsoletos.
  void _invalidateAllOrders() {
    for (final status in _allStatusFilters) {
      ref.invalidate(adminOrdersProvider(status));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    if (_searchQuery.isEmpty) return orders;
    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      final orderId = (order['id']?.toString() ?? '').toLowerCase();
      final customerName = (order['customer_name'] as String? ?? '').toLowerCase();
      final customerEmail = (order['customer_email'] as String? ?? '').toLowerCase();
      final orderNumber = (order['order_number'] as String? ?? '').toLowerCase();
      return orderId.contains(query) || 
             customerName.contains(query) || 
             customerEmail.contains(query) ||
             orderNumber.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final ordersAsync = ref.watch(adminOrdersProvider(_selectedStatus));

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminOrders),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Pedidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          const AdminNotificationButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D14),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nº pedido, cliente...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF12121A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          // Filtros
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D14),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Por enviar', 'paid'),       // Pagados, pendientes de envío
                  const SizedBox(width: 8),
                  _buildFilterChip('Enviados', 'shipped'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Entregados', 'delivered'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Devoluciones', 'return_requested'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Devueltos', 'returned'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dev. parcial', 'partial_return'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dev. rechazada', 'return_rejected'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelados', 'cancelled'),
                ],
              ),
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              ),
              error: (e, stack) {
                print('Error cargando pedidos: $e');
                print('Stack: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar pedidos',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          e.toString(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _invalidateAllOrders(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              },
              data: (orders) {
                final filteredOrders = _filterOrders(orders);
                
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, color: Colors.grey[600], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pedidos',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.grey[600], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron pedidos',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prueba con otra búsqueda',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.neonCyan,
                  backgroundColor: const Color(0xFF12121A),
                  onRefresh: () async {
                    _invalidateAllOrders();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOrderCard(filteredOrders[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: const Color(0xFF12121A),
      selectedColor: AppColors.neonCyan.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.neonCyan : Colors.grey[400],
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.neonCyan : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String? ?? 'pending';
    final statusInfo = _getStatusInfo(status);
    final items = order['items'] as List? ?? [];
    final createdAt = DateTime.tryParse(order['created_at'] ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order['order_number'] ?? order['id']?.toString().substring(0, 8) ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusInfo['color'].withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusInfo['icon'], color: statusInfo['color'], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      statusInfo['label'],
                      style: TextStyle(
                        color: statusInfo['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cliente info
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey[500], size: 16),
              const SizedBox(width: 8),
              Text(
                order['customer_name'] ?? order['customer_email'] ?? 'Cliente',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ],
          ),

          if (order['shipping_address'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[500], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['shipping_address'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Items preview
          if (items.isNotEmpty) ...[
            Text(
              '${items.length} producto${items.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Total y acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: €${(order['total_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (status == 'paid')
                    _buildActionButton(
                      icon: Icons.local_shipping_outlined,
                      color: Colors.blue,
                      onTap: () => _showOrderDetails(order),
                    ),
                  if (status == 'shipped')
                    _buildActionButton(
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      onTap: () => _updateOrderStatus(order['id'], 'delivered'),
                    ),
                  if (status == 'return_requested')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildActionButton(
                        icon: Icons.cancel_outlined,
                        color: Colors.red,
                        onTap: () => _showRejectReturnDialog(order),
                      ),
                    ),
                  if (status == 'return_requested')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildActionButton(
                        icon: Icons.assignment_return_outlined,
                        color: Colors.teal,
                        onTap: () => _showPartialReturnDialog(order),
                      ),
                    ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.visibility_outlined,
                    color: Colors.grey,
                    onTap: () => _showOrderDetails(order),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': 'Pago pendiente',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'paid':
        return {
          'label': 'Por enviar',
          'color': Colors.blue,
          'icon': Icons.inventory_2,
        };
      case 'shipped':
        return {
          'label': 'Enviado',
          'color': Colors.purple,
          'icon': Icons.local_shipping,
        };
      case 'delivered':
        return {
          'label': 'Entregado',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'cancelled':
        return {
          'label': 'Cancelado',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 'return_requested':
        return {
          'label': 'Devolución solicitada',
          'color': Colors.amber,
          'icon': Icons.assignment_return,
        };
      case 'returned':
        return {
          'label': 'Devuelto',
          'color': Colors.deepOrange,
          'icon': Icons.assignment_returned,
        };
      case 'partial_return':
        return {
          'label': 'Devolución parcial',
          'color': Colors.teal,
          'icon': Icons.assignment_return_outlined,
        };
      case 'return_rejected':
        return {
          'label': 'Devolución rechazada',
          'color': Colors.red,
          'icon': Icons.block,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(dynamic orderId, String newStatus) async {
    try {
      final admin = ref.read(adminSessionProvider);

      // ── Cancelar pedido vía API (reembolso + email automático) ──
      if (newStatus == 'cancelled' && admin != null) {
        final result = await FashionStoreApiService.adminCancelOrder(
          orderId: orderId.toString(),
          adminEmail: admin.email,
        );
        if (result['success'] != true) {
          throw Exception(result['error'] ?? 'Error al cancelar');
        }
        // Persistir motivo de cancelación (FashionStore no lo guarda)
        try {
          final supabase = ref.read(supabaseProvider);
          await supabase
              .from('orders')
              .update({'cancellation_reason': 'Cancelado por el administrador'})
              .eq('id', orderId);
        } catch (_) {}
        _invalidateAllOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido cancelado - Reembolso y email enviados'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // ── Aceptar devolución vía API (reembolso + email automático) ──
      if (newStatus == 'returned' && admin != null) {
        try {
          final result = await FashionStoreApiService.acceptReturn(
            orderId: orderId.toString(),
            adminEmail: admin.email,
          );
          if (result['success'] != true) {
            throw Exception(result['error'] ?? 'Error al aceptar devolución');
          }
          _invalidateAllOrders();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Devolución aceptada - Reembolso y email enviados'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Si falla la API, al menos actualizar estado via RPC
          debugPrint('Error en API accept-return: $e — Actualizando estado via RPC');
          final supabase = ref.read(supabaseProvider);
          await supabase.rpc(
            'admin_update_order_status',
            params: {
              'p_admin_email': admin.email,
              'p_order_id': orderId.toString(),
              'p_new_status': 'returned',
            },
          );
          _invalidateAllOrders();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Devolución aceptada (estado actualizado). Email no enviado: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        return;
      }

      // ── Otros cambios de estado via RPC (bypasa RLS) ──
      final supabase = ref.read(supabaseProvider);
      final adminEmail = admin?.email ?? '';
      await supabase.rpc(
        'admin_update_order_status',
        params: {
          'p_admin_email': adminEmail,
          'p_order_id': orderId.toString(),
          'p_new_status': newStatus,
        },
      );

      // ── Enviar email de entrega al cliente ──
      if (newStatus == 'delivered') {
        try {
          // Usar RPC para obtener datos del pedido (bypasa RLS)
          final ordersJson = await supabase.rpc(
            'admin_get_orders',
            params: {
              'p_admin_email': admin?.email ?? '',
              'p_status': null,
            },
          );
          final ordersList = ordersJson as List? ?? [];
          final orderData = ordersList.cast<Map<String, dynamic>>().firstWhere(
            (o) => o['id'].toString() == orderId.toString(),
            orElse: () => <String, dynamic>{},
          );

          if (orderData.isNotEmpty) {
            final customerEmail = orderData['customer_email'] as String?;
            final customerName = orderData['customer_name'] as String? ?? 'Cliente';
            final orderNumber = orderData['order_number'];
            final orderRef = orderNumber != null 
                ? orderNumber.toString() 
                : orderId.toString().substring(0, 8).toUpperCase();
            final total = (orderData['total_price'] ?? 0).toDouble();
            final items = (orderData['items'] as List?)?.map((item) => {
              'product_name': item['product_name'] ?? '',
              'size': item['size'] ?? '',
              'quantity': item['quantity'] ?? 1,
              'price_at_purchase': (item['price_at_purchase'] ?? 0).toDouble(),
              'product_image': item['product_image'] ?? '',
            }).toList();

            if (customerEmail != null) {
              await FashionStoreApiService.sendOrderDelivered(
                to: customerEmail,
                customerName: customerName,
                orderRef: orderRef,
                orderItems: items,
                totalPrice: total,
                adminEmail: adminEmail,
              );
            }
          }
        } catch (_) {
          // No bloquear la actualización si falla el email
        }
      }

      _invalidateAllOrders();

      if (mounted) {
        final statusLabel = _getStatusInfo(newStatus)['label'];
        final emailSent = newStatus == 'delivered' ? ' - Email enviado al cliente' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a $statusLabel$emailSent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Actualizar información de envío del pedido
  Future<void> _updateOrderShipping({
    required dynamic orderId,
    required String? shippingCarrier,
    required String? trackingNumber,
    required String? trackingUrl,
    required bool markAsShipped,
    String? newStatus,
  }) async {
    try {
      final admin = ref.read(adminSessionProvider);
      final supabase = ref.read(supabaseProvider);

      // Determinar el estado final
      String? effectiveStatus = newStatus;
      if (effectiveStatus == null && markAsShipped) {
        effectiveStatus = 'shipped';
      }

      // Usar RPC admin_update_order_status que tiene SECURITY DEFINER (bypasa RLS)
      // Este RPC también gestiona shipped_at, delivered_at, shipping_carrier, tracking*, etc.
      await supabase.rpc(
        'admin_update_order_status',
        params: {
          'p_admin_email': admin?.email ?? '',
          'p_order_id': orderId.toString(),
          'p_new_status': effectiveStatus,
          'p_shipping_carrier': shippingCarrier,
          'p_tracking_number': trackingNumber,
          'p_tracking_url': trackingUrl,
        },
      );

      // ── Enviar email de entrega al cliente si se marca como entregado ──
      if (effectiveStatus == 'delivered') {
        try {
          // Usar RPC para obtener datos del pedido (bypasa RLS)
          final ordersJson = await supabase.rpc(
            'admin_get_orders',
            params: {
              'p_admin_email': admin?.email ?? '',
              'p_status': null,
            },
          );
          final ordersList = ordersJson as List? ?? [];
          final orderData = ordersList.cast<Map<String, dynamic>>().firstWhere(
            (o) => o['id'].toString() == orderId.toString(),
            orElse: () => <String, dynamic>{},
          );

          if (orderData.isNotEmpty) {
            final customerEmail = orderData['customer_email'] as String?;
            final customerName = orderData['customer_name'] as String? ?? 'Cliente';
            final orderNumber = orderData['order_number'];
            final orderRef = orderNumber != null
                ? orderNumber.toString()
                : orderId.toString().substring(0, 8).toUpperCase();
            final total = (orderData['total_price'] ?? 0).toDouble();
            final items = (orderData['items'] as List?)?.map((item) => {
              'product_name': item['product_name'] ?? '',
              'size': item['size'] ?? '',
              'quantity': item['quantity'] ?? 1,
              'price_at_purchase': (item['price_at_purchase'] ?? 0).toDouble(),
              'product_image': item['product_image'] ?? '',
            }).toList();

            if (customerEmail != null) {
              await FashionStoreApiService.sendOrderDelivered(
                to: customerEmail,
                customerName: customerName,
                orderRef: orderRef,
                orderItems: items,
                totalPrice: total,
                adminEmail: admin?.email,
              );
            }
          }
        } catch (_) {
          // No bloquear la actualización si falla el email
        }
      }

      // ── Enviar email de actualización de envío al cliente ──
      final isShipped = effectiveStatus == 'shipped';
      if (isShipped && trackingNumber != null && trackingNumber.isNotEmpty) {
        try {
          // Usar RPC para obtener datos del pedido (bypasa RLS)
          final ordersJson = await supabase.rpc(
            'admin_get_orders',
            params: {
              'p_admin_email': admin?.email ?? '',
              'p_status': null,
            },
          );
          final ordersList = ordersJson as List? ?? [];
          final orderData = ordersList.cast<Map<String, dynamic>>().firstWhere(
            (o) => o['id'].toString() == orderId.toString(),
            orElse: () => <String, dynamic>{},
          );

          final customerEmail = orderData['customer_email'] as String?;
          if (customerEmail != null) {
            await FashionStoreApiService.sendShippingUpdate(
              to: customerEmail,
              customerName: orderData['customer_name'] as String? ?? 'Cliente',
              orderId: orderId.toString(),
              trackingNumber: trackingNumber,
              trackingUrl: trackingUrl,
              carrierName: shippingCarrier,
              orderNumber: orderData['order_number'] as int?,
              adminEmail: admin?.email,
            );
          }
        } catch (_) {
          // No bloquear la actualización si falla el email
        }
      }

      _invalidateAllOrders();

      if (mounted) {
        final statusLabel = effectiveStatus != null ? _getStatusInfo(effectiveStatus)['label'] : null;
        final statusMsg = statusLabel != null ? 'Estado: $statusLabel. ' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${statusMsg}Datos de envío actualizados',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Parsear la razón estructurada del cliente para extraer items y cantidades.
  /// Formato esperado:
  /// [Articulos solicitados]
  /// - NombreProducto (Talla X)
  /// - NombreProducto (Talla X) (2 de 3 uds)
  /// [Motivo]
  /// texto libre
  Map<String, int>? _parseClientReturnItems(
    String? returnReason,
    List<Map<String, dynamic>> orderItems,
  ) {
    if (returnReason == null || !returnReason.contains('[Articulos solicitados]')) return null;

    final itemsSection = returnReason.split('[Motivo]').first;
    final lines = itemsSection.split('\n').where((l) => l.trim().startsWith('- ')).toList();

    final result = <String, int>{};
    for (final line in lines) {
      final text = line.trim().substring(2); // Quitar "- "
      // Intentar extraer nombre y talla (la talla puede tener espacios, ej: "TALLA ÚNICA")
      final tallaMatch = RegExp(r'^(.+?)\s*\(Talla\s+(.+?)\)').firstMatch(text);
      if (tallaMatch == null) continue;
      final name = tallaMatch.group(1)!.trim();
      final size = tallaMatch.group(2)!.trim();
      // Intentar extraer cantidad parcial "(X de Y uds)"
      final qtyMatch = RegExp(r'\((\d+)\s+de\s+\d+\s+uds?\)').firstMatch(text);

      // Buscar el item correspondiente por nombre + talla
      for (final item in orderItems) {
        final itemName = (item['product_name'] as String? ?? '').trim();
        final itemSize = (item['size'] as String? ?? '').trim();
        if (itemName == name && itemSize == size) {
          final qty = qtyMatch != null ? int.parse(qtyMatch.group(1)!) : (item['quantity'] as int? ?? 1);
          result[item['id'].toString()] = qty;
          break;
        }
      }
    }
    return result.isEmpty ? null : result;
  }

  /// Diálogo de devolución — si el cliente la solicitó los items vienen pre-seleccionados y son de solo lectura
  void _showPartialReturnDialog(Map<String, dynamic> order) async {
    final admin = ref.read(adminSessionProvider);
    final supabase = ref.read(supabaseProvider);
    final orderId = order['id'];

    // Obtener items del pedido con devoluciones previas
    List<Map<String, dynamic>> items;
    try {
      final result = await supabase.rpc(
        'admin_get_order_items',
        params: {
          'p_admin_email': admin?.email ?? '',
          'p_order_id': orderId.toString(),
        },
      );
      items = (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener items: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay items en este pedido'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    // Map: order_item_id → cantidad a devolver
    final Map<String, int> returnQuantities = {};

    // Pre-seleccionar los items que el cliente solicitó devolver
    final clientParsed = _parseClientReturnItems(
      order['return_reason'] as String?,
      items,
    );
    if (clientParsed != null) {
      // Items del cliente parseados correctamente
      returnQuantities.addAll(clientParsed);
    } else {
      // Formato legacy (sin [Articulos solicitados]): seleccionar todos
      for (final item in items) {
        final itemId = item['id'].toString();
        final qty = item['quantity'] as int;
        final alreadyReturned = (item['already_returned'] as num?)?.toInt() ?? 0;
        final available = qty - alreadyReturned;
        if (available > 0) returnQuantities[itemId] = available;
      }
    }

    bool isProcessing = false;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          // Calcular total de reembolso
          double refundTotal = 0;
          for (final entry in returnQuantities.entries) {
            final item = items.firstWhere((i) => i['id'].toString() == entry.key);
            refundTotal += (item['price_at_purchase'] as num).toDouble() * entry.value;
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_return,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solicitud del cliente — Pedido #${order['order_number'] ?? orderId}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'El cliente seleccionó los artículos a devolver. No se pueden modificar.',
                                  style: TextStyle(color: Colors.amber, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Nota envío
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[300], size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'El coste de envío no se reembolsa en ninguna devolución.',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Items — solo los que el cliente solicitó devolver
                    ...items.where((item) => returnQuantities.containsKey(item['id'].toString())).map((item) {
                      final itemId = item['id'].toString();
                      final qty = item['quantity'] as int;
                      final alreadyReturned = (item['already_returned'] as num?)?.toInt() ?? 0;
                      final available = qty - alreadyReturned;
                      final currentReturn = returnQuantities[itemId] ?? 0;
                      final price = (item['price_at_purchase'] as num).toDouble();
                      final colorName = item['color'] as String?;
                      final size = item['size'] as String? ?? 'N/A';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentReturn > 0
                              ? Colors.teal.withValues(alpha: 0.08)
                              : const Color(0xFF0D0D14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: currentReturn > 0
                                ? Colors.teal.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Image
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: item['product_image'] != null
                                      ? Image.network(item['product_image'], fit: BoxFit.cover)
                                      : const Icon(Icons.image, color: Colors.grey, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name'] ?? 'Producto',
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Talla: $size${colorName != null ? ' · $colorName' : ''} · €${price.toStringAsFixed(2)}/ud',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                      if (alreadyReturned > 0)
                                        Text(
                                          'Ya devuelto: $alreadyReturned de $qty',
                                          style: const TextStyle(color: Colors.orange, fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (available > 0) ...[
                              const SizedBox(height: 10),
                              // Solo lectura: mostrar cantidad solicitada por el cliente
                                Row(
                                  children: [
                                    Text(
                                      'Devolver:',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: currentReturn > 0
                                            ? Colors.amber.withValues(alpha: 0.12)
                                            : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: currentReturn > 0
                                              ? Colors.amber.withValues(alpha: 0.3)
                                              : Colors.grey.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Text(
                                        currentReturn > 0 ? '$currentReturn ud${currentReturn > 1 ? 's' : ''}' : 'No solicitado',
                                        style: TextStyle(
                                          color: currentReturn > 0 ? Colors.amber : Colors.grey[600],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (currentReturn > 0 && available > currentReturn)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          'de $available disponibles',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                        ),
                                      ),
                                    const Spacer(),
                                    if (currentReturn > 0)
                                      Text(
                                        '€${(price * currentReturn).toStringAsFixed(2)}',
                                        style: const TextStyle(color: Colors.teal, fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                  ],
                                ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Todas las unidades ya devueltas',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Motivo del cliente (solo lectura)
                    if (order['return_reason'] != null && (order['return_reason'] as String).isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote, color: Colors.amber[300], size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Motivo del cliente',
                                  style: TextStyle(color: Colors.amber[300], fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order['return_reason'] as String,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Resumen de reembolso
                    if (returnQuantities.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items a devolver:', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                Text(
                                  '${returnQuantities.values.fold(0, (a, b) => a + b)} uds',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Reembolso envío:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                const Text('€0.00', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            const Divider(color: Colors.grey, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total a reembolsar:', style: TextStyle(color: Colors.teal, fontSize: 15, fontWeight: FontWeight.w600)),
                                Text(
                                  '€${refundTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Botón procesar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: returnQuantities.isEmpty || isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                try {
                                  final itemsData = returnQuantities.entries
                                      .where((e) => e.value > 0)
                                      .map((e) => {
                                            'order_item_id': e.key,
                                            'quantity_to_return': e.value,
                                          })
                                      .toList();

                                  // Detectar si es devolucion completa
                                  bool isFullReturn = true;
                                  for (final item in items) {
                                    final itemId = item['id'].toString();
                                    final qty = item['quantity'] as int;
                                    final alreadyReturned = (item['already_returned'] as num?)?.toInt() ?? 0;
                                    final available = qty - alreadyReturned;
                                    final returning = returnQuantities[itemId] ?? 0;
                                    if (returning < available) {
                                      isFullReturn = false;
                                      break;
                                    }
                                  }

                                  String resultMsg = '';

                                  if (isFullReturn) {
                                    // Devolucion completa desde return_requested:
                                    // 1) Llamar a FashionStore PRIMERO (status aun es return_requested)
                                    //    Esto hace: Stripe refund, factura rectificativa, email con PDFs, status->returned, stock
                                    try {
                                      final apiResult = await FashionStoreApiService.acceptReturn(
                                        orderId: orderId.toString(),
                                        adminEmail: admin?.email ?? '',
                                      );
                                      resultMsg = apiResult['message'] as String? ?? 'Devolucion aceptada';
                                    } catch (e) {
                                      // Si falla la API, procesar via RPC como fallback
                                      debugPrint('Error en accept-return API: $e - Usando RPC como fallback');
                                      final rpcResult = await supabase.rpc(
                                        'admin_process_partial_return',
                                        params: {
                                          'p_admin_email': admin?.email ?? '',
                                          'p_data': {
                                            'order_id': orderId.toString(),
                                            'reason': order['return_reason'],
                                            'items': itemsData,
                                          },
                                        },
                                      );
                                      resultMsg = '${rpcResult?['message'] ?? 'Devolucion procesada'} (email no enviado)';
                                    }
                                  } else {
                                    // Devolucion parcial: RPC + factura rectificativa + email
                                    final rpcResult = await supabase.rpc(
                                      'admin_process_partial_return',
                                      params: {
                                        'p_admin_email': admin?.email ?? '',
                                        'p_data': {
                                          'order_id': orderId.toString(),
                                          'reason': order['return_reason'],
                                          'items': itemsData,
                                        },
                                      },
                                    );
                                    resultMsg = rpcResult?['message'] ?? 'Devolucion parcial procesada';

                                    // Obtener importe de reembolso del RPC
                                    final refundAmount = (rpcResult?['refund_amount'] as num?)?.toDouble() ?? 0;

                                    // Construir lista de items devueltos con detalles para factura rectificativa + email
                                    final returnedItemsForRelay = returnQuantities.entries
                                        .where((e) => e.value > 0)
                                        .map((e) {
                                          final item = items.firstWhere((i) => i['id'].toString() == e.key);
                                          return {
                                            'product_name': item['product_name'] ?? 'Producto',
                                            'size': item['size'],
                                            'color': item['color'],
                                            'quantity': e.value,
                                            'price': (item['price_at_purchase'] as num).toDouble(),
                                          };
                                        })
                                        .toList();

                                    // Crear factura rectificativa + enviar email via relay
                                    if (refundAmount > 0) {
                                      try {
                                        final relayResult = await FashionStoreApiService.acceptPartialReturn(
                                          orderId: orderId.toString(),
                                          adminEmail: admin?.email ?? '',
                                          customerEmail: order['customer_email'] as String? ?? '',
                                          customerName: order['customer_name'] as String? ?? '',
                                          orderNumber: order['order_number'] as int?,
                                          returnedItems: returnedItemsForRelay,
                                          refundAmount: refundAmount,
                                        );

                                        final emailSent = relayResult['email_sent'] == true;
                                        final creditNote = relayResult['credit_note'] as String?;
                                        final warning = relayResult['warning'] as String?;

                                        if (creditNote != null) {
                                          resultMsg = '$resultMsg\nFactura rectificativa: $creditNote';
                                        }
                                        if (emailSent) {
                                          resultMsg = '$resultMsg\nEmail enviado al cliente';
                                        } else if (warning != null) {
                                          resultMsg = '$resultMsg\nAviso: $warning';
                                        }
                                      } catch (e) {
                                        debugPrint('Error en factura rectificativa/email parcial: $e');
                                        resultMsg = '$resultMsg\nFactura rectificativa/email no procesados';
                                      }
                                    }
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  _invalidateAllOrders();
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text(resultMsg),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() => isProcessing = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        icon: isProcessing
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(isProcessing ? 'Procesando...' : 'Procesar devolución'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    // Botón rechazar devolución (solo cuando el cliente la solicitó)
                    // Botón rechazar devolución (siempre visible, items vienen del cliente)
                    ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _showRejectReturnDialog(order);
                                },
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Rechazar devolucion'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Diálogo para rechazar una devolución solicitada por el cliente
  void _showRejectReturnDialog(Map<String, dynamic> order) {
    final reasonCtrl = TextEditingController();
    bool isRejecting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text('Rechazar devolucion',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${order['order_number'] ?? order['id']?.toString().substring(0, 8)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente: ${order['customer_name'] ?? order['customer_email'] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Motivo del cliente (si existe)
                if (order['return_reason'] != null && (order['return_reason'] as String).isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solicitud del cliente:', style: TextStyle(color: Colors.amber[300], fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          order['return_reason'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Motivo del rechazo (se enviara por email al cliente):',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Explica el motivo del rechazo...',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    filled: true,
                    fillColor: const Color(0xFF12121A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isRejecting ? null : () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[500])),
            ),
            ElevatedButton.icon(
              onPressed: isRejecting
                  ? null
                  : () async {
                      if (reasonCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Debes indicar un motivo'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      setDialogState(() => isRejecting = true);
                      await _rejectReturn(order, reasonCtrl.text.trim());
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              icon: isRejecting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cancel_outlined, size: 16),
              label: Text(isRejecting ? 'Rechazando...' : 'Rechazar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ejecuta el rechazo: actualiza estado a delivered + envía email de rechazo
  Future<void> _rejectReturn(Map<String, dynamic> order, String reason) async {
    try {
      final admin = ref.read(adminSessionProvider);
      final supabase = ref.read(supabaseProvider);
      final orderId = order['id'];

      // 1. Actualizar estado a 'return_rejected' via RPC
      await supabase.rpc(
        'admin_update_order_status',
        params: {
          'p_admin_email': admin?.email ?? '',
          'p_order_id': orderId.toString(),
          'p_new_status': 'return_rejected',
        },
      );

      // 2. Enviar email de rechazo al cliente
      bool emailSent = false;
      String emailWarning = '';
      try {
        final emailResult = await FashionStoreApiService.rejectReturn(
          orderId: orderId.toString(),
          adminEmail: admin?.email ?? '',
          reason: reason,
          customerEmail: order['customer_email'] as String?,
          customerName: order['customer_name'] as String?,
          orderNumber: order['order_number'] as int?,
          returnReason: order['return_reason'] as String?,
        );
        debugPrint('Resultado email rechazo: $emailResult');
        if (emailResult['success'] == true && emailResult['warning'] == null) {
          emailSent = true;
        } else if (emailResult['warning'] != null) {
          emailWarning = emailResult['warning'].toString();
          debugPrint('Warning email rechazo: $emailWarning');
        } else if (emailResult['error'] != null) {
          emailWarning = emailResult['error'].toString();
          debugPrint('Error email rechazo: $emailWarning');
        }
      } catch (e) {
        emailWarning = e.toString();
        debugPrint('Error enviando email de rechazo: $e');
      }

      _invalidateAllOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(emailSent
                ? 'Devolucion rechazada - Email enviado al cliente'
                : 'Devolucion rechazada - Email NO enviado${emailWarning.isNotEmpty ? ': $emailWarning' : ''}'),
            backgroundColor: emailSent ? Colors.green : Colors.orange,
            duration: Duration(seconds: emailSent ? 3 : 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OrderDetailSheet(
        order: order,
        onUpdateStatus: (orderId, status) {
          Navigator.of(context).pop();
          _updateOrderStatus(orderId, status);
        },
        onRejectReturn: () {
          Navigator.of(context).pop();
          _showRejectReturnDialog(order);
        },
        onUpdateShipping: ({
          required dynamic orderId,
          required String? shippingCarrier,
          required String? trackingNumber,
          required String? trackingUrl,
          required bool markAsShipped,
          String? newStatus,
        }) {
          Navigator.of(context).pop();
          _updateOrderShipping(
            orderId: orderId,
            shippingCarrier: shippingCarrier,
            trackingNumber: trackingNumber,
            trackingUrl: trackingUrl,
            markAsShipped: markAsShipped,
            newStatus: newStatus,
          );
        },
        getStatusInfo: _getStatusInfo,
      ),
    );
  }
}

/// Sheet de detalle de pedido con gestión de envío
class _OrderDetailSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final void Function(dynamic orderId, String status) onUpdateStatus;
  final VoidCallback onRejectReturn;
  final void Function({
    required dynamic orderId,
    required String? shippingCarrier,
    required String? trackingNumber,
    required String? trackingUrl,
    required bool markAsShipped,
    String? newStatus,
  }) onUpdateShipping;
  final Map<String, dynamic> Function(String) getStatusInfo;

  const _OrderDetailSheet({
    required this.order,
    required this.onUpdateStatus,
    required this.onRejectReturn,
    required this.onUpdateShipping,
    required this.getStatusInfo,
  });

  @override
  State<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<_OrderDetailSheet> {
  late String? _selectedCarrier;
  late final TextEditingController _trackingController;
  late final TextEditingController _trackingUrlController;
  late String _selectedStatus;
  bool _markAsShipped = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status'] as String? ?? 'pending';
    _selectedCarrier = widget.order['shipping_carrier'] as String?;
    _trackingController = TextEditingController(
      text: widget.order['tracking_number'] as String? ?? '',
    );
    _trackingUrlController = TextEditingController(
      text: widget.order['tracking_url'] as String? ?? '',
    );
    _trackingController.addListener(_autoGenerateUrl);
  }

  @override
  void dispose() {
    _trackingController.removeListener(_autoGenerateUrl);
    _trackingController.dispose();
    _trackingUrlController.dispose();
    super.dispose();
  }

  void _autoGenerateUrl() {
    if (_selectedCarrier == null) return;
    final carrier = _carriers.where((c) => c.id == _selectedCarrier).firstOrNull;
    if (carrier == null || carrier.trackingBase.isEmpty) return;
    final trackingNumber = _trackingController.text.trim();
    if (trackingNumber.isNotEmpty) {
      _trackingUrlController.text = '${carrier.trackingBase}$trackingNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final items = widget.order['items'] as List? ?? [];
        final status = _selectedStatus;
        final statusInfo = widget.getStatusInfo(status);
        final hasTracking = (widget.order['tracking_number'] as String?)?.isNotEmpty == true;

        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pedido #${widget.order['order_number'] ?? widget.order['id']?.toString().substring(0, 8)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (statusInfo['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo['label'] as String,
                      style: TextStyle(
                        color: statusInfo['color'] as Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // === Barra de progreso del pedido ===
              _buildProgressBar(status),

              const SizedBox(height: 24),

              // === Cambiar estado ===
              _buildStatusSection(status),

              const SizedBox(height: 24),

              // === Sección de Envío (oculta si está cancelado/devuelto) ===
              if (!const {'cancelled', 'returned'}.contains(status)) ...[
                _buildShippingSection(status, hasTracking),
                const SizedBox(height: 24),
              ],

              // === Cliente ===
              _buildSectionTitle('Cliente'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person_outline, widget.order['customer_name'] ?? 'N/A'),
              _buildInfoRow(Icons.email_outlined, widget.order['customer_email'] ?? 'N/A'),
              if (widget.order['shipping_address'] != null)
                _buildInfoRow(Icons.location_on_outlined, widget.order['shipping_address']),

              const SizedBox(height: 24),

              // === Productos ===
              _buildSectionTitle('Productos'),
              const SizedBox(height: 12),
              ...items.map((item) => _buildProductItem(item)),

              const Divider(color: Colors.grey, height: 32),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '€${(widget.order['total_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Barra de progreso visual del pedido
  Widget _buildProgressBar(String status) {
    final steps = ['pending', 'paid', 'shipped', 'delivered'];
    final currentIndex = steps.indexOf(status);
    final isCancelled = status == 'cancelled';
    final isReturnRelated = status == 'return_requested' || status == 'returned' || status == 'partial_return' || status == 'return_rejected';

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Pedido cancelado', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (isReturnRelated) {
      final statusInfo = widget.getStatusInfo(status);
      final color = statusInfo['color'] as Color;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(statusInfo['icon'] as IconData, color: color, size: 20),
            const SizedBox(width: 8),
            Text(statusInfo['label'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;
        final labels = ['Pendiente', 'Pagado', 'Enviado', 'Entregado'];

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.neonCyan : Colors.grey[800],
                        border: Border.all(
                          color: isCompleted ? AppColors.neonCyan : Colors.grey[600]!,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.black, size: 16)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isCompleted ? AppColors.neonCyan : Colors.grey[600],
                        fontSize: 10,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: index < currentIndex ? AppColors.neonCyan : Colors.grey[800],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Sección para cambiar el estado del pedido
  Widget _buildStatusSection(String currentStatus) {
    final statuses = ['pending', 'paid', 'shipped', 'delivered', 'cancelled', 'return_requested', 'returned', 'partial_return', 'return_rejected'];
    final labels = {
      'pending': 'Pendiente',
      'paid': 'Pagado',
      'shipped': 'Enviado',
      'delivered': 'Entregado',
      'cancelled': 'Cancelado',
      'return_requested': 'Devolución solicitada',
      'returned': 'Devuelto',
      'partial_return': 'Devolución parcial',
      'return_rejected': 'Devolución rechazada',
    };

    // Estados destructivos que requieren confirmación inmediata (generan reembolsos)
    const destructiveStatuses = {'cancelled', 'returned'};

    // ── Pedidos finalizados: solo lectura (cancelado, devuelto, devolución parcial) ──
    const _finalStatuses = {'cancelled', 'returned'};
    if (_finalStatuses.contains(currentStatus)) {
      final statusInfo = widget.getStatusInfo(currentStatus);
      final statusColor = statusInfo['color'] as Color;
      final statusLabel = statusInfo['label'] as String;
      final statusIcon = statusInfo['icon'] as IconData;
      final cancellationReason = widget.order['cancellation_reason'] as String?;
      final returnReason = widget.order['return_reason'] as String?;
      final reason = currentStatus == 'cancelled' ? cancellationReason : returnReason;
      final reasonTitle = currentStatus == 'cancelled' ? 'Motivo de la cancelación:' : 'Motivo de la devolución:';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Estado del pedido'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reasonTitle, style: TextStyle(color: Colors.amber[300], fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            reason,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (reason == null || reason.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentStatus == 'cancelled'
                          ? 'No se proporcionó motivo de cancelación.'
                          : 'No se proporcionó motivo de devolución.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Este pedido no se puede modificar.',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Estado del pedido'),
          const SizedBox(height: 8),
          Text(
            'El cambio de estado se guardará al pulsar el botón "Guardar"',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          const SizedBox(height: 12),

          // ── Botones rápidos para gestionar devolución solicitada ──────────
          if (currentStatus == 'return_requested') ...[  
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_return, color: Colors.amber, size: 17),
                      SizedBox(width: 8),
                      Text(
                        'Solicitud de devolución pendiente',
                        style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onRejectReturn(),
                          icon: Icon(Icons.close, size: 15, color: Colors.red[400]),
                          label: Text('Rechazar', style: TextStyle(color: Colors.red[400], fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmDialog(
                            title: 'Aceptar devolución',
                            message: '¿Aceptar la devolución completa? Se procesará el reembolso completo al cliente.',
                            onConfirm: () => widget.onUpdateStatus(widget.order['id'], 'returned'),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 15),
                          label: const Text('Aceptar', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Indicador de cambio pendiente
          if (_selectedStatus != (widget.order['status'] as String? ?? 'pending')) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cambio pendiente: ${labels[_selectedStatus] ?? _selectedStatus}',
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          DropdownButtonFormField<String>(
            value: _selectedStatus,
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF12121A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: statuses.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(labels[s] ?? s),
              );
            }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null && newStatus != _selectedStatus) {
                // Estados destructivos: confirmación inmediata (generan reembolsos/cancelaciones)
                if (destructiveStatuses.contains(newStatus)) {
                  _showConfirmDialog(
                    title: 'Cambiar estado',
                    message: '¿Cambiar estado a "${labels[newStatus]}"? Esta acción se ejecutará inmediatamente.',
                    onConfirm: () {
                      widget.onUpdateStatus(widget.order['id'], newStatus);
                    },
                  );
                } else {
                  // Cambio normal: solo actualizar estado local
                  setState(() => _selectedStatus = newStatus);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Sección de envío con formulario editable
  Widget _buildShippingSection(String status, bool hasTracking) {
    final isShippedOrDelivered = status == 'shipped' || status == 'delivered';
    final shippedAt = widget.order['shipped_at'] as String?;
    final deliveredAt = widget.order['delivered_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              _buildSectionTitle('Información de envío'),
            ],
          ),
          const SizedBox(height: 16),

          // Fechas de envío si existen
          if (shippedAt != null) ...[
            _buildInfoChip(Icons.send, 'Enviado', _formatDateTime(shippedAt), Colors.purple),
            const SizedBox(height: 8),
          ],
          if (deliveredAt != null) ...[
            _buildInfoChip(Icons.check_circle, 'Entregado', _formatDateTime(deliveredAt), Colors.green),
            const SizedBox(height: 16),
          ],

          // Selector de transportista
          const Text('Empresa transportista', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCarrier,
            hint: const Text('Seleccionar transportista', style: TextStyle(color: Colors.grey)),
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(),
            items: _carriers.map((carrier) {
              return DropdownMenuItem(
                value: carrier.id,
                child: Text(carrier.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCarrier = value;
                _autoGenerateUrl();
              });
            },
          ),

          const SizedBox(height: 16),

          // Código de seguimiento
          const Text('Código de seguimiento', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _trackingController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hintText: 'Ej: 1Z999AA10123456784',
              suffixIcon: _trackingController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _trackingController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código copiado'), duration: Duration(seconds: 1)),
                        );
                      },
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // URL de seguimiento
          const Text('URL de seguimiento', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _trackingUrlController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDecoration(
              hintText: 'Se genera automáticamente',
              suffixIcon: _trackingUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.open_in_new, color: AppColors.neonCyan, size: 18),
                      onPressed: () async {
                        final url = Uri.tryParse(_trackingUrlController.text);
                        if (url != null) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Checkbox para marcar como enviado (solo si está en estado 'paid')
          if (status == 'paid') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _markAsShipped,
                      onChanged: (value) => setState(() => _markAsShipped = value ?? false),
                      activeColor: AppColors.neonCyan,
                      side: BorderSide(color: Colors.grey[600]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Marcar como enviado y notificar al cliente',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Botón guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() => _isSaving = true);
                      final originalStatus = widget.order['status'] as String? ?? 'pending';
                      final statusChanged = _selectedStatus != originalStatus;
                      widget.onUpdateShipping(
                        orderId: widget.order['id'],
                        shippingCarrier: _selectedCarrier,
                        trackingNumber: _trackingController.text.trim().isEmpty
                            ? null
                            : _trackingController.text.trim(),
                        trackingUrl: _trackingUrlController.text.trim().isEmpty
                            ? null
                            : _trackingUrlController.text.trim(),
                        markAsShipped: _markAsShipped,
                        newStatus: statusChanged ? _selectedStatus : null,
                      );
                    },
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Icon(
                      _markAsShipped || _selectedStatus != (widget.order['status'] as String? ?? 'pending')
                          ? Icons.local_shipping
                          : Icons.save,
                      size: 18,
                    ),
              label: Text(
                _markAsShipped
                    ? 'Guardar y marcar como enviado'
                    : _selectedStatus != (widget.order['status'] as String? ?? 'pending')
                        ? 'Guardar cambios'
                        : 'Guardar datos de envío',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _markAsShipped || _selectedStatus != (widget.order['status'] as String? ?? 'pending')
                    ? Colors.blue
                    : AppColors.neonCyan,
                foregroundColor: _markAsShipped || _selectedStatus != (widget.order['status'] as String? ?? 'pending')
                    ? Colors.white
                    : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Tracking existente - enlace rápido
          if (hasTracking && isShippedOrDelivered) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = widget.order['tracking_url'] as String?;
                  if (url != null) {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Ver seguimiento del envío'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonCyan,
                  side: const BorderSide(color: AppColors.neonCyan),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF12121A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.neonCyan),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(dynamic item) {
    final colorName = item['color'] as String?;
    final productImage = item['product_image'] as String?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey[800],
              child: productImage != null && productImage.isNotEmpty
                  ? Image.network(
                      productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, color: Colors.grey, size: 24),
                    )
                  : const Icon(Icons.image, color: Colors.grey, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name'] ?? 'Producto',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Talla: ${item['size'] ?? 'N/A'}${colorName != null && colorName.isNotEmpty ? ' · $colorName' : ''} · Cantidad: ${item['quantity'] ?? 1}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '€${(item['price_at_purchase'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan),
            child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// Provider de Supabase para usar en la pantalla
final supabaseProvider = Provider((ref) => Supabase.instance.client);
