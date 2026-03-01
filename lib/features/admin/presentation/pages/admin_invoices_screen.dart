import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Lista de facturas con datos de pedido (vía RPC para bypasear RLS)
final adminInvoicesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final admin = ref.read(adminSessionProvider);
  if (admin == null) throw Exception('No autenticado');

  final supabase = Supabase.instance.client;

  final response = await supabase.rpc(
    'admin_get_invoices',
    params: {'p_admin_email': admin.email},
  );

  if (response == null) return [];
  return List<Map<String, dynamic>>.from(response as List);
});

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminInvoicesScreen extends ConsumerStatefulWidget {
  const AdminInvoicesScreen({super.key});

  @override
  ConsumerState<AdminInvoicesScreen> createState() =>
      _AdminInvoicesScreenState();
}

class _AdminInvoicesScreenState extends ConsumerState<AdminInvoicesScreen> {
  bool _isSending = false;
  String? _sendingOrderId;
  String _filterType = 'all'; // 'all', 'fm', 'fr'

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final invoicesAsync = ref.watch(adminInvoicesProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminInvoices),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Facturas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [
          AdminNotificationButton(),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonCyan,
        backgroundColor: const Color(0xFF12121A),
        onRefresh: () async => ref.invalidate(adminInvoicesProvider),
        child: invoicesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          ),
          error: (e, _) => _buildError(e.toString()),
          data: (invoices) =>
              invoices.isEmpty ? _buildEmpty() : _buildContent(invoices),
        ),
      ),
    );
  }

  // ─── Empty state ────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No hay facturas todavía',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ─── Error state ────────────────────────────────────────────────────
  Widget _buildError(String error) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red[400]),
              const SizedBox(height: 12),
              Text(error,
                  style: TextStyle(color: Colors.red[300], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Liste ──────────────────────────────────────────────────────────
  Widget _buildContent(List<Map<String, dynamic>> invoices) {
    // Classify invoices
    final fmInvoices = invoices.where((inv) {
      final num = inv['invoice_number'] as String? ?? '';
      return !num.startsWith('FR-');
    }).toList();
    final frInvoices = invoices.where((inv) {
      final num = inv['invoice_number'] as String? ?? '';
      return num.startsWith('FR-');
    }).toList();

    // Stats
    final totalDocs = invoices.length;
    final totalFMCount = fmInvoices.length;
    final totalFRCount = frInvoices.length;
    final totalBilled = fmInvoices.fold<double>(
        0, (sum, inv) => sum + ((inv['total'] ?? (inv['orders'] as Map?)?['total_price'] ?? 0) as num).toDouble());

    // Filtered list
    final filtered = _filterType == 'fm'
        ? fmInvoices
        : _filterType == 'fr'
            ? frInvoices
            : invoices;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            _StatCard(
              icon: Icons.description_outlined,
              label: 'Documentos',
              value: '$totalDocs',
              color: AppColors.neonCyan,
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.euro_outlined,
              label: 'Facturado',
              value: '€${totalBilled.toStringAsFixed(2)}',
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatCard(
              icon: Icons.receipt_long_outlined,
              label: 'Facturas',
              value: '$totalFMCount',
              color: AppColors.neonCyan,
            ),
            const SizedBox(width: 10),
            _StatCard(
              icon: Icons.replay_outlined,
              label: 'Rectificativas',
              value: '$totalFRCount',
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter chips
        Row(
          children: [
            _FilterChip(
              label: 'Todas',
              selected: _filterType == 'all',
              onTap: () => setState(() => _filterType = 'all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Facturas (FM-)',
              selected: _filterType == 'fm',
              onTap: () => setState(() => _filterType = 'fm'),
              color: AppColors.neonCyan,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Rectificativas (FR-)',
              selected: _filterType == 'fr',
              onTap: () => setState(() => _filterType = 'fr'),
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No hay documentos de este tipo',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
            ),
          )
        else
          ...filtered.map((inv) => _buildInvoiceCard(inv)),
      ],
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> inv) {
    final order = inv['orders'] as Map<String, dynamic>?;
    final invoiceNumber = inv['invoice_number'] as String? ?? '#${inv['id']}';
    final isCreditNote = invoiceNumber.startsWith('FR-');
    final customerName =
        inv['customer_name'] ?? order?['customer_name'] ?? 'Cliente';
    final customerEmail =
        inv['customer_email'] ?? order?['customer_email'] ?? '';
    final total = (inv['total'] ?? order?['total_price'] ?? 0).toDouble();
    final createdAt = DateTime.tryParse(inv['created_at'] ?? '');
    final orderId = inv['order_id'];
    final isSending = _isSending && _sendingOrderId == orderId?.toString();

    final accentColor = isCreditNote ? Colors.orange : AppColors.neonCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCreditNote
              ? Colors.orange.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCreditNote ? Icons.replay_outlined : Icons.receipt_long,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            invoiceNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isCreditNote) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RECTIFICATIVA',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isCreditNote ? Colors.orange : AppColors.neonCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info row
          Row(
            children: [
              if (createdAt != null) ...[
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.email_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  customerEmail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              // Ver factura
              Expanded(
                child: _ActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Ver',
                  onTap: () => _viewInvoice(orderId, invoiceId: inv['id']),
                ),
              ),
              const SizedBox(width: 10),
              // Enviar email
              Expanded(
                child: _ActionButton(
                  icon: isSending ? Icons.hourglass_top : Icons.send_outlined,
                  label: isSending ? 'Enviando…' : 'Enviar Email',
                  accent: true,
                  onTap: isSending ? null : () => _sendInvoice(orderId, invoiceId: inv['id'], isCreditNote: isCreditNote),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────

  Future<void> _viewInvoice(dynamic orderId, {dynamic invoiceId}) async {
    if (orderId == null) return;
    var urlStr = '${AppConstants.fashionStoreBaseUrl}/api/invoice/$orderId';
    if (invoiceId != null) {
      urlStr += '?invoiceId=$invoiceId';
    }
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendInvoice(dynamic orderId, {dynamic invoiceId, bool isCreditNote = false}) async {
    if (orderId == null) return;
    setState(() {
      _isSending = true;
      _sendingOrderId = orderId.toString();
    });

    try {
      final result = await FashionStoreApiService.sendInvoice(
        orderId: orderId.toString(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCreditNote
                ? 'Factura rectificativa enviada al cliente'
                : 'Factura enviada al cliente'),
            backgroundColor: Colors.green[700],
          ),
        );
      } else {
        throw Exception(result['error'] ?? 'Error al enviar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendingOrderId = null;
        });
      }
    }
  }
}

// ─── Small action button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool accent;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent
          ? AppColors.neonCyan.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: accent ? AppColors.neonCyan : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: accent ? AppColors.neonCyan : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter chip ─────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.neonCyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? chipColor : Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
