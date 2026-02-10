import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
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
        context.go(AppRoutes.adminLogin);
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
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
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
                print('❌ Error cargando pedidos: $e');
                print('📍 Stack: $stack');
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
                        onPressed: () => ref.invalidate(adminOrdersProvider(_selectedStatus)),
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
                    ref.invalidate(adminOrdersProvider(_selectedStatus));
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
      selectedColor: AppColors.neonCyan.withOpacity(0.2),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  color: statusInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusInfo['color'].withOpacity(0.3)),
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
          color: color.withOpacity(0.1),
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
      final supabase = ref.read(supabaseProvider);
      final updateData = <String, dynamic>{'status': newStatus};
      
      // Si se marca como entregado, añadir fecha
      if (newStatus == 'delivered') {
        updateData['delivered_at'] = DateTime.now().toIso8601String();
      }
      
      await supabase
          .from('orders')
          .update(updateData)
          .eq('id', orderId);

      ref.invalidate(adminOrdersProvider(_selectedStatus));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a ${_getStatusInfo(newStatus)['label']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el estado'),
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
  }) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final updateData = <String, dynamic>{
        'shipping_carrier': shippingCarrier,
        'tracking_number': trackingNumber,
        'tracking_url': trackingUrl,
      };

      if (markAsShipped) {
        updateData['status'] = 'shipped';
        updateData['shipped_at'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('orders')
          .update(updateData)
          .eq('id', orderId);

      ref.invalidate(adminOrdersProvider(_selectedStatus));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              markAsShipped
                  ? 'Pedido marcado como enviado'
                  : 'Datos de envío actualizados',
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
        onUpdateShipping: ({
          required dynamic orderId,
          required String? shippingCarrier,
          required String? trackingNumber,
          required String? trackingUrl,
          required bool markAsShipped,
        }) {
          Navigator.of(context).pop();
          _updateOrderShipping(
            orderId: orderId,
            shippingCarrier: shippingCarrier,
            trackingNumber: trackingNumber,
            trackingUrl: trackingUrl,
            markAsShipped: markAsShipped,
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
  final void Function({
    required dynamic orderId,
    required String? shippingCarrier,
    required String? trackingNumber,
    required String? trackingUrl,
    required bool markAsShipped,
  }) onUpdateShipping;
  final Map<String, dynamic> Function(String) getStatusInfo;

  const _OrderDetailSheet({
    required this.order,
    required this.onUpdateStatus,
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
  bool _markAsShipped = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
        final status = widget.order['status'] as String? ?? 'pending';
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
                      color: (statusInfo['color'] as Color).withOpacity(0.1),
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

              // === Sección de Envío ===
              _buildShippingSection(status, hasTracking),

              const SizedBox(height: 24),

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

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
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
    final statuses = ['pending', 'paid', 'shipped', 'delivered', 'cancelled'];
    final labels = {
      'pending': 'Pendiente',
      'paid': 'Pagado',
      'shipped': 'Enviado',
      'delivered': 'Entregado',
      'cancelled': 'Cancelado',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Estado del pedido'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: currentStatus,
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF12121A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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
              if (newStatus != null && newStatus != currentStatus) {
                _showConfirmDialog(
                  title: 'Cambiar estado',
                  message: '¿Cambiar estado a "${labels[newStatus]}"?',
                  onConfirm: () {
                    widget.onUpdateStatus(widget.order['id'], newStatus);
                  },
                );
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
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
                      );
                    },
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Icon(
                      _markAsShipped ? Icons.local_shipping : Icons.save,
                      size: 18,
                    ),
              label: Text(
                _markAsShipped ? 'Guardar y marcar como enviado' : 'Guardar datos de envío',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _markAsShipped ? Colors.blue : AppColors.neonCyan,
                foregroundColor: _markAsShipped ? Colors.white : Colors.black,
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
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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
        color: color.withOpacity(0.1),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
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
                  'Talla: ${item['size'] ?? 'N/A'} · Cantidad: ${item['quantity'] ?? 1}',
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
