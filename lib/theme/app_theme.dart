import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Warm Palette
  static const Color primary = Color(0xFFFF8C42);
  static const Color primaryDark = Color(0xFFE6721A);
  static const Color secondary = Color(0xFFFFD166);
  static const Color accent = Color(0xFF06D6A0);
  static const Color background = Color(0xFF1A1200);
  static const Color surface = Color(0xFF2C1F00);
  static const Color card = Color(0xFF3D2C00);
  static const Color textPrimary = Color(0xFFFFF8F0);
  static const Color textSecondary = Color(0xFFBFA980);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF06D6A0);

  // Spacing & Border Radii Guidelines (from ui-ux-pro-max)
  static final BorderRadius cardRadius = BorderRadius.circular(20);
  static final BorderRadius buttonRadius = BorderRadius.circular(30);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ).copyWith(
        background: background,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(textStyle: baseTextTheme.displayLarge, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.outfit(textStyle: baseTextTheme.displayMedium, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.outfit(textStyle: baseTextTheme.displaySmall, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.outfit(textStyle: baseTextTheme.headlineLarge, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.outfit(textStyle: baseTextTheme.headlineMedium, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(textStyle: baseTextTheme.headlineSmall, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(textStyle: baseTextTheme.titleLarge, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.outfit(textStyle: baseTextTheme.titleMedium, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.outfit(textStyle: baseTextTheme.titleSmall, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.nunito(textStyle: baseTextTheme.bodyLarge, color: textPrimary),
        bodyMedium: GoogleFonts.nunito(textStyle: baseTextTheme.bodyMedium, color: textPrimary),
        bodySmall: GoogleFonts.nunito(textStyle: baseTextTheme.bodySmall, color: textSecondary),
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.nunito(color: primary, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return GoogleFonts.nunito(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 12);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 26);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.nunito(color: textSecondary),
        labelStyle: GoogleFonts.nunito(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
    );
  }
}
