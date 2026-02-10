import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/customer_model.dart';

part 'auth_providers.g.dart';

/// Provider para el cliente de Supabase
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider para escuchar cambios de autenticación
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

/// Provider para el usuario actual
@riverpod
User? currentUser(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser;
}

/// Provider para verificar si está autenticado
@riverpod
bool isAuthenticated(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// Provider para obtener el perfil del cliente actual
@riverpod
Future<CustomerModel?> currentCustomer(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider);
  
  final response = await supabase
      .from('customers')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return CustomerModel.fromJson(response);
}

/// Notifier para manejar operaciones de autenticación
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  SupabaseClient get _supabase => ref.read(supabaseProvider);

  /// Iniciar sesión con email y contraseña
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return response;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Registrar nuevo usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    bool newsletter = false,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      // Crear perfil en tabla customers
      if (response.user != null) {
        await _supabase.from('customers').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'newsletter': newsletter,
        });
      }

      state = const AsyncData(null);
      return response;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Obtiene la URL de redirección según la plataforma
  String? _getOAuthRedirectUrl() {
    if (kIsWeb) {
      // En web, usar la URL actual del navegador para que Supabase redirija de vuelta aquí
      return Uri.base.origin;
    }
    // En nativo (Android/iOS), usar deep link
    return 'io.supabase.fashionmarket://login-callback/';
  }

  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getOAuthRedirectUrl(),
      );
      state = const AsyncData(null);
      return success;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Iniciar sesión con Apple
  Future<bool> signInWithApple() async {
    state = const AsyncLoading();

    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _getOAuthRedirectUrl(),
      );
      state = const AsyncData(null);
      return success;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await _supabase.auth.signOut();
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Enviar email para recuperar contraseña
  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Actualizar perfil del usuario
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    state = const AsyncLoading();

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase
          .from('customers')
          .update(updates)
          .eq('id', user.id);

      // Invalidar cache del perfil
      ref.invalidate(currentCustomerProvider);
      
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}
