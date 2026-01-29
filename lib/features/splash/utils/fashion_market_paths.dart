import 'dart:ui';

/// Clase que genera los paths SVG para el texto "FashionMarket"
/// con un estilo outline/stroke similar al ejemplo de FLUTTER
class FashionMarketPaths {
  FashionMarketPaths._();

  /// Genera el path completo del texto "FashionMarket"
  /// [size] es el tamaño base para escalar las letras
  static Path getFullPath({double scale = 1.0, Offset offset = Offset.zero}) {
    final path = Path();
    double currentX = offset.dx;
    final y = offset.dy;
    final letterSpacing = 8.0 * scale;

    // F
    path.addPath(_letterF(scale), Offset(currentX, y));
    currentX += 35 * scale + letterSpacing;

    // a
    path.addPath(_letterA(scale), Offset(currentX, y));
    currentX += 40 * scale + letterSpacing;

    // s
    path.addPath(_letterS(scale), Offset(currentX, y));
    currentX += 35 * scale + letterSpacing;

    // h
    path.addPath(_letterH(scale), Offset(currentX, y));
    currentX += 40 * scale + letterSpacing;

    // i
    path.addPath(_letterI(scale), Offset(currentX, y));
    currentX += 15 * scale + letterSpacing;

    // o
    path.addPath(_letterO(scale), Offset(currentX, y));
    currentX += 40 * scale + letterSpacing;

    // n
    path.addPath(_letterN(scale), Offset(currentX, y));
    currentX += 40 * scale + letterSpacing + 20 * scale; // Espacio extra entre palabras

    // M
    path.addPath(_letterM(scale), Offset(currentX, y));
    currentX += 50 * scale + letterSpacing;

    // a
    path.addPath(_letterA(scale), Offset(currentX, y));
    currentX += 40 * scale + letterSpacing;

    // r
    path.addPath(_letterR(scale), Offset(currentX, y));
    currentX += 30 * scale + letterSpacing;

    // k
    path.addPath(_letterK(scale), Offset(currentX, y));
    currentX += 35 * scale + letterSpacing;

    // e
    path.addPath(_letterE(scale), Offset(currentX, y));
    currentX += 35 * scale + letterSpacing;

    // t
    path.addPath(_letterT(scale), Offset(currentX, y));

    return path;
  }

  /// Ancho total del texto
  static double getTotalWidth(double scale) {
    final letterSpacing = 8.0 * scale;
    // F(35) + a(40) + s(35) + h(40) + i(15) + o(40) + n(40) + espacio(20) + M(50) + a(40) + r(30) + k(35) + e(35) + t(35)
    return (35 + 40 + 35 + 40 + 15 + 40 + 40 + 20 + 50 + 40 + 30 + 35 + 35 + 35) * scale + 13 * letterSpacing;
  }

  // Letra F
  static Path _letterF(double scale) {
    return Path()
      ..moveTo(0, 60 * scale)
      ..lineTo(0, 0)
      ..lineTo(30 * scale, 0)
      ..moveTo(0, 30 * scale)
      ..lineTo(22 * scale, 30 * scale);
  }

  // Letra a (minúscula)
  static Path _letterA(double scale) {
    return Path()
      ..moveTo(35 * scale, 25 * scale)
      ..lineTo(35 * scale, 60 * scale)
      ..moveTo(35 * scale, 35 * scale)
      ..quadraticBezierTo(35 * scale, 20 * scale, 17 * scale, 20 * scale)
      ..quadraticBezierTo(0, 20 * scale, 0, 35 * scale)
      ..quadraticBezierTo(0, 50 * scale, 17 * scale, 50 * scale)
      ..quadraticBezierTo(35 * scale, 50 * scale, 35 * scale, 60 * scale)
      ..lineTo(35 * scale, 60 * scale)
      ..quadraticBezierTo(35 * scale, 65 * scale, 17 * scale, 65 * scale)
      ..quadraticBezierTo(5 * scale, 65 * scale, 0, 55 * scale);
  }

