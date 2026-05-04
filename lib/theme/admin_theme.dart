import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  static ThemeData get adminLightTheme {
    const primary = Color(0xFFFF8C42);
    const background = Color(0xFFF8F4EF);
    const surface = Color(0xFFFFFFFF);
    const card = Color(0xFFFFF8F2);
    const textPrimary = Color(0xFF1A1200);
    const textSecondary = Color(0xFF8C7B6B);
    const border = Color(0xFFE8D8C8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: const Color(0xFFFFD166),
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        error: const Color(0xFFE53935),
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(),
        displayMedium: GoogleFonts.outfit(),
        displaySmall: GoogleFonts.outfit(),
        headlineLarge: GoogleFonts.outfit(),
        headlineMedium: GoogleFonts.outfit(),
        headlineSmall: GoogleFonts.outfit(),
        titleLarge: GoogleFonts.outfit(),
        titleMedium: GoogleFonts.outfit(),
        titleSmall: GoogleFonts.outfit(),
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(fontSize: 11),
        ),
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
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFFFF0E6)),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered) ? card : surface,
        ),
        headingTextStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textSecondary,
        ),
        dataTextStyle: GoogleFonts.nunito(
          fontSize: 13,
          color: textPrimary,
        ),
        dividerThickness: 1,
        horizontalMargin: 20,
      ),
    );
  }
}
