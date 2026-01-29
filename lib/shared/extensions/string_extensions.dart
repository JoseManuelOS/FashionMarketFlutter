/// Extensiones útiles para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palabra
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Verifica si es un email válido
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Verifica si es un número de teléfono válido
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Trunca el string con ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Convierte a slug (URL friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// Verifica si es null o vacío
  bool get isNullOrEmpty => isEmpty;

  /// Retorna null si está vacío
  String? get nullIfEmpty => isEmpty ? null : this;
}

/// Extensión para String nullable
extension NullableStringExtensions on String? {
  /// Verifica si es null o vacío
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Retorna el valor o un string vacío
  String get orEmpty => this ?? '';
}
