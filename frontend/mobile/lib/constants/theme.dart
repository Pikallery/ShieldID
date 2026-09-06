import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Accent Colors
  static const Color primaryCyan = Color(0xFF00F2FE);
  static const Color primaryBlue = Color(0xFF4FACFE);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentTeal = Color(0xFF06B6D4);

  // Status & Decision Colors
  static const Color passGreen = Color(0xFF10B981);
  static const Color reviewAmber = Color(0xFFF59E0B);
  static const Color rejectRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF38BDF8);

  // Dark Theme Surfaces
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color surfaceCard = Color(0xFF161F30);
  static const Color border = Color(0xFF334155);
  static const Color borderGlow = Color(0xFF1E3A8A);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shieldGradient = LinearGradient(
    colors: [Color(0xFF00F2FE), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient passGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient reviewGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rejectGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x2A1E293B),
      Color(0x1A0F172A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Decoration Helper
  static BoxDecoration glassCardDecoration({
    Color? borderColor,
    double borderRadius = 16.0,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: surface.withOpacity(0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? border.withOpacity(0.7),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        if (glow)
          BoxShadow(
            color: (borderColor ?? primaryCyan).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 1,
          ),
      ],
    );
  }

  // Theme Data Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: primaryBlue,
        surface: surface,
        background: background,
        error: rejectRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
              displayMedium: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 16,
                color: textPrimary,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondary,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                color: textMuted,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.9),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.black,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
