import 'package:flutter/material.dart';

/// Extensiones útiles para BuildContext
extension ContextExtensions on BuildContext {
  // ============ Theme ============
  /// Obtiene el tema actual
  ThemeData get theme => Theme.of(this);

  /// Obtiene el color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Obtiene los estilos de texto
  TextTheme get textTheme => theme.textTheme;

  /// Verifica si el tema es oscuro
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ============ MediaQuery ============
  /// Obtiene el MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Obtiene el tamaño de la pantalla
  Size get screenSize => mediaQuery.size;

  /// Obtiene el ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Obtiene el alto de la pantalla
  double get screenHeight => screenSize.height;

  /// Obtiene el padding seguro (notch, barra de navegación)
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Obtiene el view insets (teclado)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Verifica si el teclado está visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ============ Responsive ============
  /// Verifica si es un dispositivo móvil pequeño
  bool get isMobile => screenWidth < 600;

  /// Verifica si es una tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Verifica si es escritorio
  bool get isDesktop => screenWidth >= 1200;

  /// Orientación de la pantalla
  Orientation get orientation => mediaQuery.orientation;

  /// Verifica si es landscape
  bool get isLandscape => orientation == Orientation.landscape;

  // ============ Navigation ============
  /// Obtiene el NavigatorState
  NavigatorState get navigator => Navigator.of(this);

  /// Pop de la navegación
  void pop<T>([T? result]) => navigator.pop(result);

  /// Push de una ruta
  Future<T?> push<T>(Route<T> route) => navigator.push(route);

  /// Push de una ruta nombrada
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);

  // ============ SnackBar ============
  /// Muestra un SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============ Focus ============
  /// Quita el foco del campo actual
  void unfocus() => FocusScope.of(this).unfocus();
}
