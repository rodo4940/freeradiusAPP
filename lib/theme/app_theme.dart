import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFB8500);
  static const Color tertiary = Color(0xFFFFB703);
  static const Color darkBg = Color(0xFF023047);
  static const Color accent = Color(0xFF219EBC);
  static const Color lightBg = Color(0xFF8ECAE6);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
    primary: Color(0xFFFB8500),    // naranja → botones principales
    onPrimary: Colors.white,
    secondary: Color(0xFF219EBC),  // azul → botones secundarios / acentos
    onSecondary: Colors.white,
    tertiary: Color(0xFFFFB703),   // amarillo → highlights, iconos, hover
    onTertiary: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black87,
    ),
    // scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 14),
    ),
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black54),
    ),
    // Botones
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      // secondary: secondary,
      // surface: darkBg,
      // onSurface: Colors.white,
    ),
    // scaffoldBackgroundColor: darkBg,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 14, color: Colors.white60),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    // Botones
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
  );
}