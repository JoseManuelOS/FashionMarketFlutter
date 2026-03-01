import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto de Fashion Market
/// Serif (Playfair Display) para encabezados, Sans-serif (Lato) para cuerpo
class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADINGS — Playfair Display (Serif "Sofisticado")
  // ═══════════════════════════════════════════════════════════════════════════
  static TextStyle get h1 => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY — Lato (Sans-serif limpio)
  // ═══════════════════════════════════════════════════════════════════════════
  static TextStyle get bodyLarge => GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Button
  static TextStyle get button => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
  );

  // Caption
  static TextStyle get caption => GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
