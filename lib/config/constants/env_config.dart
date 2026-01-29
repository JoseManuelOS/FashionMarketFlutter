/// Configuración de entorno
enum Environment { development, staging, production }

/// Clase para manejar la configuración según el entorno
class EnvConfig {
  EnvConfig._();

  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  /// URL base según el entorno
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.fashionmarket.com';
      case Environment.staging:
        return 'https://staging-api.fashionmarket.com';
      case Environment.production:
        return 'https://api.fashionmarket.com';
    }
  }

  /// Habilitar logs de debug
  static bool get enableDebugLogs {
    return _environment != Environment.production;
  }
}
