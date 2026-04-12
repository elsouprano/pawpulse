import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFF00D4AA);
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF16213E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color error = Color(0xFFFF6B6B);

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ).copyWith(
        background: background,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.displayLarge),
        displayMedium: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.displayMedium),
        displaySmall: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.displaySmall),
        headlineLarge: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.headlineLarge),
        headlineMedium: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.headlineMedium),
        headlineSmall: GoogleFonts.spaceGrotesk(textStyle: baseTextTheme.headlineSmall),
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: const BorderSide(color: primary),
        ),
      ),
    );
  }
}
