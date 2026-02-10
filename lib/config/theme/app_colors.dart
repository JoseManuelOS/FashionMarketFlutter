import 'package:flutter/material.dart';

/// Paleta de colores de Fashion Market - Tema Oscuro Neón
/// Basado en el diseño web de FashionStore
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES NEÓN PRIMARIOS (Cyan)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonCyanLight = Color(0xFF22D3EE);
  static const Color neonCyanDark = Color(0xFF0891B2);
  static const Color neonCyanMuted = Color(0xFF155E75);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES NEÓN SECUNDARIOS (Fuchsia)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color neonFuchsia = Color(0xFFD946EF);
  static const Color neonFuchsiaLight = Color(0xFFE879F9);
  static const Color neonFuchsiaDark = Color(0xFFA21CAF);

  // ═══════════════════════════════════════════════════════════════════════════
  // ACENTOS ADICIONALES
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonGreen = Color(0xFF10B981);

  // ═══════════════════════════════════════════════════════════════════════════
  // FONDOS OSCUROS (Dark Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color dark50 = Color(0xFFF5F5F6);   // Texto claro sobre fondo oscuro
  static const Color dark100 = Color(0xFF2A2A35);  // Bordes sutiles
  static const Color dark200 = Color(0xFF1F1F28);  // Cards elevadas
  static const Color dark300 = Color(0xFF18181F);  // Surface
  static const Color dark400 = Color(0xFF12121A);  // Cards base
  static const Color dark500 = Color(0xFF0D0D14);  // Fondo principal
  static const Color dark600 = Color(0xFF0A0A0F);  // Fondo body (más oscuro)

  // ═══════════════════════════════════════════════════════════════════════════
  // ALIASES SEMÁNTICOS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primary = neonCyan;
  static const Color primaryLight = neonCyanLight;
  static const Color primaryDark = neonCyanDark;

  static const Color secondary = neonFuchsia;
  static const Color secondaryLight = neonFuchsiaLight;
  static const Color secondaryDark = neonFuchsiaDark;

  static const Color background = dark600;
  static const Color surface = dark400;
  static const Color surfaceElevated = dark200;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE TEXTO
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE4E4E7);   // zinc-200
  static const Color textMuted = Color(0xFFA1A1AA);       // zinc-400
  static const Color textSubtle = Color(0xFF71717A);      // zinc-500
  static const Color textOnPrimary = Color(0xFF000000);

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADOS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);    // Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);    // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);      // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);       // Blue

  // ═══════════════════════════════════════════════════════════════════════════
  // EFECTOS GLASS (Glassmorphism)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color glass = Color(0x14FFFFFF);        // 8% white
  static const Color glassLight = Color(0x0DFFFFFF);   // 5% opacity
  static const Color glassMedium = Color(0x14FFFFFF);  // 8% opacity
  static const Color glassHeavy = Color(0x1FFFFFFF);   // 12% opacity
  static const Color glassBorder = Color(0x1AFFFFFF);  // 10% opacity

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDES Y DIVISORES
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = dark100;
  static const Color borderLight = Color(0xFF3F3F46);  // zinc-700
  static const Color divider = Color(0xFF27272A);      // zinc-800

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGES Y TAGS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color badgeNew = neonCyan;
  static const Color badgeOffer = neonFuchsia;
  static const Color badgeSoldOut = Color(0xFF71717A);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTES (para usar con LinearGradient)
  // ═══════════════════════════════════════════════════════════════════════════
  static const List<Color> gradientPrimary = [neonCyan, neonCyanLight];
  static const List<Color> gradientSecondary = [neonFuchsia, neonFuchsiaLight];
  static const List<Color> gradientCyanFuchsia = [neonCyan, neonFuchsia];
  static const List<Color> gradientDark = [dark500, dark600];

  // LinearGradient helper
  static const LinearGradient primaryGradient = LinearGradient(
    colors: gradientCyanFuchsia,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: gradientSecondary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // GREYS LEGACY (para compatibilidad con widgets existentes)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
}

