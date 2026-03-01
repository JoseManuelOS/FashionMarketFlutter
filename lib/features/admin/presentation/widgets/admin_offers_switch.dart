import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';

/// Provider para el estado actual del switch de ofertas (admin)
final adminOffersEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('app_config')
        .select('value')
        .eq('key', 'offers_enabled')
        .maybeSingle();

    return response != null
        ? (response['value'] as String? ?? 'true') == 'true'
        : true;
  } catch (_) {
    return true; // Default: ofertas habilitadas
  }
});

/// Widget de switch global de ofertas para el panel de admin.
/// Cuando el admin lo desactiva, la sección de ofertas desaparece
/// en tiempo real para todos los clientes (vía Supabase Realtime).
class AdminOffersSwitch extends ConsumerStatefulWidget {
  const AdminOffersSwitch({super.key});

  @override
  ConsumerState<AdminOffersSwitch> createState() => _AdminOffersSwitchState();
}

class _AdminOffersSwitchState extends ConsumerState<AdminOffersSwitch> {
  bool _isSaving = false;

  Future<void> _toggleOffers(bool enabled) async {
    setState(() => _isSaving = true);
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('app_config').upsert({
        'key': 'offers_enabled',
        'value': enabled.toString(),
      }, onConflict: 'key');

      ref.invalidate(adminOffersEnabledProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar ofertas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledAsync = ref.watch(adminOffersEnabledProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neonFuchsia.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.neonFuchsia,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sección Ofertas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Visible para todos los clientes',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neonFuchsia,
              ),
            )
          else
            enabledAsync.when(
              data: (enabled) => Switch(
                value: enabled,
                onChanged: _toggleOffers,
                activeColor: AppColors.neonFuchsia,
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => Switch(
                value: true,
                onChanged: _toggleOffers,
                activeColor: AppColors.neonFuchsia,
              ),
            ),
        ],
      ),
    );
  }
}
