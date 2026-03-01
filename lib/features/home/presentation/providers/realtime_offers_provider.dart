import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/data/models/product_model.dart';

/// StreamProvider que escucha cambios en tiempo real de la tabla products
/// filtrando solo los que son oferta (is_offer = true).
/// Cuando un admin marca/desmarca un producto como oferta, el cambio
/// se refleja automáticamente en los clientes con Supabase Realtime.
final realtimeOfferProductsProvider =
    StreamProvider<List<ProductModel>>((ref) {
  final supabase = Supabase.instance.client;
  final controller = StreamController<List<ProductModel>>();

  // Carga inicial
  Future<void> fetchOffers() async {
    try {
      final response = await supabase
          .from('products')
          .select('''
            *,
            category:categories(*),
            images:product_images(*)
          ''')
          .eq('active', true)
          .eq('is_offer', true)
          .order('discount_percent', ascending: false)
          .limit(8);

      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
      if (!controller.isClosed) {
        controller.add(products);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  // Carga inicial
  fetchOffers();

  // Suscripción Realtime — escucha INSERT, UPDATE y DELETE en products
  final channel = supabase
      .channel('public:products:offers')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'products',
        callback: (payload) {
          // Cualquier cambio en products → refetch de ofertas
          fetchOffers();
        },
      )
      .subscribe();

  ref.onDispose(() {
    controller.close();
    supabase.removeChannel(channel);
  });

  return controller.stream;
});

/// StreamProvider para la configuración global de ofertas.
/// Escucha la tabla app_config para saber si las ofertas están habilitadas.
/// Si la tabla no existe, defaults a true.
final offersEnabledProvider = StreamProvider<bool>((ref) {
  final supabase = Supabase.instance.client;
  final controller = StreamController<bool>();

  Future<void> fetchConfig() async {
    try {
      final response = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'offers_enabled')
          .maybeSingle();

      final enabled = response != null
          ? (response['value'] as String? ?? 'true') == 'true'
          : true;
      if (!controller.isClosed) {
        controller.add(enabled);
      }
    } catch (e) {
      // Si app_config no existe (404) o cualquier error,
      // asumimos que las ofertas están habilitadas por defecto.
      debugPrint('ℹ️ app_config no disponible (${e.runtimeType}), ofertas habilitadas por defecto');
      if (!controller.isClosed) {
        controller.add(true);
      }
    }
  }

  fetchConfig();

  // Intentar suscribirse a cambios en app_config (puede no existir aún)
  RealtimeChannel? channel;
  try {
    channel = supabase
        .channel('public:app_config')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'app_config',
          callback: (_) => fetchConfig(),
        )
        .subscribe();
  } catch (_) {
    // Tabla no existe todavía — no pasa nada
  }

  ref.onDispose(() {
    controller.close();
    if (channel != null) supabase.removeChannel(channel);
  });

  return controller.stream;
});
