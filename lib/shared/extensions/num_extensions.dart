import 'package:intl/intl.dart';

/// Extensiones útiles para números
extension NumExtensions on num {
  /// Formatea como moneda
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(this);
  }

  /// Formatea como precio (MXN)
  String toMXN() => toCurrency(symbol: '\$', decimals: 2);

  /// Formatea con separadores de miles
  String toThousands() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }

  /// Formatea como porcentaje
  String toPercentage({int decimals = 0}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Convierte a duración en milisegundos
  Duration get milliseconds => Duration(milliseconds: toInt());

  /// Convierte a duración en segundos
  Duration get seconds => Duration(seconds: toInt());

  /// Convierte a duración en minutos
  Duration get minutes => Duration(minutes: toInt());

  /// Convierte a duración en horas
  Duration get hours => Duration(hours: toInt());

  /// Convierte a duración en días
  Duration get days => Duration(days: toInt());
}

/// Extensiones para double
extension DoubleExtensions on double {
  /// Redondea a N decimales
  double roundTo(int decimals) {
    final mod = 10.0 * decimals;
    return (this * mod).round() / mod;
  }
}
