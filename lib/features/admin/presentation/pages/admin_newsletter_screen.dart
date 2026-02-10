import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Lista de suscriptores al newsletter
final adminSubscribersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('newsletter_subscribers')
      .select()
      .order('subscribed_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminNewsletterScreen extends ConsumerStatefulWidget {
  const AdminNewsletterScreen({super.key});

  @override
  ConsumerState<AdminNewsletterScreen> createState() =>
      _AdminNewsletterScreenState();
}

class _AdminNewsletterScreenState extends ConsumerState<AdminNewsletterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminNewsletter),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Newsletter',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonCyan,
          labelColor: AppColors.neonCyan,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Enviar', icon: Icon(Icons.send, size: 18)),
            Tab(text: 'Suscriptores', icon: Icon(Icons.people, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ComposeTab(),
          _SubscribersTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPOSE TAB — Formulario de envío
// ═══════════════════════════════════════════════════════════════════════════

class _ComposeTab extends ConsumerStatefulWidget {
  const _ComposeTab();

  @override
  ConsumerState<_ComposeTab> createState() => _ComposeTabState();
}

class _ComposeTabState extends ConsumerState<_ComposeTab> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _headerTitleCtrl =
      TextEditingController(text: 'Novedades de FashionMarket');
  final _imageUrlCtrl = TextEditingController();
  final _promoCodeCtrl = TextEditingController();
  final _promoDiscountCtrl = TextEditingController();
  final _buttonTextCtrl = TextEditingController(text: 'Visitar la tienda');
  final _buttonUrlCtrl = TextEditingController();

  bool _isSending = false;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _contentCtrl.dispose();
    _headerTitleCtrl.dispose();
    _imageUrlCtrl.dispose();
    _promoCodeCtrl.dispose();
    _promoDiscountCtrl.dispose();
    _buttonTextCtrl.dispose();
    _buttonUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    // Confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: const Text('Confirmar envío',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de enviar este newsletter a todos los suscriptores?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan),
            child: const Text('Enviar',
                style: TextStyle(color: Color(0xFF0A0A0F))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final body = <String, dynamic>{
        'subject': _subjectCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'headerTitle': _headerTitleCtrl.text.trim(),
        'buttonText': _buttonTextCtrl.text.trim(),
      };
      if (_imageUrlCtrl.text.trim().isNotEmpty) {
        body['imageUrl'] = _imageUrlCtrl.text.trim();
      }
      if (_promoCodeCtrl.text.trim().isNotEmpty) {
        body['promoCode'] = _promoCodeCtrl.text.trim();
      }
      if (_promoDiscountCtrl.text.trim().isNotEmpty) {
        body['promoDiscount'] = _promoDiscountCtrl.text.trim();
      }
      if (_buttonUrlCtrl.text.trim().isNotEmpty) {
        body['buttonUrl'] = _buttonUrlCtrl.text.trim();
      }

      final response = await http.post(
        Uri.parse(
          '${AppConstants.fashionStoreBaseUrl}/api/email/send-newsletter',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final stats = data['stats'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Newsletter enviado: ${stats['sent']} enviados, ${stats['failed']} fallidos',
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 4),
          ),
        );
        // Limpiar formulario
        _subjectCtrl.clear();
        _contentCtrl.clear();
        _imageUrlCtrl.clear();
        _promoCodeCtrl.clear();
        _promoDiscountCtrl.clear();
      } else {
        throw Exception(data['error'] ?? 'Error desconocido');
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
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asunto
            _buildLabel('Asunto *'),
            const SizedBox(height: 8),
            _buildField(
              controller: _subjectCtrl,
              hint: 'Ej: ¡Nuevas novedades de temporada!',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),

            // Contenido
            _buildLabel('Contenido *'),
            const SizedBox(height: 8),
            _buildField(
              controller: _contentCtrl,
              hint: 'Escribe el mensaje del newsletter...',
              maxLines: 6,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),

            // Advanced toggle
            GestureDetector(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Row(
                children: [
                  Icon(
                    _showAdvanced
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.neonCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Opciones avanzadas',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (_showAdvanced) ...[
              const SizedBox(height: 20),
              _buildLabel('Título del header'),
              const SizedBox(height: 8),
              _buildField(
                controller: _headerTitleCtrl,
                hint: 'Novedades de FashionMarket',
              ),
              const SizedBox(height: 16),

              _buildLabel('URL de imagen'),
              const SizedBox(height: 8),
              _buildField(
                controller: _imageUrlCtrl,
                hint: 'https://...',
              ),
              const SizedBox(height: 16),

              _buildLabel('Código promocional'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _promoCodeCtrl,
                      hint: 'Ej: SUMMER20',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _promoDiscountCtrl,
                      hint: 'Ej: 20% de descuento',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Botón CTA'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _buttonTextCtrl,
                      hint: 'Texto del botón',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _buttonUrlCtrl,
                      hint: 'URL destino',
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            //  SEND BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSending ? 'Enviando…' : 'Enviar Newsletter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: const Color(0xFF0A0A0F),
                  disabledBackgroundColor:
                      AppColors.neonCyan.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUBSCRIBERS TAB — Lista de suscriptores
// ═══════════════════════════════════════════════════════════════════════════

class _SubscribersTab extends ConsumerWidget {
  const _SubscribersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribersAsync = ref.watch(adminSubscribersProvider);

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: const Color(0xFF12121A),
      onRefresh: () async => ref.invalidate(adminSubscribersProvider),
      child: subscribersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
        error: (e, _) => ListView(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Text('Error: $e',
                  style: TextStyle(color: Colors.red[300])),
            ),
          ],
        ),
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Sin suscriptores',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final active = subs.where((s) => s['is_active'] == true).length;

          return Column(
            children: [
              // Stats bar
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: Colors.white.withValues(alpha: 0.03),
                child: Row(
                  children: [
                    _StatChip(
                        label: 'Total', value: '${subs.length}', color: Colors.white70),
                    const SizedBox(width: 16),
                    _StatChip(
                        label: 'Activos',
                        value: '$active',
                        color: Colors.green[400]!),
                    const SizedBox(width: 16),
                    _StatChip(
                        label: 'Inactivos',
                        value: '${subs.length - active}',
                        color: Colors.red[400]!),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subs.length,
                  itemBuilder: (context, i) {
                    final sub = subs[i];
                    final isActive = sub['is_active'] == true;
                    final date = DateTime.tryParse(sub['subscribed_at'] ?? '');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Status dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green[400]
                                  : Colors.red[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub['email'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (sub['name'] != null) sub['name'],
                                    if (sub['source'] != null)
                                      'vía ${sub['source']}',
                                    if (date != null)
                                      '${date.day}/${date.month}/${date.year}',
                                  ].join(' · '),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Promo badge
                          if (sub['promo_code_sent'] != null &&
                              sub['promo_code_sent'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonFuchsia
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PROMO',
                                style: TextStyle(
                                  color: AppColors.neonFuchsia,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value ',
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
