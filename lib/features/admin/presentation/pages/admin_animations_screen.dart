import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/app_router.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_notification_button.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Obtiene la configuración de animaciones desde settings
final adminAnimationsConfigProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('settings')
      .select('value')
      .eq('key', 'animations_config')
      .single();

  final raw = response['value'];
  if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return {};
});

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class AdminAnimationsScreen extends ConsumerStatefulWidget {
  const AdminAnimationsScreen({super.key});

  @override
  ConsumerState<AdminAnimationsScreen> createState() =>
      _AdminAnimationsScreenState();
}

class _AdminAnimationsScreenState extends ConsumerState<AdminAnimationsScreen> {
  Map<String, dynamic>? _config;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(adminSessionProvider);
    final configAsync = ref.watch(adminAnimationsConfigProvider);

    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      drawer: AdminDrawer(currentRoute: AppRoutes.adminAnimations),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        title: const Text(
          'Animaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.neonCyan,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(_isSaving ? 'Guardando…' : 'Guardar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neonCyan,
              ),
            ),
          const AdminNotificationButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: configAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.neonCyan),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: Colors.red[300])),
        ),
        data: (serverConfig) {
          // Inicializar copia local editable
          _config ??= Map<String, dynamic>.from(serverConfig);
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    final config = _config!;
    final globalEnabled = config['enabled'] == true;

    return RefreshIndicator(
      color: AppColors.neonCyan,
      backgroundColor: const Color(0xFF12121A),
      onRefresh: () async {
        _config = null;
        _hasChanges = false;
        ref.invalidate(adminAnimationsConfigProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Global toggle
          _buildGlobalToggle(globalEnabled),
          const SizedBox(height: 20),

          // Secciones
          _buildSectionCard(
            title: 'Hero',
            icon: Icons.photo_size_select_actual_outlined,
            sectionKey: 'hero',
            fields: [
              _ToggleField('parallax', 'Parallax'),
            ],
          ),
          _buildSectionCard(
            title: 'Productos',
            icon: Icons.grid_view,
            sectionKey: 'products',
            fields: [
              _ToggleField('scrollReveal', 'Scroll Reveal'),
            ],
          ),
          _buildSectionCard(
            title: 'Categorías',
            icon: Icons.category_outlined,
            sectionKey: 'categories',
            fields: [
              _ToggleField('scrollReveal', 'Scroll Reveal'),
              _ToggleField('hoverZoom', 'Hover Zoom'),
            ],
          ),
          _buildSectionCard(
            title: 'Botones',
            icon: Icons.smart_button_outlined,
            sectionKey: 'buttons',
            fields: [
              _ToggleField('ripple', 'Efecto Ripple'),
              _ToggleField('ctaPulse', 'Pulso CTA'),
            ],
          ),
          _buildSectionCard(
            title: 'Carrito',
            icon: Icons.shopping_cart_outlined,
            sectionKey: 'cart',
            fields: [
              _ToggleField('slideAnimation', 'Slide Animation'),
              _ToggleField('itemsStagger', 'Items Stagger'),
            ],
          ),
          _buildSectionCard(
            title: 'Badges',
            icon: Icons.new_releases_outlined,
            sectionKey: 'badges',
            fields: [
              _ToggleField('pulse', 'Pulse'),
            ],
          ),
          _buildSectionCard(
            title: 'Progreso de Scroll',
            icon: Icons.linear_scale,
            sectionKey: 'scrollProgress',
            fields: [
              _ToggleField('enabled', 'Habilitado'),
            ],
          ),
          _buildSectionCard(
            title: 'Transiciones de Página',
            icon: Icons.swap_horiz,
            sectionKey: 'pageTransitions',
            fields: [
              _ToggleField('enabled', 'Habilitado'),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Global toggle ──────────────────────────────────────────────────
  Widget _buildGlobalToggle(bool enabled) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enabled
              ? [
                  AppColors.neonCyan.withValues(alpha: 0.1),
                  AppColors.neonFuchsia.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.03),
                  Colors.white.withValues(alpha: 0.02),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? AppColors.neonCyan.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (enabled ? AppColors.neonCyan : Colors.white)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.animation,
              color: enabled ? AppColors.neonCyan : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Animaciones Globales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? 'Las animaciones están activas en la tienda web'
                      : 'Las animaciones están desactivadas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppColors.neonCyan,
            onChanged: (v) {
              setState(() {
                _config!['enabled'] = v;
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  // ─── Section card ───────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String sectionKey,
    required List<_ToggleField> fields,
  }) {
    final section =
        _config![sectionKey] as Map<String, dynamic>? ?? {};

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
          // Header
          Row(
            children: [
              Icon(icon, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Toggle fields
          ...fields.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    f.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: section[f.key] == true,
                    activeColor: AppColors.neonCyan,
                    onChanged: (v) {
                      setState(() {
                        final s = Map<String, dynamic>.from(section);
                        s[f.key] = v;
                        _config![sectionKey] = s;
                        _hasChanges = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Duration / easing display (read-only info)
          if (section.containsKey('duration')) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                    label: 'Duración', value: '${section['duration']}s'),
                if (section.containsKey('easing'))
                  _InfoChip(label: 'Easing', value: '${section['easing']}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Save ───────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('settings')
          .update({'value': jsonEncode(_config), 'updated_at': DateTime.now().toIso8601String()})
          .eq('key', 'animations_config');

      if (!mounted) return;

      setState(() => _hasChanges = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuración guardada'),
          backgroundColor: Colors.green[700],
        ),
      );
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
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────

class _ToggleField {
  final String key;
  final String label;
  const _ToggleField(this.key, this.label);
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
        ),
      ),
    );
  }
}
