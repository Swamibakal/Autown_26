import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AUTOwn'26 palette, taken from the final brochure and logo:
/// deep indigo (#1F1E6E) + logo red (#CC404E) + peach (#FFD09C) headings,
/// with the brochure's yellow / sky-blue / red accent stripe, on white and soft lavender pages.
class AppColors {
  // Brand
  static const primary = Color(0xFF1F1E6E); // indigo (logo + brochure panels)
  static const primaryLight = Color(0xFF3A37A0);
  static const red = Color(0xFFCC404E); // logo "26"
  static const stripeRed = Color(0xFFEB1F27);
  static const yellow = Color(0xFFFBBA16);
  static const peach = Color(0xFFFFD09C); // brochure headings on indigo, schedule day bars
  static const peachDeep = Color(0xFFF3A35B); // heading accent bars on white
  static const sky = Color(0xFF75C1E3);
  static const green = Color(0xFF2FA77A);

  // Surfaces & text
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF4F5FB);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE1E3F0);
  static const text = Color(0xFF17163F);
  static const muted = Color(0xFF5A5E7A);
  static const onDark = Color(0xFFFFFFFF);
  static const onDarkMuted = Color(0xFFC9C8EA);

  // Aliases kept so older widgets keep compiling.
  static const cyan = primary;
  static const blue = sky;
  static const teal = primary;
  static const amber = yellow;
  static const pink = red;
}

/// Opacity helper that works on every Flutter 3.x version.
Color fade(Color c, double opacity) => c.withAlpha((opacity * 255).round().clamp(0, 255));

const brandGradient = LinearGradient(
  colors: [AppColors.primary, AppColors.primaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

TextStyle displayStyle(double size, {Color color = AppColors.primary, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight, height: 1.2);

TextStyle bodyStyle(double size, {Color color = AppColors.muted, FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, height: 1.6);

TextStyle themeLineStyle(double size, {Color color = AppColors.primary}) =>
    GoogleFonts.inter(fontSize: size, color: color, fontWeight: FontWeight.w500, height: 1.4);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.red,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
