import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MilestoneReach Design System
/// Implements a modern, bright minimalistic startup aesthetic.
class AppTheme {
  // Light Theme Palette
  static const Color _lightBg = Color(0xFFF8F9FA); // soft white
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF007AFF); // pastel blue accent
  static const Color _lightSecondary = Color(0xFFE8EAF6); // soft lavender
  static const Color _lightAccent = Color(0xFF00C853); // mint green
  static const Color _lightText = Color(0xFF1D1D1F);

  // Dark Theme Palette
  static const Color _darkBg = Color(0xFF0F0F11); // charcoal black
  static const Color _darkSurface = Color(0xFF1C1C1E); // dark slate
  static const Color _darkPrimary = Color(0xFF3A86FF); // neon blue
  static const Color _darkSecondary = Color(0xFF2C2C2E);
  static const Color _darkAccent = Color(0xFF00E676); // bright mint
  static const Color _darkText = Color(0xFFF5F5F7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightSurface,
        background: _lightBg,
        onPrimary: Colors.white,
        onSurface: _lightText,
        onBackground: _lightText,
      ),
      scaffoldBackgroundColor: _lightBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _lightText, letterSpacing: -1.0),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _lightText),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: _lightText),
      ),
      cardTheme: CardTheme(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _lightText),
        titleTextStyle: GoogleFonts.inter(
          color: _lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkSurface,
        background: _darkBg,
        onPrimary: Colors.white,
        onSurface: _darkText,
        onBackground: _darkText,
      ),
      scaffoldBackgroundColor: _darkBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -1.0),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _darkText),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: _darkText),
      ),
      cardTheme: CardTheme(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _darkText),
        titleTextStyle: GoogleFonts.inter(
          color: _darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
