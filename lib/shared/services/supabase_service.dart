import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants/app_constants.dart';

/// Servicio para manejar la conexión con Supabase
class SupabaseService {
  SupabaseService._();

  static SupabaseClient? _client;

  /// Inicializa Supabase (llamar en main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Obtiene el cliente de Supabase
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase no ha sido inicializado. Llama a SupabaseService.initialize() primero.');
    }
    return _client!;
  }

  /// Obtiene el cliente de autenticación
  static GoTrueClient get auth => client.auth;

  /// Obtiene el usuario actual
  static User? get currentUser => auth.currentUser;

  /// Verifica si hay una sesión activa
  static bool get isAuthenticated => currentUser != null;

  /// Obtiene el ID del usuario actual
  static String? get userId => currentUser?.id;

  /// Stream de cambios en la autenticación
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}

/// Provider para el cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

/// Provider para el estado de autenticación
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

/// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.isAuthenticated;
});
