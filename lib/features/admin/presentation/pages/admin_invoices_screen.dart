import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Lista de facturas con datos de pedido
final adminInvoicesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final admin = ref.read(adminSessionProvider);
  if (admin == null) throw Exception('No autenticado');

  final supabase = Supabase.instance.client;

  final response = await supabase
      .from('facturacion')
      .select('*, orders!inner(customer_email, customer_name, status, total)')
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
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

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final invoicesAsync = ref.watch(adminInvoicesProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
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
              invoices.isEmpty ? _buildEmpty() : _buildList(invoices),
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
  Widget _buildList(List<Map<String, dynamic>> invoices) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return _buildInvoiceCard(inv);
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> inv) {
    final order = inv['orders'] as Map<String, dynamic>?;
    final invoiceNumber = inv['invoice_number'] ?? '#${inv['id']}';
    final customerName =
        inv['customer_name'] ?? order?['customer_name'] ?? 'Cliente';
    final customerEmail =
        inv['customer_email'] ?? order?['customer_email'] ?? '';
    final total = (inv['total'] ?? order?['total'] ?? 0).toDouble();
    final createdAt = DateTime.tryParse(inv['created_at'] ?? '');
    final orderId = inv['order_id'];
    final isSending = _isSending && _sendingOrderId == orderId?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
                  color: AppColors.neonCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long,
                    color: AppColors.neonCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
                style: const TextStyle(
                  color: AppColors.neonCyan,
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
                  onTap: () => _viewInvoice(orderId),
                ),
              ),
              const SizedBox(width: 10),
              // Enviar email
              Expanded(
                child: _ActionButton(
                  icon: isSending ? Icons.hourglass_top : Icons.send_outlined,
                  label: isSending ? 'Enviando…' : 'Enviar Email',
                  accent: true,
                  onTap: isSending ? null : () => _sendInvoice(orderId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────

  Future<void> _viewInvoice(dynamic orderId) async {
    if (orderId == null) return;
    final url = Uri.parse(
      '${AppConstants.fashionStoreBaseUrl}/api/invoice/$orderId',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendInvoice(dynamic orderId) async {
    if (orderId == null) return;
    setState(() {
      _isSending = true;
      _sendingOrderId = orderId.toString();
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.fashionStoreBaseUrl}/api/invoice/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Factura enviada al cliente'),
            backgroundColor: Colors.green[700],
          ),
        );
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Error al enviar');
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
