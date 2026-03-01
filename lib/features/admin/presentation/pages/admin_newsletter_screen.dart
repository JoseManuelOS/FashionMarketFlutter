import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../../../../shared/services/fashion_store_api_service.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Lista de suscriptores al newsletter (combina tabla + clientes como FashionStore)
final adminSubscribersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;

  // 1. Subscribers from dedicated table
  final tableResponse = await supabase
      .from('newsletter_subscribers')
      .select()
      .order('subscribed_at', ascending: false);
  final tableSubs = List<Map<String, dynamic>>.from(tableResponse);

  // 2. Customers with newsletter = true
  final customerResponse = await supabase
      .from('customers')
      .select('id, email, full_name, newsletter, created_at')
      .eq('newsletter', true);
  final customerSubs = List<Map<String, dynamic>>.from(customerResponse);

  // Track emails to avoid duplicates
  final seenEmails = <String>{};
  final combined = <Map<String, dynamic>>[];

  // Add table subscribers first
  for (final sub in tableSubs) {
    final email = (sub['email'] as String?)?.toLowerCase() ?? '';
    if (email.isNotEmpty && seenEmails.add(email)) {
      combined.add({...sub, '_source': 'popup'});
    }
  }

  // Add customer subscribers
  for (final cust in customerSubs) {
    final email = (cust['email'] as String?)?.toLowerCase() ?? '';
    if (email.isNotEmpty && seenEmails.add(email)) {
      combined.add({
        'email': cust['email'],
        'name': cust['full_name'],
        'is_active': true,
        'subscribed_at': cust['created_at'],
        '_source': 'cliente',
      });
    }
  }

  return combined;
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
        context.go(AppRoutes.home);
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

  // Predefined URL destinations (like FashionStore)
  static const _urlDestinations = <String, String>{
    '/productos': 'Todos los productos',
    '/ofertas': 'Ofertas y descuentos',
    '/categoria/camisas': 'Camisas',
    '/categoria/pantalones': 'Pantalones',
    '/categoria/chaquetas': 'Chaquetas',
    '/categoria/vestidos': 'Vestidos',
    '/categoria/accesorios': 'Accesorios',
    '/': 'Inicio',
  };
  String? _selectedUrlKey = '/productos';

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
      final data = await FashionStoreApiService.sendNewsletter(
        subject: _subjectCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        headerTitle: _headerTitleCtrl.text.trim().isNotEmpty
            ? _headerTitleCtrl.text.trim()
            : null,
        imageUrl: _imageUrlCtrl.text.trim().isNotEmpty
            ? _imageUrlCtrl.text.trim()
            : null,
        promoCode: _promoCodeCtrl.text.trim().isNotEmpty
            ? _promoCodeCtrl.text.trim()
            : null,
        promoDiscount: _promoDiscountCtrl.text.trim().isNotEmpty
            ? _promoDiscountCtrl.text.trim()
            : null,
        buttonText: _buttonTextCtrl.text.trim().isNotEmpty
            ? _buttonTextCtrl.text.trim()
            : null,
        buttonUrl: _selectedUrlKey != null
            ? _selectedUrlKey!
            : (_buttonUrlCtrl.text.trim().isNotEmpty
                ? _buttonUrlCtrl.text.trim()
                : null),
        adminEmail: ref.read(adminSessionProvider)?.email,
      );

      if (!mounted) return;

      if (data['success'] == true) {
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
    final subscribersAsync = ref.watch(adminSubscribersProvider);
    final subscriberCount = subscribersAsync.valueOrNull?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscriber count info (like FashionStore)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.check_circle_outline, color: Colors.green[400], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suscriptores del Newsletter',
                          style: TextStyle(
                            color: Colors.green[300],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$subscriberCount personas recibiran este email',
                          style: TextStyle(
                            color: Colors.green[400]?.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
              _buildLabel('Titulo del header'),
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
              Text(
                'Imagen destacada que aparecera en el email',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
              ),
              const SizedBox(height: 16),

              // Promo section (styled like FashionStore)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 16, color: Colors.amber[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Codigo Promocional (opcional)',
                          style: TextStyle(
                            color: Colors.amber[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _promoCodeCtrl,
                            hint: 'VERANO20',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _promoDiscountCtrl,
                            hint: '20% de descuento',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CTA Button section (styled like FashionStore)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: AppColors.neonCyan),
                        const SizedBox(width: 8),
                        Text(
                          'Boton de Accion',
                          style: TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _buttonTextCtrl,
                      hint: 'Texto del boton',
                    ),
                    const SizedBox(height: 10),
                    // URL Dropdown (like FashionStore)
                    Text(
                      'Destino del boton',
                      style: TextStyle(
                        color: AppColors.neonCyan.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonFormField<String?>(
                        value: _selectedUrlKey,
                        dropdownColor: const Color(0xFF1A1A24),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.4)),
                        items: [
                          ..._urlDestinations.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(fontSize: 14)),
                              )),
                          const DropdownMenuItem(
                            value: null,
                            child: Text('URL personalizada', style: TextStyle(fontSize: 14, color: Colors.white54)),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedUrlKey = v),
                      ),
                    ),
                    if (_selectedUrlKey == null) ...[
                      const SizedBox(height: 10),
                      _buildField(
                        controller: _buttonUrlCtrl,
                        hint: 'https://...',
                      ),
                    ],
                  ],
                ),
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
                    final source = sub['_source'] as String? ??
                        (sub['source'] as String? ?? '');
                    final isPopup = source == 'popup' || source == 'subscriber';
                    final isCliente = source == 'cliente';

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
                          // Avatar (first letter like FashionStore)
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (sub['name'] as String? ?? sub['email'] as String? ?? '?')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        sub['name'] as String? ?? sub['email'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPopup || isCliente) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isCliente
                                              ? AppColors.neonCyan.withValues(alpha: 0.12)
                                              : AppColors.neonFuchsia.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isCliente ? 'Cliente' : 'Popup',
                                          style: TextStyle(
                                            color: isCliente
                                                ? AppColors.neonCyan
                                                : AppColors.neonFuchsia,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    sub['email'] ?? '',
                                    if (date != null)
                                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                                  ].join(' · '),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green[400]
                                  : Colors.red[400],
                              shape: BoxShape.circle,
                            ),
                          ),

                          // Promo badge
                          if (sub['promo_code_sent'] != null &&
                              sub['promo_code_sent'] == true)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
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
