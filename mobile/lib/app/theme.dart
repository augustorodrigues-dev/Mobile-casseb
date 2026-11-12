import 'package:flutter/material.dart';

const forest = Color(0xFF164B3C);
const lime = Color(0xFFD6EBAC);
ThemeData circuitoTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: forest,
    surface: const Color(0xFFF7F8F2),
    primary: forest,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: forest,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE5EADB)),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.15,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -.5),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(height: 1.5),
    ),
  );
}
