/// Clase base para todas las excepciones de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Excepción de red/conexión
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Error de conexión. Verifica tu internet.',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Excepción de servidor
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Error del servidor. Intenta más tarde.',
    super.code = 'SERVER_ERROR',
    super.originalError,
    this.statusCode,
  });
}

/// Excepción de autenticación
class AuthException extends AppException {
  const AuthException({
    super.message = 'Error de autenticación.',
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Excepción de sesión expirada
class SessionExpiredException extends AuthException {
  const SessionExpiredException({
    super.message = 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.',
    super.code = 'SESSION_EXPIRED',
  });
}

/// Excepción de validación
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    super.message = 'Error de validación.',
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Excepción de caché/almacenamiento local
class CacheException extends AppException {
  const CacheException({
    super.message = 'Error al acceder al almacenamiento local.',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Excepción de recurso no encontrado
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Recurso no encontrado.',
    super.code = 'NOT_FOUND',
  });
}

/// Excepción de permiso denegado
class PermissionDeniedException extends AppException {
  const PermissionDeniedException({
    super.message = 'No tienes permiso para realizar esta acción.',
    super.code = 'PERMISSION_DENIED',
  });
}

/// Excepción desconocida
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Ha ocurrido un error inesperado.',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
  });
}
