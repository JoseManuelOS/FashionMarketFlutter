import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/cart_item_model.dart';

part 'cart_providers.g.dart';

/// Key para el box de Hive del carrito
const String _cartBoxName = 'cart';

/// Provider para inicializar Hive para el carrito
final cartBoxProvider = FutureProvider<Box<Map>>((ref) async {
  if (!Hive.isBoxOpen(_cartBoxName)) {
    return await Hive.openBox<Map>(_cartBoxName);
  }
  return Hive.box<Map>(_cartBoxName);
});

/// Notifier para gestionar el estado del carrito
@riverpod
class CartNotifier extends _$CartNotifier {
  Box<Map>? _box;

  @override
  List<CartItemModel> build() {
    // Cargar items desde Hive al iniciar
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    try {
      _box = await ref.read(cartBoxProvider.future);
      final items = _box!.values
          .map((json) => CartItemModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      state = items;
    } catch (e) {
      // Si hay error, iniciar con carrito vacío
      state = [];
    }
  }

  Future<void> _saveToStorage() async {
    if (_box == null) return;
    await _box!.clear();
    for (var i = 0; i < state.length; i++) {
      await _box!.put(i, state[i].toJson());
    }
  }

  /// Añadir producto al carrito
  void addItem(CartItemModel item) {
    final existingIndex = state.indexWhere(
      (i) => i.productId == item.productId && i.size == item.size,
    );

    if (existingIndex >= 0) {
      // Si ya existe, incrementar cantidad
      final existing = state[existingIndex];
      final updated = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updated,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Si no existe, añadir nuevo item
      state = [...state, item];
    }

    _saveToStorage();
  }

  /// Eliminar item del carrito
  void removeItem(String productId, String size) {
    state = state
        .where((item) => !(item.productId == productId && item.size == size))
        .toList();
    _saveToStorage();
  }

  /// Actualizar cantidad de un item
  void updateQuantity(String productId, String size, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, size);
      return;
    }

    final index = state.indexWhere(
      (i) => i.productId == productId && i.size == size,
    );

    if (index >= 0) {
      final updated = state[index].copyWith(quantity: quantity);
      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      _saveToStorage();
    }
  }

  /// Incrementar cantidad
  void incrementQuantity(String productId, String size) {
    final item = state.firstWhere(
      (i) => i.productId == productId && i.size == size,
      orElse: () => throw Exception('Item not found'),
    );
    updateQuantity(productId, size, item.quantity + 1);
  }

  /// Decrementar cantidad
  void decrementQuantity(String productId, String size) {
    final item = state.firstWhere(
      (i) => i.productId == productId && i.size == size,
      orElse: () => throw Exception('Item not found'),
    );
    updateQuantity(productId, size, item.quantity - 1);
  }

  /// Vaciar carrito
  void clear() {
    state = [];
    _saveToStorage();
  }

  /// Alias para vaciar carrito
  void clearCart() => clear();

  /// Verificar si un producto está en el carrito
  bool containsProduct(String productId, [String? size]) {
    if (size != null) {
      return state.any((i) => i.productId == productId && i.size == size);
    }
    return state.any((i) => i.productId == productId);
  }
}

/// Provider para el total del carrito
@riverpod
double cartTotal(Ref ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold(0, (sum, item) => sum + item.subtotal);
}

/// Provider para el número de items en el carrito
@riverpod
int cartItemCount(Ref ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
}

/// Provider para el ahorro total (descuentos)
@riverpod
double cartSavings(Ref ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold(0.0, (sum, item) => sum + item.savings);
}

/// Provider para verificar si el carrito está vacío
@riverpod
bool isCartEmpty(Ref ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.isEmpty;
}
