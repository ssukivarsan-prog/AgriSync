import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Emerald & Nature Color Palette
  static const Color primaryDark = Color(0xFF0C2A1B);    // Deep Forest Obsidian
  static const Color primaryGreen = Color(0xFF1B4D3E);   // Rich Emerald Green
  static const Color accentGreen = Color(0xFF2D6A4F);    // Foliage Green
  static const Color mintVibrant = Color(0xFF10B981);    // Vibrant Leaf Mint
  static const Color mintSoft = Color(0xFFE8F8F0);       // Soft Mint Surface
  static const Color lightSage = Color(0xFFEFF6EF);      // Soft Sage Background
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF7FAF7); // Clean Warm Off-White
  
  // Semantic Status Colors (Mild, warm, earthy & attention-provoking - no alarming harsh reds)
  static const Color healthOptimal = Color(0xFF059669);  // Emerald Success
  static const Color warningModerate = Color(0xFFD97706); // Warm Amber Warning
  static const Color riskHigh = Color(0xFFC2410C);       // Warm Terracotta / Burnt Sienna Alert
  static const Color riskHighSoft = Color(0xFFFED7AA);   // Soft Amber-Terracotta Tint Border
  static const Color riskHighBg = Color(0xFFFFF7ED);     // Soft Warm Ivory/Peach Surface
  static const Color waterCyan = Color(0xFF0284C7);      // Sky / Water Blue
  static const Color earthAmber = Color(0xFFB45309);     // Rich Soil Accent
  static const Color purpleAccent = Color(0xFF7C3AED);   // Deep Analytics Purple

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F3823), Color(0xFF1B4D3E), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintCardGradient = LinearGradient(
    colors: [Color(0xFFF0FDF4), Color(0xFFE8F8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralCardGradient = LinearGradient(
    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyCardGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleCardGradient = LinearGradient(
    colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Premium Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F2818).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF0F2818).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1B4D3E).withValues(alpha: 0.16),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: surfaceWhite,
        error: riskHigh,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF141F17),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: primaryDark,
          letterSpacing: -0.8,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF141F17),
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF141F17),
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF141F17),
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E33),
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF4B5E52),
          height: 1.4,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEAEFEA), width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.5,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: Color(0xFFD1E0D4), width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSage,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: primaryGreen,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F7F4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E9E3), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E9E3), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: const Color(0xFF8A9A8F),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF3EE),
        thickness: 1.2,
        space: 20,
      ),
    );
  }
}
