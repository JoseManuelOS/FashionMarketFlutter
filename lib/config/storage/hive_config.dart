import 'package:hive_flutter/hive_flutter.dart';

/// Inicializa Hive para persistencia local
/// Debe llamarse en main() antes de runApp()
class HiveConfig {
  HiveConfig._();

  /// Inicializa Hive y abre los boxes necesarios
  static Future<void> init() async {
    // Inicializar Hive
    await Hive.initFlutter();

    // Abrir boxes
    await Hive.openBox<Map>('cart');
    await Hive.openBox('user_preferences');
    await Hive.openBox('search_history');
  }

  /// Cierra todos los boxes de Hive
  static Future<void> close() async {
    await Hive.close();
  }

  /// Limpia todos los datos locales
  static Future<void> clearAll() async {
    final cartBox = Hive.box<Map>('cart');
    final prefsBox = Hive.box('user_preferences');
    final searchBox = Hive.box('search_history');

    await cartBox.clear();
    await prefsBox.clear();
    await searchBox.clear();
  }
}
