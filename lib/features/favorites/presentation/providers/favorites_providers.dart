import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/favorites_service.dart';
import '../../../products/data/models/product_model.dart';

/// Provider del repositorio
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Notifier para el set de IDs favoritos (cache global)
class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final repo = ref.read(favoritesRepositoryProvider);
    return repo.getFavoriteIds();
  }

  /// Toggle optimista: actualiza UI inmediatamente, sincroniza con Supabase
  Future<void> toggle(String productId) async {
    final currentIds = state.valueOrNull ?? {};
    final isFav = currentIds.contains(productId);

    // Optimistic update
    final newIds = Set<String>.from(currentIds);
    if (isFav) {
      newIds.remove(productId);
    } else {
      newIds.add(productId);
    }
    state = AsyncData(newIds);

    // Sync con Supabase
    try {
      final repo = ref.read(favoritesRepositoryProvider);
      await repo.toggleFavorite(productId, currentlyFavorite: isFav);
    } catch (_) {
      // Rollback
      state = AsyncData(currentIds);
    }
  }

  /// ¿Es favorito?
  bool isFavorite(String productId) {
    return state.valueOrNull?.contains(productId) ?? false;
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(
  FavoriteIdsNotifier.new,
);

/// Provider helper para saber si un producto concreto es favorito
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final ids = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
  return ids.contains(productId);
});

/// Provider para la lista de productos favoritos (para la pantalla)
final favoriteProductsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  // Watch del ids provider para refrescar cuando cambie
  ref.watch(favoriteIdsProvider);
  final repo = ref.read(favoritesRepositoryProvider);
  return repo.getFavoriteProducts();
});
