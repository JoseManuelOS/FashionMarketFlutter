import '../../data/models/customer_model.dart';

/// Contrato del repositorio de autenticación.
/// Define las operaciones de auth sin exponer la implementación (Supabase).
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  Future<CustomerModel> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<CustomerModel> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Envía email de restablecimiento de contraseña
  Future<void> resetPassword(String email);

  /// Obtiene el perfil del usuario autenticado
  Future<CustomerModel?> getCurrentUser();

  /// Actualiza el perfil del usuario
  Future<CustomerModel> updateProfile(CustomerModel customer);

  /// Inicia sesión con Google OAuth
  Future<CustomerModel> signInWithGoogle();
}