  // Letra s (minúscula)
  static Path _letterS(double scale) {
    return Path()
      ..moveTo(30 * scale, 28 * scale)
      ..quadraticBezierTo(30 * scale, 20 * scale, 15 * scale, 20 * scale)
      ..quadraticBezierTo(0, 20 * scale, 0, 30 * scale)
      ..quadraticBezierTo(0, 40 * scale, 15 * scale, 40 * scale)
      ..quadraticBezierTo(30 * scale, 40 * scale, 30 * scale, 50 * scale)
      ..quadraticBezierTo(30 * scale, 60 * scale, 15 * scale, 60 * scale)
      ..quadraticBezierTo(0, 60 * scale, 0, 52 * scale);
  }

  // Letra h (minúscula)
  static Path _letterH(double scale) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, 60 * scale)
      ..moveTo(0, 35 * scale)
      ..quadraticBezierTo(0, 20 * scale, 17 * scale, 20 * scale)
      ..quadraticBezierTo(35 * scale, 20 * scale, 35 * scale, 35 * scale)
      ..lineTo(35 * scale, 60 * scale);
  }

  // Letra i (minúscula)
  static Path _letterI(double scale) {
    return Path()
      ..moveTo(7 * scale, 20 * scale)
      ..lineTo(7 * scale, 60 * scale)
      ..moveTo(7 * scale, 5 * scale)
      ..addOval(Rect.fromCircle(center: Offset(7 * scale, 8 * scale), radius: 4 * scale));
  }

  // Letra o (minúscula)
  static Path _letterO(double scale) {
    return Path()
      ..addOval(Rect.fromLTWH(0, 20 * scale, 35 * scale, 40 * scale));
  }

  // Letra n (minúscula)
  static Path _letterN(double scale) {
    return Path()
      ..moveTo(0, 60 * scale)
      ..lineTo(0, 20 * scale)
      ..moveTo(0, 35 * scale)
      ..quadraticBezierTo(0, 20 * scale, 17 * scale, 20 * scale)
      ..quadraticBezierTo(35 * scale, 20 * scale, 35 * scale, 35 * scale)
      ..lineTo(35 * scale, 60 * scale);
  }

  // Letra M (mayúscula)
  static Path _letterM(double scale) {
    return Path()
      ..moveTo(0, 60 * scale)
      ..lineTo(0, 0)
      ..lineTo(25 * scale, 40 * scale)
      ..lineTo(50 * scale, 0)
      ..lineTo(50 * scale, 60 * scale);
  }

  // Letra r (minúscula)
  static Path _letterR(double scale) {
    return Path()
      ..moveTo(0, 60 * scale)
      ..lineTo(0, 20 * scale)
      ..moveTo(0, 35 * scale)
      ..quadraticBezierTo(0, 20 * scale, 15 * scale, 20 * scale)
      ..quadraticBezierTo(25 * scale, 20 * scale, 25 * scale, 25 * scale);
  }

  // Letra k (minúscula)
  static Path _letterK(double scale) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, 60 * scale)
      ..moveTo(30 * scale, 20 * scale)
      ..lineTo(0, 40 * scale)
      ..lineTo(30 * scale, 60 * scale);
  }

  // Letra e (minúscula)
  static Path _letterE(double scale) {
    return Path()
      ..moveTo(0, 40 * scale)
      ..lineTo(30 * scale, 40 * scale)
      ..quadraticBezierTo(32 * scale, 20 * scale, 15 * scale, 20 * scale)
      ..quadraticBezierTo(0, 20 * scale, 0, 40 * scale)
      ..quadraticBezierTo(0, 60 * scale, 15 * scale, 60 * scale)
      ..quadraticBezierTo(28 * scale, 60 * scale, 30 * scale, 50 * scale);
  }

  // Letra t (minúscula)
  static Path _letterT(double scale) {
    return Path()
      ..moveTo(15 * scale, 0)
      ..lineTo(15 * scale, 50 * scale)
      ..quadraticBezierTo(15 * scale, 60 * scale, 25 * scale, 60 * scale)
      ..quadraticBezierTo(30 * scale, 60 * scale, 32 * scale, 55 * scale)
      ..moveTo(0, 15 * scale)
      ..lineTo(30 * scale, 15 * scale);
  }
}
