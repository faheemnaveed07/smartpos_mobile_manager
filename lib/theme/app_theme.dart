import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Mere recommended scheme use karo
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF00ACC1);
  static const Color accentColor = Color(0xFFFF6F00);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),

      // AppBar theme (line 18)
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme (line 27)
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Button theme (line 34)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Text theme (line 44)
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  // Dark Theme - Optional, lekin rakh lo
  static ThemeData get darkTheme {
    return ThemeData(/* ...dark theme logic... */);
  }
}
