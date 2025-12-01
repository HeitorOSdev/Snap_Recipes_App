import 'package:flutter/material.dart';

// --- Cores do Tema ---
const Color primaryColor = Color(0xFF46ec13);
const Color backgroundLight = Color(0xFFf6f8f6);
const Color backgroundDark = Color(0xFF142210);
const Color textLight = Color(0xFF111b0d);
const Color textDark = Color(0xFFe8f5e9);
const Color subtleLight = Color(0xFFeef3ed);
const Color subtleDark = Color(0xFF21361c);
const Color borderLight = Color(0xFFdce5d9);
const Color borderDark = Color(0xFF304d2a);

// --- Fonte ---
const String fontDisplay = 'Plus Jakarta Sans';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: fontDisplay,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textLight),
        titleLarge: TextStyle(color: textLight),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        background: backgroundLight,
        surface: backgroundLight,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: fontDisplay,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textDark),
        titleLarge: TextStyle(color: textDark),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        background: backgroundDark,
        surface: backgroundDark,
      ),
      useMaterial3: true,
    );
  }
}
