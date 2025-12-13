import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F12),
    primaryColor: const Color(0xFFFFD700),
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

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: const Color(0xFF2196F3),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF6C63FF),
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme)
        .copyWith(
          displayLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: const TextStyle(color: Color(0xFF424242)),
        ),
    useMaterial3: true,
  );
}
