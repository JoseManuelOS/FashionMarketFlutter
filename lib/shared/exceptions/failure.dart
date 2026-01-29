import 'package:equatable/equatable.dart';

/// Clase base para representar fallos (failures) en la aplicación
/// Siguiendo el patrón Either de programación funcional
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de conexión a internet
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet',
    super.code = 'NETWORK_FAILURE',
  });
}

/// Fallo del servidor
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Error del servidor',
    super.code = 'SERVER_FAILURE',
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Error de autenticación',
    super.code = 'AUTH_FAILURE',
  });
}

/// Fallo de validación
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Error de validación',
    super.code = 'VALIDATION_FAILURE',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error de caché',
    super.code = 'CACHE_FAILURE',
  });
}

/// Fallo de recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado',
    super.code = 'NOT_FOUND_FAILURE',
  });
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Error desconocido',
    super.code = 'UNKNOWN_FAILURE',
  });
}
