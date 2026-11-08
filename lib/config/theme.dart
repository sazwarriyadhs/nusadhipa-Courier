import 'package:flutter/material.dart';

// ============================================================
// NUSA-DHIPA COURIER DARK THEME (Sesuai Mockup)
// ============================================================

const bgDark = Color(0xFF121212);
const surfaceDark = Color(0xFF1E1E1E);
const surfaceLight = Color(0xFF2C2C2C);

const brandRed = Color(0xFFE5232E); 
const courierGreen = Color(0xFF34C759);
const courierBlue = Color(0xFF007AFF);
const warningOrange = Color(0xFFF59E0B);

const textPrimary = Colors.white;
const textSecondary = Color(0xFFAAAAAA);
const textMuted = Color(0xFF777777);

const redGradient = LinearGradient(
  colors: [Color(0xFFE5232E), Color(0xFFB3121B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// --- TAMBAHAN: ALIAS KOMPATIBILITAS UNTUK FILE LAMA ---
const canvas = bgDark;
const ink = textPrimary;
const muted = textMuted;
const line = surfaceLight;
const brandGradient = redGradient;
// ------------------------------------------------------

ThemeData buildCourierTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: brandRed,
      secondary: warningOrange,
      surface: surfaceDark,
      background: bgDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    // FIX: CardTheme -> CardThemeData
    cardTheme: CardThemeData(
      color: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w900),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: textSecondary),
    ),
  );
}
