import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenamiento local usando SharedPreferences
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // ============ String ============
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // ============ Int ============
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // ============ Double ============
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // ============ Bool ============
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // ============ List<String> ============
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // ============ JSON Object ============
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // ============ Utilities ============
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  Future<bool> clear() async {
    return _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

/// Provider para SharedPreferences (debe inicializarse en main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences debe ser inicializado antes de usarse');
});

/// Provider para LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});
