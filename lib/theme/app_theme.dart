import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F12), // Deep dark background
    primaryColor: const Color(0xFFFFD700), // Gold/Banana accent
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFD700),
      secondary: Color(0xFF6C63FF),
      surface: Color(0xFF1E1E24),
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: const TextStyle(color: Color(0xFFE0E0E0)),
    ),
    useMaterial3: true,
  );
}
