import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AUTOwn'26 visual identity: deep "night-drive" navy with electric cyan / blue
/// accents (intelligence & EV), a teal italic for the theme line (as in the
/// official information sheet) and amber for prizes.
class AppColors {
  static const bg = Color(0xFF060A14);
  static const surface = Color(0xFF0C1322);
  static const card = Color(0xFF111A2E);
  static const border = Color(0xFF223050);
  static const cyan = Color(0xFF00D1FF);
  static const blue = Color(0xFF3A7BFF);
  static const teal = Color(0xFF4FB3C8);
  static const amber = Color(0xFFFFB547);
  static const green = Color(0xFF37D39B);
  static const pink = Color(0xFFFF5C8A);
  static const text = Color(0xFFE8EEF8);
  static const muted = Color(0xFF93A3BD);
}

/// Opacity helper that works on every Flutter 3.x version.
Color fade(Color c, double opacity) => c.withAlpha((opacity * 255).round().clamp(0, 255));

const brandGradient = LinearGradient(
  colors: [AppColors.cyan, AppColors.blue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

TextStyle displayStyle(double size, {Color color = AppColors.text, FontWeight weight = FontWeight.w800}) =>
    GoogleFonts.orbitron(fontSize: size, color: color, fontWeight: weight, letterSpacing: 1.2, height: 1.15);

TextStyle bodyStyle(double size, {Color color = AppColors.muted, FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, height: 1.6);

TextStyle themeLineStyle(double size) =>
    GoogleFonts.playfairDisplay(fontSize: size, color: AppColors.teal, fontStyle: FontStyle.italic, height: 1.35);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.dark,
      primary: AppColors.cyan,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bg,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
