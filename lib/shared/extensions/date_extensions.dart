import 'package:intl/intl.dart';

/// Extensiones útiles para DateTime
extension DateExtensions on DateTime {
  /// Formato: 01/01/2024
  String get toShortDate => DateFormat('dd/MM/yyyy').format(this);

  /// Formato: 1 de enero de 2024
  String get toLongDate => DateFormat('d MMMM yyyy', 'es').format(this);

  /// Formato: 01/01/2024 14:30
  String get toDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Formato: 14:30
  String get toTime => DateFormat('HH:mm').format(this);

  /// Formato: Lunes, 1 de enero
  String get toDayMonth => DateFormat('EEEE, d MMMM', 'es').format(this);

  /// Verifica si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Verifica si es esta semana
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Tiempo relativo (hace 5 minutos, ayer, etc.)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (isYesterday) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return toShortDate;
    }
  }

  /// Inicio del día (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Fin del día (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Agregar días laborables (sin fines de semana)
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days;
    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }
    return result;
  }
}
